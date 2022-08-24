resource "azurerm_log_analytics_workspace" "hub" {
  name                = "log-${local.resource_suffixes.hub}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  daily_quota_gb      = var.log_analytics_workspace_daily_quota_gb
  retention_in_days   = var.log_analytics_workspace_retention_in_days
}

resource "azurerm_log_analytics_workspace" "spoke" {
  name                = "log-${local.resource_suffixes.spoke}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  daily_quota_gb      = var.log_analytics_workspace_daily_quota_gb
  retention_in_days   = var.log_analytics_workspace_retention_in_days
}