resource "random_password" "sqlpass" {
  length  = 20
  special = true
}

resource "google_sql_database" "db" {
  name     = "${var.prefix}-ghostcms"
  instance = var.db_instance
  charset  = "utf8mb4"
}

resource "google_sql_user" "sqluser" {
  name     = "${var.prefix}-ghostcms"
  instance = var.db_instance
  password = var.db_password != null ? var.db_password : random_password.sqlpass.result
}

resource "google_service_account" "content" {
  account_id   = "${var.prefix}-content"
  display_name = "${var.prefix} Ghost CMS Content"
}

output "db_password" {
  value = google_sql_user.sqluser.password
}