resource "google_compute_address" "ghostcms" {
  count        = (var.create_load_balancer == true || var.external_ip != "") ? 1 : 0
  name         = "${var.prefix}-ghostcms"
  network_tier = "STANDARD"
}

data "google_compute_backend_service" "backend_service" {
  name = var.backend_service_name
}

resource "google_compute_backend_bucket" "ghostcms" {
  count       = var.create_load_balancer == true ? 1 : 0
  bucket_name = google_storage_bucket.ghostcms_content.name
  enable_cdn  = false
  name        = "${var.prefix}-ghost-backend-bucket"
}

resource "google_compute_url_map" "ghostcms" {
  count           = var.create_load_balancer == true ? 1 : 0
  default_service = data.google_compute_backend_service.backend_service.self_link
  name            = "${var.prefix}-ghostcms"

  host_rule {
    hosts = [
      var.ghost_envvars.storage__gcloud__assetDomain
    ]
    path_matcher = "path-matcher-1"
  }

  path_matcher {
    default_service = var.ghost_envvars.storage__gcloud__assetDomain == replace(replace(var.ghost_envvars.url, "https://", ""), "http://", "") ? data.google_compute_backend_service.backend_service.self_link : google_compute_backend_bucket.ghostcms[0].self_link
    name            = "path-matcher-1"

    path_rule {
      paths = [
        "/${trimsuffix(trimprefix(lookup(var.ghost_envvars, "storage__gcloud__assetPath", ""), "/"), "/")}/*",
      ]
      service = google_compute_backend_bucket.ghostcms[0].self_link
    }
  }

}

resource "google_compute_managed_ssl_certificate" "ghostcms" {
  count    = var.create_load_balancer == true ? 1 : 0
  provider = google-beta
  name     = "${var.prefix}-ghostcms-cert"
  type     = "MANAGED"

  managed {
    domains = distinct([
      replace(replace(var.ghost_envvars.url, "https://", ""), "http://", ""),
      replace(var.ghost_envvars.storage__gcloud__assetDomain, "/", "")
    ])
  }
}

resource "google_compute_target_http_proxy" "ghostcms" {
  count   = var.create_load_balancer == true ? 1 : 0
  name    = "${var.prefix}-ghostcms-target-proxy"
  url_map = google_compute_url_map.ghostcms[0].self_link
}


resource "google_compute_target_https_proxy" "ghostcms" {
  count   = var.create_load_balancer == true ? 1 : 0
  name    = "${var.prefix}-ghostcms-target-proxy-2"
  url_map = google_compute_url_map.ghostcms[0].self_link
  ssl_certificates = [
    google_compute_managed_ssl_certificate.ghostcms[0].self_link
  ]
}

resource "google_compute_forwarding_rule" "ghostcms-http" {
  count                 = var.create_load_balancer == true ? 1 : 0
  all_ports             = false
  ip_address            = var.external_ip == "" ? google_compute_address.ghostcms[0].address : var.external_ip
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  name                  = "${var.prefix}-ghostcms-http"
  network_tier          = "STANDARD"
  port_range            = "80-80"
  ports                 = []
  region                = var.region
  target                = google_compute_target_http_proxy.ghostcms[0].self_link
}

resource "google_compute_forwarding_rule" "ghostcms-https" {
  count                 = var.create_load_balancer == true ? 1 : 0
  all_ports             = false
  ip_address            = var.external_ip == "" ? google_compute_address.ghostcms[0].address : var.external_ip
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  name                  = "${var.prefix}-ghostcms-https"
  network_tier          = "STANDARD"
  port_range            = "443-443"
  ports                 = []
  region                = var.region
  target                = google_compute_target_https_proxy.ghostcms[0].self_link
}
