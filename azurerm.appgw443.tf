variable "k8s_ingress_ip" {
  default     = ["10.1.16.5"]
  description = "get IP via command = make show_nginx_ingress_ip"
}

variable "ssl_certificate_file" {}
variable "ssl_certificate_password" {}

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
    name              = "https-port"
    port              = 443
  }

  frontend_port {
    name              = "http-port"
    port              = 80
  }

  frontend_ip_configuration {
    name                 = "feip"
    public_ip_address_id = azurerm_public_ip.appgw-pip.id
  }

  ssl_certificate {
    name     = "certificate"
    data     = filebase64(var.ssl_certificate_file)
    password = var.ssl_certificate_password
  }

########################## http >> https
  # listener
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "feip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }
  # rules
  request_routing_rule {
    name                        = "http-routing-rule"
    rule_type                   = "Basic"
    http_listener_name          = "http-listener"
    redirect_configuration_name = "redirects-to-https"
  }
  # redirect
  redirect_configuration {
    name                 = "redirects-to-https"
    redirect_type        = "Permanent"
    target_listener_name = "https-listener"
    include_path         = true
    include_query_string = true
  }

########################## https to backend
  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "feip"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "certificate"
    #require_sni                    = "true"
    #host_name                      = "www.example.com"
  }

  request_routing_rule {
    name                       = "https-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "be-pool-01"
    backend_http_settings_name = "http-settings"
  }

  # http backend
  backend_http_settings {
    name                                = "http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 20
    probe_name                          = "http-probe"    
    pick_host_name_from_backend_address = true
    # host_name                           = ""
  }

  probe {
    name                                      = "http-probe"
    protocol                                  = "http"
    path                                      = "/"
    pick_host_name_from_backend_http_settings = true
    interval                                  = "30"
    timeout                                   = "30"
    unhealthy_threshold                       = "3"
    # host                                      = ""

    match {
      body                                    = "default backend - 404"
      status_code                             = ["404"]
    }
  }

  backend_address_pool {
    name                  = "be-pool-01"
    ip_addresses          = var.k8s_ingress_ip
    # fqdns                 = [azurerm_kubernetes_cluster.k8s.fqdn]
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
