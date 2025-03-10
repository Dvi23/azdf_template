variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
}

variable "data_factory_name" {
  description = "Name of the Azure Data Factory"
  type        = string
}

variable "synapse_workspace_name" {
  description = "Name of the Synapse Workspace"
  type        = string
}

variable "sql_pool_name" {
  description = "Name of the SQL Pool"
  type        = string
}

variable "spark_pool_name" {
  description = "Name of the Spark Pool"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Storage Account"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "vnet_id" {
  description = "Virtual Network ID for private endpoint"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}