resource "azurerm_virtual_network" "main" {
  name                = "aks-vnet"
  location            = "eastus"
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = ["192.168.0.0/24"]
  tags                = local.tags
}

resource "azurerm_subnet" "main" {
  name                 = "aks-vnet-subnet"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["192.168.0.0/24"]
}
