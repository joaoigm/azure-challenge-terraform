
resource "azurerm_public_ip" "apigateway" {
  name                = "${var.project_name}apigatewayip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.main.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.main.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.main.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.main.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.main.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.main.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.main.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "${var.project_name}-api-gateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.public.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.apigateway.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.project_name}-privateaks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.project_name}-privateaks"

  private_cluster_enabled = true
  sku_tier = "Free"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
    enable_auto_scaling = true
    enable_node_public_ip = false
    vnet_subnet_id = azurerm_subnet.private[0].id
    max_count = 3
    min_count = 1
  }

  role_based_access_control {
    enabled = false
  }
  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }

  linux_profile {
    admin_username = var.project_name
    ssh_key {
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.main.kube_config_raw
}