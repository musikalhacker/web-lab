terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-web-lab"
  location = var.location
}

resource "azurerm_service_plan" "plan" {
  name                = "plan-web-lab"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-web-lab-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = false   # required for free tier

    ip_restriction {
      name       = "allow-home"
      ip_address = "${var.home_ip}/32"
      action     = "Allow"
      priority   = 100
    }

    ip_restriction_default_action = "Deny"
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
