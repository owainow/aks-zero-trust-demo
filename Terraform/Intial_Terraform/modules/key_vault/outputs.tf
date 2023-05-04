output "key_vault_id" {
  value = resource.azurerm_key_vault.etcd_key_vault.id
}
output "key_vault_key"{
  value = resource.azurerm_key_vault_key.etcd_generated_key.id
}

output "key_vault_name"{
  value = resource.azurerm_key_vault.etcd_key_vault.name
}
