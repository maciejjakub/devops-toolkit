data "azurerm_resource_group" "main" {
  # kodekloud creates new resource group with random name for each lab, 
  # remember to update it after each lab reset before running terraform apply
  name = "kml_rg_main-9fe5180a251042c7"
}

resource "azurerm_kubernetes_cluster" "main" {
  name                      = "lab-aks"
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name
  dns_prefix                = "lab-aks"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = azurerm_subnet.main.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
  }
}
