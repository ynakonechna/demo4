data "aws_secretsmanager_secret_version" "dd" {
  secret_id = "dd-creds"
}

locals {
  dd_secrets = jsondecode(data.aws_secretsmanager_secret_version.dd.secret_string)
}

resource "helm_release" "alb_controller" {
  name       = "datadog"
  chart      = "datadog"
  repository = "https://helm.datadoghq.com"
  version    = "3.43.1"

  set {
    name  = "datadog.clusterName"
    value = var.cluster_name
  }

  # set {
  #   name = "datadog.appKey"
  #   value = ""
  # }

  set {
    name = "datadog.apiKey"
    value = local.dd_secrets["api-key"]
  }

  set {
    name  = "datadog.logs.enabled"
    value = true
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = true
  }

  set {
    name  = "datadog.site"
    value = "us5.datadoghq.com"
  }

}