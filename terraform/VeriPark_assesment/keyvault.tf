data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "sqlvault" {
  name                = "sql-vault"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.clientname}-kv"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
    key_permissions = ["Get", "List", "Create", "Delete", "Update", "Recover", "Purge", "GetRotationPolicy"]
  }


    access_policy {
      tenant_id = azurerm_user_assigned_identity.sqlvault.tenant_id
      object_id = azurerm_user_assigned_identity.sqlvault.principal_id

      key_permissions = ["Get", "WrapKey", "UnwrapKey"]
    }
}

resource "azurerm_key_vault_key" "tde-key" {
  depends_on   = [azurerm_key_vault.kv]
  name         = "tde-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["unwrapKey", "wrapKey"]
}
resource "azurerm_key_vault_secret" "admin_username" {
  depends_on   = [azurerm_key_vault.kv]
  name         = "admin-username"
  value        = "sqladmin"
  key_vault_id = azurerm_key_vault.kv.id

}
resource "azurerm_key_vault_secret" "admin_password" {
  depends_on   = [azurerm_key_vault.kv]
  name         = "admin-password"
  value        = "toughpassword"
  key_vault_id = azurerm_key_vault.kv.id
}
