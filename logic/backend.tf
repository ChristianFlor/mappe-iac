resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = "${local.naming_convention}-app-gateway-public-ip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"

}
locals {
  # App Gateway
  frontend_ip_configuration_name_app_gateway = "${local.naming_convention}-frontend_ip_configuration_app_gateway"
  # App1
  frontend_port_name_zipkin         = var.frontend_port_name_zipkin
  backend_address_pool_name_zipkin  = var.backend_address_pool_name_zipkin
  http_setting_name_zipkin          = var.http_setting_name_zipkin
  listener_name_zipkin              = var.listener_name_zipkin
  request_routing_rule_zipkin_name  = var.request_routing_rule_zipkin_name
  # App2
  frontend_port_name_users          = var.frontend_port_name_users
  backend_address_pool_name_users   = var.backend_address_pool_name_users
  http_setting_name_users           = var.http_setting_name_users
  listener_name_users               = var.listener_name_users
  request_routing_rule_users_name   = var.request_routing_rule_users_name
}
/*
locals {

  # App Gateway
  frontend_ip_configuration_name_app_gateway = "${local.naming_convention}-frontend_ip_configuration_app_gateway"

  # App1
  frontend_port_name_zipkin        = "${local.naming_convention}-frontend_port_zipkin"
  backend_address_pool_name_zipkin = "${local.naming_convention}-backend_address_pool_zipkin"
  http_setting_name_zipkin         = "${local.naming_convention}-backend_http_settings_zipkin"
  listener_name_zipkin             = "${local.naming_convention}-http-listener_zipkin"
  request_routing_rule_zipkin_name = "${local.naming_convention}-request_routing_rule_zipkin"
  # App2
  frontend_port_name_users        = "${local.naming_convention}-frontend_port_users_api"
  backend_address_pool_name_users = "${local.naming_convention}-backend_address_pool_users_api"
  http_setting_name_users         = "${local.naming_convention}-backend_http_settings_users_api"
  listener_name_users             = "${local.naming_convention}-http-listener_users_api"
  request_routing_rule_users_name = "${local.naming_convention}-request_routing_rule_users_api"
  # App3
  frontend_port_name_auth        = "${local.naming_convention}-frontend_port_auth_api"
  backend_address_pool_name_auth = "${local.naming_convention}-backend_address_pool_auth_api"
  http_setting_name_auth         = "${local.naming_convention}-backend_http_settings_auth_api"
  listener_name_auth             = "${local.naming_convention}-http-listener_auth_api"
  request_routing_rule_auth_name = "${local.naming_convention}-request_routing_rule_auth_api"
  # App4
  frontend_port_name_log_processor        = "${local.naming_convention}-frontend_port_log_processors"
  backend_address_pool_name_log_processor = "${local.naming_convention}-backend_address_pool_log_processors"
  http_setting_name_log_processor         = "${local.naming_convention}-backend_http_settings_log_processors"
  listener_name_log_processor             = "${local.naming_convention}-http-listener_log_processors"
  request_routing_rule_log_processor_name = "${local.naming_convention}-request_routing_rule_log_processors"
  # App5
  frontend_port_name_todos        = "${local.naming_convention}-frontend_port_todos_api"
  backend_address_pool_name_todos = "${local.naming_convention}-backend_address_pool_todos_api"
  http_setting_name_todos         = "${local.naming_convention}-backend_http_settings_todos_api"
  listener_name_todos             = "${local.naming_convention}-http-listener_todos_api"
  request_routing_rule_todos_name = "${local.naming_convention}-request_routing_rule_todos_api"

}*/
data "azurerm_resource_group" "image" {
  name = azurerm_resource_group.resource_group.name
}

data "azurerm_image" "zipkin_image" {
  name                = "dev-prft-eastus-rg-zipkin-img"
  resource_group_name = azurerm_resource_group.resource_group.name
}


resource "azurerm_linux_virtual_machine_scale_set" "zipkin_vmss" {
  name                            = "${local.naming_convention}-zipkin-vmss"
  resource_group_name             = azurerm_resource_group.resource_group.name
  location                        = azurerm_resource_group.resource_group.location
  sku                             = "Standard_F2"
  instances                       = 1
  admin_username                  = "adminuser"
  admin_password                  = "#Tomate2022"
  disable_password_authentication = false
  source_image_id                 = data.azurerm_image.zipkin_image.id

  network_interface {
    name    = "${local.naming_convention}-zipkin-nic"
    primary = true
    ip_configuration {
      name                                         = "config_zipkin"
      subnet_id                                    = azurerm_subnet.subnet_backend.id
      application_gateway_backend_address_pool_ids = toset([for pool in azurerm_application_gateway.app_gateway.backend_address_pool : pool.id if pool.name == local.backend_address_pool_name_zipkin])
    }

    network_security_group_id = azurerm_network_security_group.nsg_back.id
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  depends_on = [
    azurerm_network_security_group.nsg_back,
  ]

}
resource "azurerm_network_security_group" "nsg_back" {
  name                = "myNetworkSecurityGroupBack"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "161.18.74.141"
    destination_address_prefix = "*"
  }

}


data "azurerm_image" "users_image" {
  name                = "dev-prft-eastus-rg-users-api-img"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_linux_virtual_machine_scale_set" "users_api_vmss" {
  name                            = "${local.naming_convention}-users-api-vmss"
  resource_group_name             = azurerm_resource_group.resource_group.name
  location                        = azurerm_resource_group.resource_group.location
  sku                             = "Standard_F2"
  instances                       = 1
  admin_username                  = "adminuser"
  admin_password                  = "#Tomate2022"
  disable_password_authentication = false
  source_image_id                 = data.azurerm_image.users_image.id
  network_interface {
    name    = "${local.naming_convention}-users-api-nic"
    primary = true
    ip_configuration {
      name                                         = "config_users_api"
      subnet_id                                    = azurerm_subnet.subnet_backend.id
      application_gateway_backend_address_pool_ids = toset([for pool in azurerm_application_gateway.app_gateway.backend_address_pool : pool.id if pool.name == local.backend_address_pool_name_users])
    }
    network_security_group_id = azurerm_network_security_group.nsg_back.id
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  depends_on = [
    azurerm_network_security_group.nsg_back,
  ]

}
/*
data "azurerm_image" "auth_image" {
  name                = "dev-prft-eastus-rg-auth-img"
  resource_group_name = azurerm_resource_group.resource_group.name 
}
resource "azurerm_linux_virtual_machine_scale_set" "auth_api_vmss" {
    name                = "${local.naming_convention}-auth-api-vmss"
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = azurerm_resource_group.resource_group.location
    sku                 = "Standard_F2"
    instances           = 1
    admin_username      = "adminuser"
    admin_password      = "#Tomate2022"
    disable_password_authentication = false
    source_image_id = data.azurerm_image.auth_image.id
    network_interface {
        name    = "${local.naming_convention}-auth-api-nic"
        primary = true
        ip_configuration {
            name                          = "config_auth_api"
            subnet_id                     = azurerm_subnet.subnet_backend.id
            application_gateway_backend_address_pool_ids = toset([for pool in azurerm_application_gateway.app_gateway.backend_address_pool : pool.id if pool.name == local.backend_address_pool_name_auth])
        }
        network_security_group_id = azurerm_network_security_group.nsg_back.id
    }
    
    os_disk {
        storage_account_type = "Standard_LRS"
        caching              = "ReadWrite"
    }
    depends_on = [
        azurerm_network_security_group.nsg_back,
    ]
    
}
/*
data "azurerm_image" "log_processor_image" {
  name                = "dev-prft-eastus-rg-log-processor-img"
  resource_group_name = azurerm_resource_group.resource_group.name 
}
resource "azurerm_linux_virtual_machine_scale_set" "log_processor_vmss" {
    name                = "${local.naming_convention}-log-processor-vmss"
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = azurerm_resource_group.resource_group.location
    sku                 = "Standard_F2"
    instances           = 1
    admin_username      = "adminuser"
    admin_password      = "#Tomate2022"
    disable_password_authentication = false
    source_image_id = data.azurerm_image.log_processor_image.id
    network_interface {
        name    = "${local.naming_convention}-auth-api-nic"
        primary = true
        ip_configuration {
            name                          = "config_log_processor"
            subnet_id                     = azurerm_subnet.subnet_backend.id
            application_gateway_backend_address_pool_ids = toset([for pool in azurerm_application_gateway.app_gateway.backend_address_pool : pool.id if pool.name == local.backend_address_pool_name_log_processor])
        }
        network_security_group_id = azurerm_network_security_group.nsg_back.id
    }
   
    os_disk {
        storage_account_type = "Standard_LRS"
        caching              = "ReadWrite"
    }
    depends_on = [
        azurerm_network_security_group.nsg_back,
    ]
    
}

data "azurerm_image" "todos_image" {
  name                = "dev-prft-eastus-rg-todos-api-img"
  resource_group_name = azurerm_resource_group.resource_group.name 
}
resource "azurerm_linux_virtual_machine_scale_set" "todos_api_vmss" {
    name                = "${local.naming_convention}-todos-api-vmss"
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = azurerm_resource_group.resource_group.location
    sku                 = "Standard_F2"
    instances           = 1
    admin_username      = "adminuser"
    admin_password      = "#Tomate2022"
    disable_password_authentication = false
    source_image_id = data.azurerm_image.todos_image.id
    network_interface {
        name    = "${local.naming_convention}-todos-api-nic"
        primary = true
        ip_configuration {
            name                          = "config_todos_api"
            subnet_id                     = azurerm_subnet.subnet_backend.id
            application_gateway_backend_address_pool_ids = toset([for pool in azurerm_application_gateway.app_gateway.backend_address_pool : pool.id if pool.name == local.backend_address_pool_name_todos])
        }
        network_security_group_id = azurerm_network_security_group.nsg_back.id
    }
    
    os_disk {
        storage_account_type = "Standard_LRS"
        caching              = "ReadWrite"
    }
    depends_on = [
        azurerm_network_security_group.nsg_back,
    ]

}

*/


resource "azurerm_application_gateway" "app_gateway" {
  name                = "${local.naming_convention}-app-gateway"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }
  
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.subnet_app_gateway.id
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name_app_gateway
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }
  dynamic "frontend_port" {
    for_each = [local.frontend_port_name_zipkin, local.frontend_port_name_users]
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }
    dynamic "backend_address_pool" {
        for_each = var.backend_address_pools
        content {
            name = backend_address_pool.value.name
        }
    
  }
  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                  = backend_http_settings.value.name
      cookie_based_affinity = backend_http_settings.value.cookie_based_affinity
      port                  = backend_http_settings.value.port
      protocol              = backend_http_settings.value.protocol
      request_timeout       = backend_http_settings.value.request_timeout
    }
    
  }
  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
    }
    
  }
  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                       = request_routing_rule.value.name
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
    }
  }
  /*  
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name_app_gateway
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }


  # Configuración del backend address pool y http settings para zipkin (puerto 9411)
  frontend_port {
    name = local.frontend_port_name_zipkin
    port = 9411
  }
  backend_address_pool {
    name = local.backend_address_pool_name_zipkin
  }
  backend_http_settings {
    name                  = local.http_setting_name_zipkin
    cookie_based_affinity = "Disabled"
    #path                  = "/zipkin/"
    port            = 9411
    protocol        = "Http"
    request_timeout = 60
  }
  http_listener {
    name                           = local.listener_name_zipkin
    frontend_ip_configuration_name = local.frontend_ip_configuration_name_app_gateway
    frontend_port_name             = local.frontend_port_name_zipkin
    protocol                       = "Http"
  }
  # Path based Routing Rule
  request_routing_rule {
    name                       = local.request_routing_rule_zipkin_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_zipkin
    backend_address_pool_name  = local.backend_address_pool_name_zipkin
    backend_http_settings_name = local.http_setting_name_zipkin

  }
  # Configuración del backend address pool y http settings para users_api (puerto 8083)
  frontend_port {
    name = local.frontend_port_name_users
    port = 8083
  }
  backend_address_pool {
    name = local.backend_address_pool_name_users
  }

  backend_http_settings {
    name                  = local.http_setting_name_users
    cookie_based_affinity = "Disabled"
    #path                  = "/users/"
    port            = 8083
    protocol        = "Http"
    request_timeout = 60
  }
  http_listener {
    name                           = local.listener_name_users
    frontend_ip_configuration_name = local.frontend_ip_configuration_name_app_gateway
    frontend_port_name             = local.frontend_port_name_users
    protocol                       = "Http"
  }
  # Path based Routing Rule
  request_routing_rule {
    name                       = local.request_routing_rule_users_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_users
    backend_address_pool_name  = local.backend_address_pool_name_users
    backend_http_settings_name = local.http_setting_name_users

  }
  /*
  # Configuración del backend address pool y http settings para auth_api (puerto 8081)
  frontend_port {
    name = local.frontend_port_name_auth
    port = 8081
  }
  backend_address_pool {
    name = local.backend_address_pool_name_auth
  }
    backend_http_settings {
        name                  = local.http_setting_name_auth
        cookie_based_affinity = "Disabled"
        #path                  = "/auth/"
        port            = 8081
        protocol        = "Http"
        request_timeout = 60
    }
    http_listener {
        name                           = local.listener_name_auth
        frontend_ip_configuration_name = local.frontend_ip_configuration_name_app_gateway
        frontend_port_name             = local.frontend_port_name_auth
        protocol                       = "Http"
    }
    # Path based Routing Rule
    request_routing_rule {
        name                      = local.request_routing_rule_auth_name 
        rule_type                  = "Basic"
        http_listener_name         = local.listener_name_auth
        backend_address_pool_name  = local.backend_address_pool_name_auth
        backend_http_settings_name = local.http_setting_name_auth
    }

  # Configuración del backend address pool y http settings para log_processor (puerto 8080)
    frontend_port {
        name = local.frontend_port_name_log_processor
        port = 8080
    }
    backend_address_pool {
        name = local.backend_address_pool_name_log_processor
    }
    backend_http_settings {
        name                  = local.http_setting_name_log_processor
        cookie_based_affinity = "Disabled"
        #path                  = "/log_processor/"
        port            = 8080
        protocol        = "Http"
        request_timeout = 60
    }
    http_listener {
        name                           = local.listener_name_log_processor
        frontend_ip_configuration_name = local.frontend_ip_configuration_name_app_gateway
        frontend_port_name             = local.frontend_port_name_log_processor
        protocol                       = "Http"
    }
    # Path based Routing Rule
    request_routing_rule {
        name                       = local.request_routing_rule_log_processor_name
        rule_type                  = "Basic"
        http_listener_name         = local.listener_name_log_processor
        backend_address_pool_name  = local.backend_address_pool_name_log_processor
        backend_http_settings_name = local.http_setting_name_log_processor
    }

  # Configuración del backend address pool y http settings para todos_api (puerto 8082)
    frontend_port {
        name = local.frontend_port_name_todos
        port = 8082
    }
    backend_address_pool {
        name = local.backend_address_pool_name_todos
    }
    backend_http_settings {
        name                  = local.http_setting_name_todos
        cookie_based_affinity = "Disabled"
        #path                  = "/todos/"
        port            = 8082
        protocol        = "Http"
        request_timeout = 60
    }
    http_listener {
        name                           = local.listener_name_todos
        frontend_ip_configuration_name = local.frontend_ip_configuration_name_app_gateway
        frontend_port_name             = local.frontend_port_name_todos
        protocol                       = "Http"
    }
    request_routing_rule {
        name                       = local.request_routing_rule_todos_name
        rule_type                  = "Basic"
        http_listener_name         = local.listener_name_todos
        backend_address_pool_name  = local.backend_address_pool_name_todos
        backend_http_settings_name = local.http_setting_name_todos
    }
   */
}