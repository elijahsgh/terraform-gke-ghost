resource "kubernetes_stateful_set" "ghostcms" {
  metadata {
    name      = "${var.prefix}-ghostcms"
    namespace = kubernetes_namespace.ghostcms.metadata[0].name
    labels = {
      app           = "ghostcms"
      ghostsitename = var.prefix
    }
  }

  spec {
    service_name = kubernetes_service.ghostcms.metadata[0].name

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 0
      }
    }
    selector {
      match_labels = {
        app           = "ghostcms"
        ghostsitename = var.prefix
      }
    }

    template {
      metadata {
        labels = {
          app           = "ghostcms"
          ghostsitename = var.prefix
        }
      }
      spec {
        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.ghostcms_serviceaccount.metadata[0].name

        volume {
          name = "ghostcontent"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ghostcms.metadata[0].name
          }
        }

        volume {
          name = "ghostcontent-key"
          secret {
            secret_name = kubernetes_secret.ghostcms_content_key.metadata[0].name
            items {
              key  = "key.json"
              path = "key.json"
            }
          }
        }

        init_container {
          name  = "copycontent"
          image = var.init_container_image != "" ? var.init_container_image : var.ghostimage
          command = [
            "sh", "-c", "cp -farv /var/lib/ghost/content.orig/. /var/lib/ghost/content || true; chown -R node: /var/lib/ghost/content;"
          ]

          security_context {
            run_as_user = 0
          }

          volume_mount {
            name       = "ghostcontent"
            mount_path = "/var/lib/ghost/content"
          }
        }

        container {
          name  = "ghostcms"
          image = var.ghostimage

          env {
            name = "database__connection__host"
            #            value = var.db_ip
            value = kubernetes_endpoints.ghostdb.metadata[0].name
          }

          env {
            name = "database__connection__user"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.ghostcmsdb_secret.metadata[0].name
                key  = "username"
              }
            }

          }

          env {
            name = "database__connection__password"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.ghostcmsdb_secret.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name  = "database__connection__database"
            value = google_sql_database.ghostcms.name
          }

          env {
            name = "mail__options__auth__pass"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.ghostcmsmail_secret.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name  = "storage__gcloud__bucket"
            value = google_storage_bucket.ghostcms_content.name
          }

          dynamic "env" {
            for_each = var.ghost_envvars
            content {
              name  = env.key
              value = env.value
            }
          }

          port {
            name           = "http"
            container_port = 2368
          }

          volume_mount {
            name       = "ghostcontent"
            mount_path = "/var/lib/ghost/content"
          }

          volume_mount {
            name       = "ghostcontent-key"
            mount_path = "/var/run/secrets/bucket"
          }

          liveness_probe {
            http_get {
              port = 2368
              path = "/"
              http_header {
                name  = "Host"
                value = replace(replace(var.ghost_envvars.url, "https://", ""), "http://", "")
              }

              http_header {
                name  = "X-Forwarded-Proto"
                value = regex("^http[s]?", var.ghost_envvars.url)
              }
            }

            initial_delay_seconds = 10
            period_seconds        = 5
            failure_threshold     = 3
            timeout_seconds       = 2
          }
        }
      }
    }
  }
}
