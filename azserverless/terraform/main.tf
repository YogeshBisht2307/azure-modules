terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.90.0"
    }
  }
}

provider "tls" {
  proxy {
    from_env = true
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

resource "azurerm_resource_group" "backend_resources" {
  name     = "${var.resource_prefix}-backend-resource-group"
  location = var.resource_location
}

data "azurerm_storage_account" "primary_storage_account" {
  name                = var.storage_account_name
  resource_group_name = var.portal_resource_group
}