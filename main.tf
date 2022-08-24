resource "azurerm_resource_group" "hub" {
  name     = "rg-${local.resource_suffixes.hub}"
  location = var.hub_location

  tags = {
    role = "hub"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_resource_group" "spoke" {
  name     = "rg-${local.resource_suffixes.spoke}"
  location = var.spoke_location

  tags = {
    role = "spoke"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
