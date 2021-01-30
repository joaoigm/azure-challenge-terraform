provider "azurerm" { 
    features {
      
    }
}

resource "azurerm_resource_group" "main" {
  name = "azure-challenge"
  location = var.location
}