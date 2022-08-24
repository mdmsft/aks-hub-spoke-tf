resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${local.resource_suffixes.hub}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.hub_address_space]
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${local.resource_suffixes.spoke}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = [var.spoke_address_space]
}

resource "azurerm_virtual_network_peering" "hub" {
  name                         = "peer-${azurerm_virtual_network.spoke.name}"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "spoke" {
  name                         = "peer-${azurerm_virtual_network.hub.name}"
  resource_group_name          = azurerm_resource_group.spoke.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  allow_virtual_network_access = true
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  address_prefixes     = [cidrsubnet(var.hub_address_space, 2, 0)]
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  address_prefixes     = [cidrsubnet(var.hub_address_space, 2, 1)]
  virtual_network_name = azurerm_virtual_network.hub.name
  resource_group_name  = azurerm_resource_group.hub.name
}

resource "azurerm_subnet" "jumphost" {
  name                 = "snet-vm"
  address_prefixes     = [cidrsubnet(var.hub_address_space, 2, 2)]
  virtual_network_name = azurerm_virtual_network.hub.name
  resource_group_name  = azurerm_resource_group.hub.name
}

resource "azurerm_subnet" "endpoint" {
  name                                      = "snet-pe"
  address_prefixes                          = [cidrsubnet(var.hub_address_space, 2, 3)]
  virtual_network_name                      = azurerm_virtual_network.hub.name
  resource_group_name                       = azurerm_resource_group.hub.name
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_subnet" "cluster" {
  name                 = "snet-aks"
  address_prefixes     = [cidrsubnet(var.spoke_address_space, 0, 0)]
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
}

resource "azurerm_network_security_group" "bastion" {
  name                = "nsg-${local.resource_suffixes.hub}-bas"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  security_rule {
    name                       = "AllowInternetInbound"
    priority                   = 100
    protocol                   = "Tcp"
    access                     = "Allow"
    direction                  = "Inbound"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "443"
  }

  security_rule {
    name                       = "AllowControlPlaneInbound"
    priority                   = 200
    protocol                   = "Tcp"
    access                     = "Allow"
    direction                  = "Inbound"
    source_address_prefix      = "GatewayManager"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "443"
  }

  security_rule {
    name                       = "AllowHealthProbesInbound"
    priority                   = 300
    protocol                   = "Tcp"
    access                     = "Allow"
    direction                  = "Inbound"
    source_address_prefix      = "AzureLoadBalancer"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "443"
  }

  security_rule {
    name                       = "AllowDataPlaneInbound"
    priority                   = 400
    protocol                   = "Tcp"
    access                     = "Allow"
    direction                  = "Inbound"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_ranges    = ["8080", "5701"]
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 1000
    protocol                   = "*"
    access                     = "Deny"
    direction                  = "Inbound"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "AllowSshRdpOutbound"
    priority                   = 100
    protocol                   = "Tcp"
    access                     = "Allow"
    direction                  = "Outbound"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges    = ["22", "3389"]
  }

  security_rule {
    name                       = "AllowCloudOutbound"
    priority                   = 200
    protocol                   = "Tcp"
    access                     = "Allow"
    direction                  = "Outbound"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "AzureCloud"
    destination_port_range     = "443"
  }

  security_rule {
    name                       = "AllowDataPlaneOutbound"
    priority                   = 300
    protocol                   = "Tcp"
    access                     = "Allow"
    direction                  = "Outbound"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges    = ["8080", "5701"]
  }

  security_rule {
    name                       = "AllowSessionCertificateValidationOutbound"
    priority                   = 400
    protocol                   = "Tcp"
    access                     = "Allow"
    direction                  = "Outbound"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "Internet"
    destination_port_range     = "80"
  }

  security_rule {
    name                       = "DenyAllOutbound"
    priority                   = 1000
    protocol                   = "*"
    access                     = "Deny"
    direction                  = "Outbound"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
}

resource "azurerm_network_security_group" "jumphost" {
  name                = "nsg-${local.resource_suffixes.hub}-vm"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
}

resource "azurerm_network_security_group" "endpoint" {
  name                = "nsg-${local.resource_suffixes.spoke}-pe"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
}

resource "azurerm_network_security_group" "cluster" {
  name                = "nsg-${local.resource_suffixes.spoke}-aks"
  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  network_security_group_id = azurerm_network_security_group.bastion.id
  subnet_id                 = azurerm_subnet.bastion.id
}

resource "azurerm_subnet_network_security_group_association" "cluster" {
  subnet_id                 = azurerm_subnet.cluster.id
  network_security_group_id = azurerm_network_security_group.cluster.id
}

resource "azurerm_subnet_network_security_group_association" "jumphost" {
  subnet_id                 = azurerm_subnet.jumphost.id
  network_security_group_id = azurerm_network_security_group.jumphost.id
}

resource "azurerm_subnet_network_security_group_association" "endpoint" {
  subnet_id                 = azurerm_subnet.endpoint.id
  network_security_group_id = azurerm_network_security_group.endpoint.id
}

resource "azurerm_route_table" "main" {
  name                = "rt-${local.resource_suffixes.spoke}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
}

resource "azurerm_route" "internet_firewall" {
  name                   = "net-afw"
  resource_group_name    = azurerm_resource_group.spoke.name
  route_table_name       = azurerm_route_table.main.name
  address_prefix         = "0.0.0.0/0"
  next_hop_in_ip_address = azurerm_firewall.main.ip_configuration.0.private_ip_address
  next_hop_type          = "VirtualAppliance"
}

resource "azurerm_route" "firewall_internet" {
  name                = "afw-www"
  resource_group_name = azurerm_resource_group.spoke.name
  route_table_name    = azurerm_route_table.main.name
  address_prefix      = "${azurerm_public_ip.firewall.ip_address}/32"
  next_hop_type       = "Internet"
}

resource "azurerm_subnet_route_table_association" "main" {
  subnet_id      = azurerm_subnet.cluster.id
  route_table_id = azurerm_route_table.main.id
}

resource "azurerm_public_ip_prefix" "main" {
  name                = "ippre-${local.resource_suffixes.hub}"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  prefix_length       = 31
  sku                 = "Standard"
}
