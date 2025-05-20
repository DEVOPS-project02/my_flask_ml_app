provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "ml_app_namespace" {
  metadata {
    name = "ml-app-namespace"
  }
}

resource "kubernetes_deployment" "flask_ml_app" {
  metadata {
    name      = "flask-ml-app"
    namespace = kubernetes_namespace.ml_app_namespace.metadata[0].name
    labels = {
      app = "flask-ml-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "flask-ml-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "flask-ml-app"
        }
      }

      spec {
        container {
          name  = "flask-ml-container"
          image = "balesunilkumar/my-flask-ml-app:1.0"

          port {
            container_port = 5000
          }

          env {
            name  = "FLASK_ENV"
            value = "production"
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 5000
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 5000
            }
            initial_delay_seconds = 15
            period_seconds        = 20
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask_ml_service" {
  metadata {
    name      = "flask-ml-service"
    namespace = kubernetes_namespace.ml_app_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.flask_ml_app.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 5000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}
