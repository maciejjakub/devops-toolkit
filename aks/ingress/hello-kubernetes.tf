resource "helm_release" "hello_kubernetes" {
  name       = "hello-kubernetes"
  chart      = "${path.module}/../charts/hello-kubernetes"
  namespace  = "hello"

  depends_on = [kubernetes_manifest.istio_gateway]

  create_namespace = true

  values = [
    file("${path.module}/../charts/hello-kubernetes/values.yaml")
  ]
}

resource "kubernetes_manifest" "hello_virtual_service" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "hello-virtual-service"
      namespace = "hello"
    }
    spec = {
      hosts = ["*"]
      gateways = ["ingress/gateway"]
      http = [
        {
          route = [
            {
              destination = {
                host = "hello-kubernetes-hello-kubernetes.hello.svc.cluster.local"
                port = {
                  number = 80
                }
              }
            }
          ]
        }
      ]
    }
  }
}