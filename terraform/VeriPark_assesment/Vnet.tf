resource "azurerm_resource_group" "rg" {
  name     = var.prodresourcegroup
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.clientname}_VNET"
  address_space       = [var.vnetaddress]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "appservicesubnet" {
  name                 = "${var.clientname}_appSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.appsubnetaddress]
}
resource "azurerm_subnet" "middlesubnet" {
  name                 = "${var.clientname}_middleSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.middlesubnetaddress]
}
resource "azurerm_subnet" "dbsubnet" {
  name                 = "${var.clientname}_dbSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.dbsubnetaddress]
}

# NSG for DB Subnet
resource "azurerm_network_security_group" "nsgdb" {
  name                = "${var.clientname}_NSG-DB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  security_rule {
    name                       = "AllowMiddle"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = ["10.0.0.64/26"]
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllBlock"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
# NSG For the App&Web Subnet
resource "azurerm_network_security_group" "nsgprodapp" {
  name                = "${var.clientname}_NSG-PRODAPP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}
resource "azurerm_subnet_network_security_group_association" "prodnsglink" {
  subnet_id                 = azurerm_subnet.appservicesubnet.id
  network_security_group_id = azurerm_network_security_group.nsgprodapp.id
}
resource "azurerm_subnet_network_security_group_association" "dbnsglink" {
  subnet_id                 = azurerm_subnet.dbsubnet.id
  network_security_group_id = azurerm_network_security_group.nsgdb.id
}

resource "azurerm_private_dns_zone" "dnszone" {
  for_each            = var.dns
  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnslink" {
  for_each              = azurerm_private_dns_zone.dnszone
  name                  = "link1"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnszone[each.key].name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  # registration_enabled = true
}

