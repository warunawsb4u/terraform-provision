terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote backend — values injected at pipeline init time via -backend-config
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
