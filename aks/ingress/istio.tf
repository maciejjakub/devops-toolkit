resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  version    = local.istio_version

  create_namespace = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  version    = local.istio_version

  # Wait for CRDs to be ready before installing Istiod
  depends_on = [helm_release.istio_base]

  values = [
    file("${path.module}/values/istiod.yaml")
  ]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = "ingress"
  version    = local.istio_version

  depends_on = [helm_release.istiod]

  create_namespace = true

  values = [
    file("${path.module}/values/gateway.yaml")
  ]
}

resource "kubernetes_manifest" "istio_gateway" {
  depends_on = [helm_release.istio_ingress]
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "Gateway"
    metadata = {
      name      = "fileserver-gateway"
      namespace = "ingress"
    }
    spec = {
      selector = {
        istio = "gateway"
      }
      servers = [
        {
          port = {
            number   = 80
            name     = "http"
            protocol = "HTTP"
          }
          hosts = ["*"]
        }
      ]
    }
  }
}