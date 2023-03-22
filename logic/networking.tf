# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.71.0"
    }
  }
}
provider "azurerm" {
 
  features {}
}

locals {
  location_formatted =replace(lower(var.location)," ","")
  naming_convention = "${var.environment}-${var.service}-${local.location_formatted}"
}
# Create a resource group
resource "azurerm_resource_group" "resource_group" {
  name     = "${local.naming_convention}-rg" 
  location = var.location
  
}