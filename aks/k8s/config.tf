locals {
  tags = {
    owner       = "maciejmiliszewski@gmail.com"
    environment = "lab"
  }
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "a2b28c85-1948-4263-90ca-bade2bac4df4"

  # azurerm registers all Azure providers by default, which can only work if the identity
  # that runs terraform has Contributor on the subcription level. Disable this behaviour 
  # to let it create resources in a restricted environment like KodeKloud Azure playground
  resource_provider_registrations = "none"
}