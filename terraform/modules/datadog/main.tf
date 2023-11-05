resource "helm_release" "alb_controller" {
  name       = "datadog"
  chart      = "datadog"
  repository = "https://helm.datadoghq.com"
  version    = "3.43.1"

  set {
    name  = "datadog.clusterName"
    value = var.cluster_name
  }

  set {
    name = "datadog.appKey"
    value = ""
  }

  set {
    name = "datadog.apiKey"
    value = ""
  }

  set {
    name  = "datadog.logs.enabled"
    value = true
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = true
  }

}