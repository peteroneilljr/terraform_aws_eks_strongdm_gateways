
resource "kubernetes_service" "sdm_gateway_hostname" {
  metadata {
    name = var.sdm_gateway_name
    labels = {
      app = var.sdm_app_name
    }
  }
  spec {
    selector = {
      app = var.sdm_app_name
    }
    port {
      port = var.sdm_port
    }

    type = "LoadBalancer"
  }
}
resource "sdm_node" "gateway" {
  gateway {
    name           = var.sdm_gateway_name
    listen_address = "${coalesce(kubernetes_service.sdm_gateway_hostname.load_balancer_ingress.0.hostname, kubernetes_service.sdm_gateway_hostname.load_balancer_ingress.0.ip)}:${var.sdm_port}"
  }
}
resource "kubernetes_secret" "sdm_gateway_token" {
  metadata {
    name = "${var.sdm_gateway_name}-token"
  }
  type = "Opaque"
  data = {
    token = sdm_node.gateway.gateway.0.token
  }
}
resource "kubernetes_deployment" "sdm_gateway" {
  metadata {
    name = var.sdm_gateway_name
    labels = {
      app = var.sdm_app_name
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.sdm_app_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.sdm_app_name
        }
      }
      spec {
        container {
          image             = "quay.io/sdmrepo/relay:latest"
          image_pull_policy = "Always"
          name              = var.sdm_app_name
          env {
            name  = "SDM_ORCHESTRATOR_PROBES"
            value = ":9090"
          }
          env {
            name = "SDM_RELAY_TOKEN"
            value_from {
              secret_key_ref {
                key  = "token"
                name = kubernetes_secret.sdm_gateway_token.metadata.0.name
              }
            }
          }
          liveness_probe {
            http_get {
              path = "/liveness"
              port = 9090
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}
