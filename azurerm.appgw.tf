variable "k8s_ingress_ip" {
  default     = ["10.1.16.5"]
  description = "get IP via command = make show_nginx_ingress_ip"
}


resource "azurerm_application_gateway" "appgw" {
  name                = "${var.project_prefix}-appgw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name              = "WAF_Medium"
    tier              = "WAF"
    capacity          = 1
  }

  waf_configuration {
    firewall_mode     = "Detection"
    rule_set_type     = "OWASP"
    rule_set_version  = "3.0"
    enabled           = true
  }

  enable_http2        = true 

  gateway_ip_configuration {
    name              = "ip-configuration"
    subnet_id         = azurerm_subnet.snet-appgw.id
  }

  frontend_port {
    name              = "${var.project_prefix}-https"
    port              = 443
  }

  frontend_port {
    name              = "${var.project_prefix}-http"
    port              = 80
  }

  frontend_ip_configuration {
    name                 = "${var.project_prefix}-feip"
    public_ip_address_id = azurerm_public_ip.appgw-pip.id
  }

#####
  http_listener {
    name                           = "${var.project_prefix}-httplstn1"
    frontend_ip_configuration_name = "${var.project_prefix}-feip"
    frontend_port_name             = "${var.project_prefix}-http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${var.project_prefix}-rule1"
    rule_type                  = "Basic"
    http_listener_name         = "${var.project_prefix}-httplstn1"
    backend_address_pool_name  = "${var.project_prefix}-bepool1"
    backend_http_settings_name = "${var.project_prefix}-httpsetting1"
  }

  backend_http_settings {
    name                                = "${var.project_prefix}-httpsetting1"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 20
    probe_name                          = "probe"
    # host_name                           = ""
    pick_host_name_from_backend_address = true
  }

  backend_address_pool {
    name                  = "${var.project_prefix}-bepool1"
    # fqdns                 = [azurerm_kubernetes_cluster.k8s.fqdn]
    # @./terraform/vars.tf
    ip_addresses          = var.k8s_ingress_ip
  }

  probe {
    name                                      = "probe"
    protocol                                  = "http"
    path                                      = "/"
    # host                                      = ""
    pick_host_name_from_backend_http_settings = true
    interval                                  = "30"
    timeout                                   = "30"
    unhealthy_threshold                       = "3"

    match {
      body                                    = "default backend - 404"
      status_code                             = ["404"]
    }
  }
}


variable "k8s_snet_appgw" {
  default = ["10.1.1.0/28"]
}

resource "azurerm_subnet" "snet-appgw" {
  name                   = "${var.project_prefix}-snet-appgw"
  resource_group_name    = azurerm_resource_group.rg.name
  address_prefixes       = var.k8s_snet_appgw
  virtual_network_name   = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet_network_security_group_association" "nsga" {
  subnet_id                     = azurerm_subnet.snet-appgw.id
  network_security_group_id     = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "appgw-pip" {
  name                   = "${var.project_prefix}-appgw-pip"
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  allocation_method      = "Dynamic"
  tags                   = var.project_tags
}
