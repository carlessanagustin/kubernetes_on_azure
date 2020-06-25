resource "azurerm_monitor_diagnostic_setting" "appgw-diagnostics" {
  name                       = "diag2law"
  target_resource_id         = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true
  }

  log {
    category = "ApplicationGatewayPerformanceLog"
    enabled  = true
  }

  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "pip-diagnostics" {
  name                       = "diag2law"
  target_resource_id         = azurerm_public_ip.appgw-pip.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "DDoSProtectionNotifications"
    enabled  = true
  }

  log {
    category = "DDoSMitigationFlowLogs"
    enabled  = true
  }

  log {
    category = "DDoSMitigationReports"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "vnet-diagnostics" {
  name                       = "diag2law"
  target_resource_id         = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "VMProtectionAlerts"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "k8s-diagnostics" {
  name                       = "diag2law"
  target_resource_id         = azurerm_kubernetes_cluster.k8s.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "kube-apiserver"
    enabled  = true
  }
  log {
    category = "kube-audit"
    enabled  = true
  }
  log {
    category = "kube-controller-manager"
    enabled  = true
  }
  log {
    category = "kube-scheduler"
    enabled  = true
  }
  log {
    category = "cluster-autoscaler"
    enabled  = true
  }
}

#resource "azurerm_monitor_diagnostic_setting" "nsg-diagnostics" {
#  name                       = "diag2law"
#  target_resource_id         = azurerm_network_security_rule.nsr.id
#  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
#  log {
#    category = "NetworkSecurityGroupEvent"
#    enabled  = true
#  }
#  log {
#    category = "NetworkSecurityGroupRuleCounter"
#    enabled  = true
#  }
#}