data "azurerm_client_config" "current" {}

resource "random_id" "key_vault" {
  byte_length = 4
}

locals {
  vaultName = "${var.vaultPrefix}${lower(random_id.key_vault.hex)}" 
}

resource "azurerm_key_vault" "etcd_key_vault" {
  name                        = local.vaultName
  location                    = var.location
  resource_group_name         = var.resourceGroupName
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "SetRotationPolicy", "GetRotationPolicy"
    ]

    secret_permissions = [
    "Get", "Set", "List", "Delete"
    ]

    storage_permissions = [
      "Get", "Set", "List", "Delete", "RegenerateKey"
    ]
  }
}

resource "azurerm_key_vault_key" "etcd_generated_key" {
  name         = "etcd-generated-key"
  key_vault_id = azurerm_key_vault.etcd_key_vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}