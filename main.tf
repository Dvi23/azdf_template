provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
}

# Data Factory
resource "azurerm_data_factory" "adf" {
  name                = var.data_factory_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Data Factory Private Endpoint
resource "azurerm_private_endpoint" "adf_pe" {
  name                = "${var.data_factory_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.data_factory_name}-connection"
    private_connection_resource_id = azurerm_data_factory.adf.id
    subresource_names              = ["datafactory"]
    is_manual_connection           = false
  }
}

# Synapse Workspace
resource "azurerm_synapse_workspace" "synapse" {
  name                                 = var.synapse_workspace_name
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_account.storage.primary_dfs_endpoint
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@rd2Gu3ssP@ssw0rd!"
}

# Synapse SQL Pool
resource "azurerm_synapse_sql_pool" "sql_pool" {
  name                 = var.sql_pool_name
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  sku_name             = "DW100c"
  create_mode          = "Default"
}

# Synapse Spark Pool
resource "azurerm_synapse_spark_pool" "spark_pool" {
  name                 = var.spark_pool_name
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  node_size_family     = "MemoryOptimized"
  node_size            = "Small"
  spark_version        = "3.2"

  auto_scale {
    enabled      = true
    min_node_count = 3
    max_node_count = 10
  }

  auto_pause {
    enabled = true
    delay_in_minutes = 15
  }
}

# Get current client config for tenant_id
data "azurerm_client_config" "current" {}