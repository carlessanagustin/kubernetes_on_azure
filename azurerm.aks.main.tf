resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${var.project_prefix}-k8s"
  dns_prefix          = var.project_prefix
  kubernetes_version  = var.k8s_version

  default_node_pool {
    name                  = "defaultnp"
    vm_size               = var.k8s_vm_size
    os_disk_size_gb       = var.k8s_disk_gb
    enable_node_public_ip = false

    enable_auto_scaling   = var.k8s_npool_scale
    max_count             = var.k8s_npool_max_count
    min_count             = var.k8s_npool_min_count
    node_count            = var.k8s_npool_node_count
    type                  = "VirtualMachineScaleSets"
    availability_zones    = ["1", "2", "3"]
    vnet_subnet_id        = azurerm_subnet.snet1.id
  }

  auto_scaler_profile {
    balance_similar_node_groups      = var.auto_scaler_settings.balance_similar_node_groups
    max_graceful_termination_sec     = var.auto_scaler_settings.max_graceful_termination_sec
    scan_interval                    = var.auto_scaler_settings.scan_interval
    scale_down_delay_after_add       = var.auto_scaler_settings.scale_down_delay_after_add
    scale_down_delay_after_delete    = var.auto_scaler_settings.scale_down_delay_after_delete
    scale_down_delay_after_failure   = var.auto_scaler_settings.scale_down_delay_after_failure
    scale_down_unneeded              = var.auto_scaler_settings.scale_down_unneeded
    scale_down_unready               = var.auto_scaler_settings.scale_down_unready
    scale_down_utilization_threshold = var.auto_scaler_settings.scale_down_utilization_threshold
  }

  network_profile {
    network_plugin                  = "kubenet"
    network_policy                  = "calico"

    # "loadBalancer" | "userDefinedRouting"
    #outbound_type = "loadBalancer"

    load_balancer_sku               = "Standard"
    load_balancer_profile {
    	managed_outbound_ip_count     = 1
      #outbound_ip_prefix_ids 
      #outbound_ip_address_ids 
    }
  }

  role_based_access_control {
    enabled  = true
  }
  
  # beware! "unable to validate against any pod security policy"
  enable_pod_security_policy        = false
  api_server_authorized_ip_ranges   = var.office_pip

  addon_profile {
    # ingress-class=addon-http-application-routing
    http_application_routing {
      enabled                       = false
    }
    kube_dashboard {
      enabled                       = true
    }
    # @azurerm.law.tf
    oms_agent {
      enabled                       = true
      log_analytics_workspace_id    = azurerm_log_analytics_workspace.law.id
    }
  }

  depends_on = [azurerm_log_analytics_workspace.law]

  service_principal {
    client_id     = var.k8s_sp_client_id
    client_secret = var.k8s_sp_client_secret
  }

  tags                = var.project_tags
}



provider "kubernetes" {
  version                = "=1.11.2"

  load_config_file       = "false"
  host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  username               = azurerm_kubernetes_cluster.k8s.kube_config.0.username
  password               = azurerm_kubernetes_cluster.k8s.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}
