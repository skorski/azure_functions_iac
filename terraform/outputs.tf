output "function_app_name" {
  value = azurerm_function_app.functions.name
  description = "Final function app name"
}

output "function_app_default_hostname" {
  value = azurerm_function_app.functions.default_hostname
  description = "Deployed function app hostname"
}