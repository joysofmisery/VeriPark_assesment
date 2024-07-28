#Assign Variables values for ProdVnet creation
#**************************************************************************************************************************************
vnetaddress       = "10.0.0.0/24"
appsubnetaddress = "10.0.0.0/26"
middlesubnetaddress = "10.0.0.64/26"
dbsubnetaddress   = "10.0.0.128/26"
prodresourcegroup = "Acme-Prod"
clientname        = "Acme"
location = "West Europe"

dns = {
  "dns1" = "privatelink.azurewebsites.net"
  "dns2" = "privatelink.database.windows.net"
}

