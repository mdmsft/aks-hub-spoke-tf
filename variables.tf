variable "project" {
  type    = string
  default = "contoso"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "hub_location" {
  type    = string
  default = "westeurope"
}

variable "spoke_location" {
  type    = string
  default = "northeurope"
}

variable "hub_address_space" {
  type    = string
  default = "192.168.0.0/24"
}

variable "spoke_address_space" {
  type    = string
  default = "192.168.1.0/24"
}

variable "key_vault_soft_delete_retention_days" {
  type    = number
  default = 7
}

variable "kubernetes_cluster_orchestrator_version" {
  type    = string
  default = "1.24.3"
}

variable "kubernetes_cluster_sku_tier" {
  type    = string
  default = "Paid"
}

variable "kubernetes_cluster_automatic_channel_upgrade" {
  type    = string
  default = "rapid"
}

variable "kubernetes_cluster_azure_policy_enabled" {
  type    = bool
  default = false
}

variable "kubernetes_cluster_service_cidr" {
  type    = string
  default = "192.168.255.0/24"
}

variable "kubernetes_cluster_docker_bridge_cidr" {
  type    = string
  default = "10.255.255.0/24"
}

variable "kubernetes_cluster_default_node_pool_vm_size" {
  type    = string
  default = "Standard_D2d_v5"
}

variable "kubernetes_cluster_default_node_pool_max_pods" {
  type    = number
  default = 30
}

variable "kubernetes_cluster_default_node_pool_min_count" {
  type    = number
  default = 1
}

variable "kubernetes_cluster_default_node_pool_max_count" {
  type    = number
  default = 3
}

variable "kubernetes_cluster_default_node_pool_os_disk_size_gb" {
  type    = number
  default = 64
}

variable "kubernetes_cluster_default_node_pool_os_disk_type" {
  type    = string
  default = "Ephemeral"
}

variable "kubernetes_cluster_default_node_pool_os_sku" {
  type    = string
  default = "Ubuntu"
}

variable "kubernetes_cluster_default_node_pool_max_surge" {
  type    = string
  default = "33%"
}

variable "kubernetes_cluster_default_node_pool_availability_zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "kubernetes_cluster_default_node_pool_orchestrator_version" {
  type     = string
  default  = null
  nullable = true
}

variable "kubernetes_cluster_workload_node_pool_vm_size" {
  type    = string
  default = "Standard_D2d_v5"
}

variable "kubernetes_cluster_workload_node_pool_max_pods" {
  type    = number
  default = 30
}

variable "kubernetes_cluster_workload_node_pool_min_count" {
  type    = number
  default = 0
}

variable "kubernetes_cluster_workload_node_pool_max_count" {
  type    = number
  default = 3
}

variable "kubernetes_cluster_workload_node_pool_os_disk_size_gb" {
  type    = number
  default = 64
}

variable "kubernetes_cluster_workload_node_pool_os_disk_type" {
  type    = string
  default = "Ephemeral"
}

variable "kubernetes_cluster_workload_node_pool_os_sku" {
  type    = string
  default = "Ubuntu"
}

variable "kubernetes_cluster_workload_node_pool_max_surge" {
  type    = string
  default = "33%"
}

variable "kubernetes_cluster_workload_node_pool_availability_zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "kubernetes_cluster_workload_node_pool_orchestrator_version" {
  type     = string
  default  = null
  nullable = true
}

variable "kubernetes_cluster_workload_node_pool_labels" {
  type    = map(string)
  default = {}
}

variable "kubernetes_cluster_workload_node_pool_taints" {
  type    = list(string)
  default = []
}

variable "kubernetes_cluster_network_plugin" {
  type    = string
  default = "azure"
}

variable "kubernetes_cluster_network_policy" {
  type    = string
  default = "azure"
}

variable "kubernetes_cluster_open_service_mesh_enabled" {
  type    = bool
  default = false
}

variable "log_analytics_workspace_daily_quota_gb" {
  type    = number
  default = 1
}

variable "log_analytics_workspace_retention_in_days" {
  type    = number
  default = 30
}

variable "container_registry_sku" {
  type    = string
  default = "Standard"
}
