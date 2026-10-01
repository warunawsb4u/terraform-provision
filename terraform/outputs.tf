output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "web_app_name" {
  description = "The name of the web app"
  value       = azurerm_linux_web_app.webapp.name
}

output "web_app_url" {
  description = "Default public URL of the deployed Web App"
  value       = "https://${azurerm_linux_web_app.webapp.default_hostname}"
}
