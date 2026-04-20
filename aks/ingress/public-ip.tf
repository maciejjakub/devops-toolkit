data "azurerm_resource_group" "main" {
  # kodekloud creates new resource group with random name for each lab, 
  # remember to update it after each lab reset before running terraform apply
  name = "kml_rg_main-9fe5180a251042c7"
}

resource "azurerm_public_ip" "static" {
  name                = "static-ip"
  resource_group_name = "MC_kml_rg_main-9fe5180a251042c7_lab-aks_eastus"
  location            = data.azurerm_resource_group.main.location
  sku                 = "Standard"
  allocation_method   = "Static"
}