resource "kubernetes_namespace" "sdm_gateway" {
  count = var.gateway_count > 0 ? 1:0
  metadata {
    name = var.namespace
    labels = {
      app = var.sdm_app_name
    }
  }
}

resource "kubernetes_service" "sdm_gateway" {
  count = var.gateway_count

  metadata {
    name      = "${var.sdm_gateway_name}-${count.index}"
    namespace = var.namespace
    labels = {
      app = var.sdm_app_name
    }
  }
  spec {
    selector = {
      app = var.sdm_app_name
    }
    port {
      port = var.expose_on_node_port ? "500${count.index}" : var.sdm_port
      protocol = "TCP"
      target_port = var.sdm_port

    }
    type = var.expose_on_node_port ? "NodePort" : "LoadBalancer"
  }
  depends_on = [
    kubernetes_namespace.sdm_gateway
  ]
}

resource "sdm_node" "gateway" {
  count = var.gateway_count

  gateway {
    name           = "${var.sdm_gateway_name}-${count.index}"
    listen_address = var.expose_on_node_port ? "${kubernetes_service.sdm_gateway[count.index].spec.0.cluster_ip}:500${count.index}" : "${coalesce(kubernetes_service.sdm_gateway[count.index].load_balancer_ingress.0.hostname, kubernetes_service.sdm_gateway[count.index].load_balancer_ingress.0.ip)}:${var.sdm_port}"
  }
}
resource "kubernetes_secret" "sdm_gateway" {
  count = var.gateway_count

  metadata {
    name      = "${var.sdm_gateway_name}-${count.index}"
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    token = sdm_node.gateway[count.index].gateway.0.token
  }
}
resource "kubernetes_deployment" "sdm_gateway" {
  count = var.gateway_count

  metadata {
    name      = "${var.sdm_gateway_name}-${count.index}"
    namespace = var.namespace
    labels = {
      app = var.sdm_app_name
    }
  }
  spec {
    replicas = 1 # Required to be 1

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
          resources {
            requests {
              cpu    = var.dev_mode ? "0m" : "2000m"
              memory = var.dev_mode ? "0Mi" : "4000Mi"
            }
          }
          env {
            name  = "SDM_ORCHESTRATOR_PROBES"
            value = ":9090"
          }
          env {
            name = "SDM_RELAY_TOKEN"
            value_from {
              secret_key_ref {
                key  = "token"
                name = kubernetes_secret.sdm_gateway[count.index].metadata.0.name
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


