resource "kubernetes_namespace" "ghostcms" {
  metadata {
    name = "${var.prefix}-ghostcms"
  }
}

resource "kubernetes_endpoints" "ghostdb" {
  metadata {
    name      = "${var.prefix}-ghostdb"
    namespace = kubernetes_namespace.ghostcms.metadata[0].name
  }

  subset {
    address {
      ip = var.db_ip
    }

    port {
      port = 3306
    }
  }
}

resource "kubernetes_service" "ghostdb" {
  metadata {
    name      = "${var.prefix}-ghostdb"
    namespace = kubernetes_namespace.ghostcms.metadata[0].name
  }

  spec {
    type = "ClusterIP"
    port {
      port        = 3306
      target_port = 3306
    }
  }
}

resource "kubernetes_secret" "ghostcmsdb_secret" {
  metadata {
    name      = "ghostcmsdb-secret"
    namespace = kubernetes_namespace.ghostcms.metadata[0].name
  }

  data = {
    username = google_sql_user.ghostcms.name
    password = google_sql_user.ghostcms.password
  }
}

resource "kubernetes_secret" "ghostcmsmail_secret" {
  metadata {
    name      = "ghostcmsmail-secret"
    namespace = kubernetes_namespace.ghostcms.metadata[0].name
  }

  data = {
    password = var.mail_password
  }
}

resource "kubernetes_service" "ghostcms" {
  metadata {
    name      = "${var.prefix}-ghostcms"
    namespace = kubernetes_namespace.ghostcms.metadata[0].name
    annotations = {
      "cloud.google.com/neg"                = "{\"ingress\": true}"
      "cloud.google.com/load-balancer-type" = "Internal"
    }
  }

  spec {
    selector = {
      app           = "ghostcms"
      ghostsitename = var.prefix
    }

    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress" "ghostcms" {
  metadata {
    name        = "${var.prefix}-ghostcms"
    namespace   = kubernetes_namespace.ghostcms.metadata[0].name
    annotations = var.ingress_annotations
  }

  spec {
    rule {
      host = replace(replace(var.ghost_envvars.url, "https://", ""), "http://", "")
      http {
        path {
          backend {
            service_name = kubernetes_service.ghostcms.metadata[0].name
            service_port = "http"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_account" "ghostcms_serviceaccount" {
  metadata {
    name      = "${var.prefix}-ghostcms"
    namespace = kubernetes_namespace.ghostcms.metadata[0].name

    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.ghostcms_content.email
    }
  }
}
