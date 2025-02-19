resource "google_compute_disk" "ghostcms" {
  name = "${var.prefix}-ghost-content"
  type = "pd-ssd"
  size = 2

  lifecycle {
    ignore_changes = [
      terraform_labels["goog-gke-volume"],
    ]
  }

}

resource "kubernetes_persistent_volume" "ghostcms" {
  metadata {
    name = "${var.prefix}-ghostpv"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = google_compute_disk.ghostcms.name
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume_claim" "ghostcms" {
  metadata {
    name      = "${var.prefix}ghostpvc"
    namespace = kubernetes_namespace.ghostcms.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    storage_class_name = "standard"
    volume_name        = kubernetes_persistent_volume.ghostcms.metadata.0.name
  }
}
