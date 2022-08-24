resource "azurerm_private_dns_zone" "registry" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "registry" {
  name                  = azurerm_virtual_network.spoke.name
  private_dns_zone_name = azurerm_private_dns_zone.registry.name
  resource_group_name   = azurerm_resource_group.hub.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}

resource "azurerm_container_registry" "main" {
  name                   = "cr${replace(local.resource_suffixes.hub, "-", "")}"
  location               = azurerm_resource_group.hub.location
  resource_group_name    = azurerm_resource_group.hub.name
  sku                    = "Premium"
  admin_enabled          = false
  anonymous_pull_enabled = false
}

resource "azurerm_private_endpoint" "registry" {
  name                = "pe-${local.resource_suffixes.hub}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  subnet_id           = azurerm_subnet.endpoint.id

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.registry.name
    private_dns_zone_ids = [azurerm_private_dns_zone.registry.id]
  }

  private_service_connection {
    name                           = azurerm_container_registry.main.name
    is_manual_connection           = false
    subresource_names              = ["registry"]
    private_connection_resource_id = azurerm_container_registry.main.id
  }
}
