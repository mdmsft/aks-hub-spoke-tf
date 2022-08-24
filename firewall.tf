locals {
  firewall_diagnostic_logs = [
    "AzureFirewallApplicationRule",
    "AzureFirewallNetworkRule",
    "AzureFirewallDnsProxy",
    "AZFWNetworkRule",
    "AZFWApplicationRule",
    "AZFWNatRule",
    "AZFWThreatIntel",
    "AZFWIdpsSignature",
    "AZFWDnsQuery",
    "AZFWFqdnResolveFailure",
    "AZFWApplicationRuleAggregation",
    "AZFWNetworkRuleAggregation",
    "AZFWNatRuleAggregation",
  ]
}

resource "azurerm_public_ip" "firewall" {
  name                = "pip-${local.resource_suffixes.hub}-afw"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  allocation_method   = "Static"
  sku                 = "Standard"
  public_ip_prefix_id = azurerm_public_ip_prefix.main.id
}

resource "azurerm_firewall" "main" {
  name                = "afw-${local.resource_suffixes.hub}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  private_ip_ranges   = ["IANAPrivateRanges"]
  firewall_policy_id  = azurerm_firewall_policy.main.id

  ip_configuration {
    name                 = "default"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_firewall_policy" "main" {
  name                     = "afwp-${local.resource_suffixes.hub}"
  location                 = azurerm_resource_group.hub.location
  resource_group_name      = azurerm_resource_group.hub.name
  sku                      = "Standard"
  threat_intelligence_mode = "Alert"

  insights {
    enabled                            = true
    default_log_analytics_workspace_id = azurerm_log_analytics_workspace.hub.id
    retention_in_days                  = var.log_analytics_workspace_retention_in_days
  }

  dns {
    proxy_enabled = true
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "main" {
  name               = "default"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 100

  network_rule_collection {
    name     = "net"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "ntp"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }

    rule {
      name                  = "aks-upd"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureCloud.${var.spoke_location}"]
      destination_ports     = ["1194"]
    }

    rule {
      name                  = "aks-tcp"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureCloud.${var.spoke_location}"]
      destination_ports     = ["9000"]
    }

    rule {
      name             = "azure"
      protocols        = ["TCP"]
      source_addresses = ["*"]
      destination_addresses = [
        "AzureMonitor",
        "AzureContainerRegistry",
        "MicrosoftContainerRegistry",
        "AzureActiveDirectory"
      ]
      destination_ports = ["443"]
    }
  }

  application_rule_collection {
    name     = "app"
    priority = 300
    action   = "Allow"

    rule {
      name             = "azure"
      source_addresses = ["*"]
      destination_fqdns = [
        "*.hcp.${var.spoke_location}.azmk8s.io",
        "mcr.microsoft.com",
        "*.data.mcr.microsoft.com",
        "management.azure.com",
        "login.microsoftonline.com",
        "packages.microsoft.com",
        "acs-mirror.azureedge.net",
        "dc.services.visualstudio.com",
        "*.ods.opinsights.azure.com",
        "*.oms.opinsights.azure.com",
        "*.monitoring.azure.com",
        "data.policy.core.windows.net",
        "store.policy.core.windows.net",
        "${var.spoke_location}.dp.kubernetesconfiguration.azure.com"
      ]

      protocols {
        type = "Https"
        port = 443
      }
    }

    rule {
      name             = "ubuntu"
      source_addresses = ["*"]
      destination_fqdns = [
        "archive.ubuntu.com",
        "security.ubuntu.com",
        "azure.archive.ubuntu.com",
        "changelogs.ubuntu.com",
        "motd.ubuntu.com"
      ]

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }
    }

    rule {
      name             = "registry"
      source_addresses = ["*"]
      destination_fqdns = [
        "k8s.gcr.io",
        "storage.googleapis.com",
        "auth.docker.io",
        "registry-1.docker.io",
        "production.cloudflare.docker.com"
      ]

      protocols {
        type = "Https"
        port = 443
      }
    }

    rule {
      name             = "helm"
      source_addresses = ["*"]
      destination_fqdns = [
        "kubernetes.github.io",
        "github.com",
        "objects.githubusercontent.com"
      ]

      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "kubernetes" {
  name               = "kubernetes"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 200

  network_rule_collection {
    name     = "net"
    priority = 200
    action   = "Allow"

    rule {
      name              = "control-plane-tcp"
      protocols         = ["TCP"]
      source_addresses  = ["*"]
      destination_fqdns = [azurerm_kubernetes_cluster.main.fqdn]
      destination_ports = ["443"]
    }

    rule {
      name              = "control-plane-dns"
      protocols         = ["UDP"]
      source_addresses  = ["*"]
      destination_fqdns = [azurerm_kubernetes_cluster.main.fqdn]
      destination_ports = ["53"]
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "Logs"
  target_resource_id         = azurerm_firewall.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub.id

  dynamic "log" {
    for_each = local.firewall_diagnostic_logs

    content {
      category = log.value
      enabled  = true
    }
  }
}
