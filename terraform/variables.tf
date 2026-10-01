variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-terraform-demo"
}

variable "location" {
  description = "Azure Region for resources"
  type        = string
  default     = "eastus"
}

variable "app_name" {
  description = "Globally unique name for the Azure Web App"
  type        = string
  default     = "waruna-tf-webapp-01" # Must be unique across Azure
}
