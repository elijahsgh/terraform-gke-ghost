output "google_storage_bucket_name" {
  value = google_storage_bucket.ghostcms_content.name
}

output "service_neg_name" {
  value = jsondecode(kubernetes_service.ghostcms.metadata[0].annotations["cloud.google.com/neg"])["exposed_ports"]["80"]["name"]
}