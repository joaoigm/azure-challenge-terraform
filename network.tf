resource "azurerm_network_security_group" "main" {
  name                = "vnet-sg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_ddos_protection_plan" "main" {
  name                = "vnet-ddos"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_virtual_network" "main" {
  name = "challenge-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  address_space = [ "10.16.0.0/16" ]

  ddos_protection_plan {
    enable = true
    id = azurerm_network_ddos_protection_plan.main.id
  }

}

resource "azurerm_subnet" "public" {
  name = "public"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [ "10.16.10.0/24" ]
}

resource "azurerm_subnet" "private" {
  count = 2
  name = "private-${count.index}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [ "10.16.1${count.index + 1}.0/24" ]
}