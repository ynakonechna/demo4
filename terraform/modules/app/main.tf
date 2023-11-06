data "aws_secretsmanager_secret_version" "db" {
  secret_id = "db/master-creds"
}

locals {
  db_secrets = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"
    labels = {
      app = "demo4"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "demo4"
      }
    }
    template {
      metadata {
        labels = {
          app = "demo4"
        }
      }
      spec {
        container {
          image = "404405619113.dkr.ecr.eu-north-1.amazonaws.com/app:latest"
          name  = "app"

          env {
            name = "PG_HOST"
            value = local.db_secrets["host"]
          }

          env {
            name = "PG_DATABASE"
            value = local.db_secrets["dbname"]
          }

          env {
            name = "PG_USERNAME"
            value = local.db_secrets["username"]
          }

          env {
            name = "PG_PASSWORD"
            value = local.db_secrets["password"]
          }

          port {
            container_port = 3000
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "app" {
  metadata {
    name = "app"
  }

  spec {
    selector = {
      app = "demo4"
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "NodePort"
  }

  depends_on = [ kubernetes_deployment.app ]
}

resource "kubernetes_ingress_v1" "app" {
  wait_for_load_balancer = true
  metadata {
    name = "app"
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/certificate-arn": var.certificate_arn
      "alb.ingress.kubernetes.io/ssl-redirect" = 443
      "alb.ingress.kubernetes.io/listen-ports": jsonencode([{"HTTP"=80}, {"HTTPS"=443}])
      "alb.ingress.kubernetes.io/subnets": join(", ", var.public_subnet_ids)
    }
  }

  spec {
    ingress_class_name = "alb"
    default_backend {
      service {
        name = "app"
        port {
          number = 3000
        }
      }
    }
    rule {
      host = "app.demo4.yulia1.pp.ua"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.app.metadata[0].name
              port {
                number = 3000
              }
            }
          }
          path = "/*"
        }
      }
    }
  }
}

data "aws_route53_zone" "app" {
  name         = "yulia1.pp.ua"
  private_zone = false
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.app.zone_id
  name    = "app.demo4"
  type    = "CNAME"
  ttl     = 60

  records        = [kubernetes_ingress_v1.app.status.0.load_balancer.0.ingress.0.hostname]
}