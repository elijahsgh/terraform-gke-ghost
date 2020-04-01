provider google {
  project = var.project
  zone    = var.zone
  version = "~> 3.13"
}

provider google-beta {
  project = var.project
  zone    = var.zone
  version = "~> 3.13"
}

provider kubernetes {
  version = "~>1.11"
}

resource "google_sql_database" "ghostcms" {
  name     = "${var.prefix}-ghostcms"
  instance = var.db_instance
  charset  = "utf8mb4"
}

resource "google_sql_user" "ghostcms" {
  name     = "${var.prefix}-ghostcms"
  instance = var.db_instance
  password = var.db_password
}

resource "google_service_account" "ghostcms_content" {
  account_id   = "${var.prefix}-ghostcms-content"
  display_name = "${var.prefix} GhostCMS Content"
}