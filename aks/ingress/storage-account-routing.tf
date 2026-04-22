resource "kubernetes_manifest" "storage_virtual_service" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = "storage-virtual-service"
      namespace = "ingress"
    }
    spec = {
      hosts    = ["*"]
      gateways = ["ingress/fileserver-gateway"]
      http = [
        {
          route = [
            {
              destination = {
                host = "fileservernoconflict.blob.core.windows.net"
                port = {
                  number = 443
                }
              }
              headers = {
                request = {
                  set = {
                    host = "fileservernoconflict.blob.core.windows.net"
                  }
                }
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "blob_service_entry" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "blob-storage"
      namespace = "ingress"
    }
    spec = {
      hosts = ["fileservernoconflict.blob.core.windows.net"]
      ports = [
        {
          number   = 443
          name     = "https"
          protocol = "HTTPS"
        }
      ]
      resolution = "DNS"
      location   = "MESH_EXTERNAL"
    }
  }
}

resource "kubernetes_manifest" "blob_destination_rule" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "DestinationRule"
    metadata = {
      name      = "blob-storage"
      namespace = "ingress"
    }
    spec = {
      host = "fileservernoconflict.blob.core.windows.net"
      trafficPolicy = {
        tls = {
          mode           = "SIMPLE"
          sni            = "fileservernoconflict.blob.core.windows.net"
          caCertificates = "/etc/ssl/certs/ca-certificates.crt"
        }
      }
    }
  }
}