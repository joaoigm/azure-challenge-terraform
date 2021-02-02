resource "azurerm_cosmosdb_account" "main" {
  
  name                = "${var.project_name}-cosmosdb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = true
  public_network_access_enabled = false
  is_virtual_network_filter_enabled = true
  virtual_network_rule {
    id = azurerm_subnet.private[1].id
  }
  
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

  lifecycle {
    ignore_changes = [ capabilities ]
  }
}

resource "azurerm_postgresql_server" "main" {
  
  name                = "${var.project_name}postgresql"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  administrator_login          = "postgres"
  administrator_login_password = random_password.postgres_pwd.result

  sku_name   = "GP_Gen5_2"
  version    = "9.6"
  storage_mb = 10240

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

}


resource "random_password" "postgres_pwd" {
  length = 12
  special = false
}
