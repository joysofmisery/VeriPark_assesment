
resource "azurerm_app_service_plan" "ASP" {
  name                = "${var.clientname}-ASP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Frontend App Service
resource "azurerm_app_service" "Appservice" {
  name                = "${var.clientname}-front"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.ASP.id
  
  site_config {
    dotnet_framework_version = "v4.0"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }
}
data "azurerm_private_dns_zone" "privatednszone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_private_endpoint" "appservicepe" {
  name                = "${azurerm_app_service.Appservice.name}-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.appservicesubnet.id
  
   private_dns_zone_group {
    name                 = "privatednsappservice"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.privatednszone.id]
  }

  private_service_connection {
    name                           = "${azurerm_app_service.Appservice.name}-peconnection"
    private_connection_resource_id = azurerm_app_service.Appservice.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
}

# MiddleWare App service

resource "azurerm_app_service" "Middleservice" {
  name                = "${var.clientname}-middle"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.ASP.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}

resource "azurerm_private_endpoint" "middleservicepe" {
  name                = "${azurerm_app_service.Middleservice.name}-pe"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.middlesubnet.id
  
   private_dns_zone_group {
    name                 = "privatednsappservice"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.privatednszone.id]
  }

  private_service_connection {
    name                           = "${azurerm_app_service.Middleservice.name}-peconnection"
    private_connection_resource_id = azurerm_app_service.Middleservice.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
}