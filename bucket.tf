resource "google_service_account_key" "ghostcms_content_key" {
  service_account_id = google_service_account.ghostcms_content.name
}

resource "google_storage_bucket_iam_member" "ghostcms_content_iam" {
  bucket = google_storage_bucket.ghostcms_content.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.ghostcms_content.email}"
}

resource "google_storage_bucket_iam_member" "ghostcms_public_iam" {
  bucket = google_storage_bucket.ghostcms_content.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "kubernetes_secret" "ghostcms_content_key" {
  metadata {
    name      = "${var.prefix}-ghostcms-content-key"
    namespace = kubernetes_namespace.ghostcms.metadata[0].name
  }

  data = {
    "key.json" = base64decode(google_service_account_key.ghostcms_content_key.private_key)
  }
}

resource "google_storage_bucket" "ghostcms_content" {
  name = "${var.prefix}-ghostcms-content"

  storage_class = "REGIONAL"
  location      = var.region

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}