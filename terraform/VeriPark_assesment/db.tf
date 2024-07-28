
resource "azurerm_mssql_server" "sqlserver" {
  name                         = "rg-sqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = azurerm_key_vault_secret.admin_username.value
  administrator_login_password = azurerm_key_vault_secret.admin_password.value
    
#   azuread_administrator {
#     login_username = "AzureAD Admin"
#     object_id      = "00000000-0000-0000-0000-000000000000"
#   }

  tags = var.tags
}

resource "azurerm_mssql_database" "sqldb" {
  name           = "rg-db"
  server_id      = azurerm_mssql_server.sqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "S0"
  zone_redundant = true

  tags = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.sqlvault.id]
  }

  transparent_data_encryption_key_vault_key_id = azurerm_key_vault_key.tde-key.id

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
    ignore_changes = [transparent_data_encryption_key_vault_key_id]
  }
}
data "azurerm_private_dns_zone" "dbprivatednszone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_private_endpoint" "dbpe" {
  name                = "${azurerm_mssql_server.sqlserver.name}-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.appservicesubnet.id
  
   private_dns_zone_group {
    name                 = "privatednsappservice"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dbprivatednszone.id]
  }

  private_service_connection {
    name                           = "${azurerm_mssql_server.sqlserver.name}-peconnection"
    private_connection_resource_id = azurerm_mssql_server.sqlserver.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}