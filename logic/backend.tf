
data "azurerm_resource_group" "image" {
  name                = azurerm_resource_group.resource_group.name 
}

data "azurerm_image" "zipkin_image" {
  name                = "dev-prft-eastus-rg-zipkin-img"
  resource_group_name = azurerm_resource_group.resource_group.name 
}


resource "azurerm_linux_virtual_machine_scale_set" "zipkin_vmss" {
    name                = "${local.naming_convention}-zipkin-vmss"
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = azurerm_resource_group.resource_group.location
    sku                 = "Standard_F2"
    instances           = 1
    admin_username      = "adminuser"
    admin_password      = "#Tomate2022"
    disable_password_authentication = false
    source_image_id = data.azurerm_image.zipkin_image.id
    
    network_interface {
        name    = "${local.naming_convention}-zipkin-nic"
        primary = true
        ip_configuration {
            name                          = "config_zipkin"
            subnet_id                     = azurerm_subnet.subnet_backend.id
            application_gateway_backend_address_pool_ids = "${azurerm_application_gateway.app_gateway.backend_address_pool[0].id}"
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
    name                = "${local.naming_convention}-users-api-vmss"
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = azurerm_resource_group.resource_group.location
    sku                 = "Standard_F2"
    instances           = 1
    admin_username      = "adminuser"
    admin_password      = "#Tomate2022"
    disable_password_authentication = false
    source_image_id = data.azurerm_image.users_image.id
    network_interface {
        name    = "${local.naming_convention}-users-api-nic"
        primary = true
        ip_configuration {
            name                          = "config_users_api"
            subnet_id                     = azurerm_subnet.subnet_backend.id
            
            application_gateway_backend_address_pool_ids = "${azurerm_application_gateway.app_gateway.backend_address_pool[1].id}"
           
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
            application_gateway_backend_address_pool_ids = "${azurerm_application_gateway.app_gateway.backend_address_pool[*].id}"
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
   
            #private_ip_address             = "10.0.2.13"
            application_gateway_backend_address_pool_ids = "${azurerm_application_gateway.app_gateway.backend_address_pool[*].id}"
            #private_ip_address_allocation = "Dynamic"
            #public_ip_address_id          = azurerm_public_ip.app_gateway_public_ip.id
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
           
            #private_ip_address             = "10.0.2.12"
            application_gateway_backend_address_pool_ids = "${azurerm_application_gateway.app_gateway.backend_address_pool[*].id}"
            #private_ip_address_allocation = "Dynamic"
            #public_ip_address_id          = azurerm_public_ip.app_gateway_public_ip.id
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

resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = "${local.naming_convention}-app-gateway-public-ip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name 
  allocation_method = "Static"
  sku = "Standard" 
 
}
locals { 
  # Generic 
  frontend_port_name             = "${local.naming_convention}-frontend_port"
  frontend_ip_configuration_name = "${local.naming_convention}-frontend_ip_configuration"
  listener_name                  = "${local.naming_convention}-http-listener"
  request_routing_rule1_name     = "${azurerm_virtual_network.vnet.name}-rqrt-1"  

  # App1
  backend_address_pool_name_zipkin      = "${local.naming_convention}-backend_address_pool_zipkin"
  http_setting_name_zipkin              = "${local.naming_convention}-backend_http_settings_zipkin"
  probe_name_app1                = "${local.naming_convention}-be-probe-app1"

  # App2
  backend_address_pool_name_users      = "${local.naming_convention}-backend_address_pool_users_api"
  http_setting_name_users              = "${local.naming_convention}-backend_http_settings_users_api"
  probe_name_app2                    = "${local.naming_convention}-be-probe-app2"

  # Default Redirect on Root Context (/)
  redirect_configuration_name    = "${local.naming_convention}-rdrcfg"

}

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

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

    
  # Configuración del backend address pool y http settings para zipkin (puerto 9411)
    backend_address_pool {
        name = local.backend_address_pool_name_zipkin
    }
    backend_http_settings {
        name                  = local.http_setting_name_zipkin
        cookie_based_affinity = "Disabled"
        #path                  = "/zipkin/"
        port                  = 9411
        protocol              = "Http"
        request_timeout       = 60
        probe_name = local.probe_name_app1
    }
  backend_http_settings {
    name                  = "${local.naming_convention}-backend_http_settings_zipkin"
    cookie_based_affinity = "Disabled"
    #path                  = "/zipkin/"
    port                  = 9411
    protocol              = "Http"
    request_timeout       = 60
  }
    http_listener {
    name                           = "${local.naming_convention}-http-listener-zipkin"
    frontend_ip_configuration_name = "${local.naming_convention}-frontend_ip_configuration"
    frontend_port_name             = "${local.naming_convention}-frontend_port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${local.naming_convention}-request-routing-rule-zipkins"
    rule_type                  = "Basic"
    http_listener_name         = "${local.naming_convention}-http-listener-zipkin"
    backend_address_pool_name  = "${local.naming_convention}-backend_address_pool_zipkin"
    backend_http_settings_name = "${local.naming_convention}-backend_http_settings_zipkin"
  }
    /*
  # Configuración del backend address pool y http settings para auth_api (puerto 8081)
  backend_address_pool {
    name = "${local.naming_convention}-backend_address_pool_auth_api"
    backend_addresses {
      fqdn = "${azurerm_linux_virtual_machine_scale_set.auth_api_vmss.name}.${azurerm_resource_group.resource_group.name}.cloudapp.azure.com"
    }
  }
  backend_http_settings {
    name                  = "${local.naming_convention}-backend_http_settings_auth_api"
    cookie_based_affinity = "Disabled"
    path                  = "/auth/"
    port                  = 8081
    protocol              = "Http"
    request_timeout       = 60
  }
  http_listener {
    name                           = "${local.naming_convention}-auth-api-http-listener"
    frontend_ip_configuration_name = "${local.naming_convention}-frontend_ip_configuration"
    frontend_port_name             = "${local.naming_convention}-frontend_port_auth_api"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "${local.naming_convention}-auth-api-request-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "${local.naming_convention}-auth-api-http-listener"
    backend_address_pool_name  = "${local.naming_convention}-backend_address_pool_auth_api"
    backend_http_settings_name = "${local.naming_convention}-backend_http_settings_auth_api"
  }
  # Configuración del backend address pool y http settings para log_processor (puerto 8080)
  backend_address_pool {
    name = "${local.naming_convention}-backend_address_pool_log_processor"
    backend_addresses {
      fqdn = "${azurerm_linux_virtual_machine_scale_set.log_processor_vmss.name}.${azurerm_resource_group.resource_group.name}.cloudapp.azure.com"
    }
  }

  backend_http_settings {
    name                  = "${local.naming_convention}-backend_http_settings_log_processor"
    cookie_based_affinity = "Disabled"
    path                  = "/log/"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 60
  }
  http_listener {
    name                           = "${local.naming_convention}-log-processor-http-listener"
    frontend_ip_configuration_name = "${local.naming_convention}-frontend_ip_configuration"
    frontend_port_name             = "${local.naming_convention}-frontend_port_log_processor"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "${local.naming_convention}-log-processor-request-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "${local.naming_convention}-log-processor-http-listener"
    backend_address_pool_name  = "${local.naming_convention}-backend_address_pool_log_processor"
    backend_http_settings_name = "${local.naming_convention}-backend_http_settings_log_processor"
  }
  # Configuración del backend address pool y http settings para todos_api (puerto 8082)
  backend_address_pool {
    name = "${local.naming_convention}-backend_address_pool_todos_api"
    backend_addresses {
      fqdn = "${azurerm_linux_virtual_machine_scale_set.todos_api_vmss.name}.${azurerm_resource_group.resource_group.name}.cloudapp.azure.com"
    }
  }

  backend_http_settings {
    name                  = "${local.naming_convention}-backend_http_settings_todos_api"
    cookie_based_affinity = "Disabled"
    path                  = "/todos/"
    port                  = 8082
    protocol              = "Http"
    request_timeout       = 60
  }
  http_listener {
    name                           = "${local.naming_convention}-todos-api-http-listener"
    frontend_ip_configuration_name = "${local.naming_convention}-frontend_ip_configuration"
    frontend_port_name             = "${local.naming_convention}-frontend_port_todos_api"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "${local.naming_convention}-todos-api-request-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "${local.naming_convention}-todos-api-http-listener"
    backend_address_pool_name  = "${local.naming_convention}-backend_address_pool_todos_api"
    backend_http_settings_name = "${local.naming_convention}-backend_http_settings_todos_api"
  }
  # Configuración del backend address pool y http settings para users_api (puerto 8083)
  backend_address_pool {
    name = "${local.naming_convention}-backend_address_pool_users_api"
    backend_addresses {
      fqdn = "${azurerm_linux_virtual_machine_scale_set.users_api_vmss.name}.${azurerm_resource_group.resource_group.name}.cloudapp.azure.com"
    }
  }

  backend_http_settings {
    name                  = "${local.naming_convention}-backend_http_settings_users_api"
    cookie_based_affinity = "Disabled"
    path                  = "/users/"
    port                  = 8083
    protocol              = "Http"
    request_timeout       = 60
  }
  http_listener {
    name                           = "${local.naming_convention}-users-api-http-listener"
    frontend_ip_configuration_name = "${local.naming_convention}-frontend_ip_configuration"
    frontend_port_name             = "${local.naming_convention}-frontend_port_users_api"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "${local.naming_convention}-users-api-request-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "${local.naming_convention}-users-api-http-listener"
    backend_address_pool_name  = "${local.naming_convention}-backend_address_pool_users_api"
    backend_http_settings_name = "${local.naming_convention}-backend_http_settings_users_api"
  }
    */

}


#resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "back_nic_app_gateway" {
 # count = 2
  #network_interface_id    = azurerm_linux_virtual_machine_scale_set.back_vmss.network_interface_id
  #ip_configuration_name   = "nic-ipconfig-${count.index+1}"
  #backend_address_pool_id = azurerm_application_gateway.app_gateway.backend_address_pool[0].id
#}