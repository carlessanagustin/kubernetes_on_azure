resource "azurerm_log_analytics_workspace" "law" {
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  name                = "${var.project_prefix}-law-001"
  sku                 = "PerGB2018"
  retention_in_days   = 180

  tags                = var.project_tags
}
