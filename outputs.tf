output "backup_rg" {
  description = "Resource Group, used as backup location"
  value       = var.backups_rg_name
}
output "name_of_storage" {
  description = "storage account name"
  value       = "${local.random_stracc_name}"
}
output "connection_string" {
  value = azurerm_storage_account.aks1_backups.primary_connection_string
  sensitive = true
}

output "access_key" {
  value = azurerm_storage_account.aks1_backups.primary_access_key
  sensitive = true
}