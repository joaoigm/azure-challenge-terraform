terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.0.1"
    }
    azurerm = {
    }
  }
}

provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "main" {
  name = "azure-challenge"
  location = var.location
}