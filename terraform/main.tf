provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0dba2cb6798deb6d8"  # Example Ubuntu 22.04 LTS AMI in us-east-1
  instance_type = "t3.large"

  tags = {
    Name = "flask-ml-app-server"
  }
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "ml-app-static-uploads"
}



  tags = {
    Name        = "flask-ml-artifacts"
    Environment = "dev"
  }
}

provider "kubernetes" {
  config_path = kubeconfig_path = "/home/ubuntu/.kube/config"
}

resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = var.k8s_namespace
  }
}

resource "kubernetes_deployment" "flask_app" {
  metadata {
    name      = "flask-ml-app"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
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
          image = var.docker_image
          name  = "flask-ml-container"

          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask_service" {
  metadata {
    name      = "flask-ml-service"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "flask-ml-app"
    }

    port {
      port        = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}
