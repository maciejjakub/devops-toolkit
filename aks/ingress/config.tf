locals {
  istio_version = "1.29.2"  # latest GA in April 2026
}

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "lab-aks"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "lab-aks" 
}
