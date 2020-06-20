variable "k8s_vnet" {
  default = ["10.1.0.0/16"]
}
# Hosts/Net: 4094
variable "k8s_snet1" {
  default = ["10.1.16.0/20"]
}
variable "k8s_snet2" {
  default = ["10.1.32.0/20"]
}

resource "azurerm_virtual_network" "vnet" {
  name                   = "${var.project_prefix}-vnet"
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  address_space          = var.k8s_vnet
  tags                   = var.project_tags
}

# https://www.aprendaredes.com/cgi-bin/ipcalc/ipcalc_cgi?host=10.1.0.0&mask1=16&mask2=20
resource "azurerm_subnet" "snet1" {
  name                   = "${var.project_prefix}-snet1"
  resource_group_name    = azurerm_resource_group.rg.name
  address_prefixes       = var.k8s_snet1
  virtual_network_name   = azurerm_virtual_network.vnet.name
}

output "snet1_id" {
  value                  = azurerm_subnet.snet1.id
}

resource "azurerm_subnet" "snet2" {
  name                   = "${var.project_prefix}-snet2"
  resource_group_name    = azurerm_resource_group.rg.name
  address_prefixes       = var.k8s_snet2
  virtual_network_name   = azurerm_virtual_network.vnet.name
}

# nsg - firewall
resource "azurerm_network_security_group" "nsg" {
  name                          = "${var.project_prefix}-nsg"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tags                          = var.project_tags
}

resource "azurerm_subnet_network_security_group_association" "nsga1" {
  subnet_id                     = azurerm_subnet.snet1.id
  network_security_group_id     = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsga2" {
  subnet_id                     = azurerm_subnet.snet2.id
  network_security_group_id     = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_security_rule" "nsr" {
  resource_group_name           = azurerm_resource_group.rg.name
  network_security_group_name   = azurerm_network_security_group.nsg.name

  name                          = "office-pip"
  priority                      = 200
  direction                     = "Inbound"
  access                        = "Allow"
  protocol                      = "Tcp"
  source_port_range             = "*"
  destination_port_ranges       = ["80", "443"]
  source_address_prefixes       = var.office_pip
  # "VirtualNetwork" | "*"
  destination_address_prefix    = "*"
}

