variable "project_location" {
  default = "northeurope"
}
resource "azurerm_resource_group" "rg" {
  name     = "${var.project_prefix}-rg"
  location = var.project_location
  tags     = var.project_tags
}
