### VeriPark Assessment

#### The solution consists of the following resources:

    1.Virtual Network (VNet) in the West Europe Region
      -  Subnets: Three subnets, each for a different tier.
      -  Network Policy: Private endpoints for all subnets are set to "Route Tables and NSG".
      -  DB Subnet: Contains one Network Security Group (NSG) which restricts access only from the middleware subnet.

    2. Web API Application (Backend for Frontend)
       - This application is accessible publicly.
       - Public inbound access needs to be enabled manually from the Azure portal.
       - Note: I have not used the azurerm_windows_web_app resource, so enabling public access through Terraform was not possible.

    3. Web API Application (Middleware)
        This application is accessible internally within the virtual network.

    4. Azure SQL Database
       - The database is encrypted using a Customer Managed Key (CMK) through the Transparent Data Encryption (TDE) feature.
       - The SQL Server has a private endpoint and is accessible only from the middleware network.