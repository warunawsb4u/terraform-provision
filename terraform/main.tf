terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0"
    }
  }

  # Azure remote backend: stores state safely in Azure Blob Storage
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

# 1. Resource Group (Zero Cost)
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Activity    = "Activity-02"
  }
}

# 2. Azure Service Plan (F1 Free Tier = $0.00 / Month)
resource "azurerm_service_plan" "asp" {
  name                = "${var.app_name}-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1" # Free Tier!

  tags = {
    Environment = "Dev"
    CostCenter  = "FreeTier"
  }
}

# 3. Linux Web App (.NET 8 runtime on Free Tier)
resource "azurerm_linux_web_app" "webapp" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    always_on = false # Must be false on F1 Free Tier
  }

  tags = {
    Environment = "Dev"
  }
}
