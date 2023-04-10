resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = "${local.naming_convention}-app-gateway-public-ip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name 
  allocation_method = "Dynamic"

 
}
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
            #private_ip_address = "10.0.2.16"
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
    #source_image_id = data.azurerm_image.image.id
    /*extension {
        name                       = "zipkin-extension"
        publisher                  = "Microsoft.Azure.Extensions"
        type                       = "CustomScript"
        type_handler_version       = "2.0"
        auto_upgrade_minor_version = true
        settings = <<SETTINGS
        {
            "fileUris": ["https://raw.githubusercontent.com/ChristianFlor/mappe-scripting/tree/feature/packer/packer/zipkin.sh"],
            "commandToExecute": "bash zipkin.sh"
        }
        SETTINGS
    }*/
    
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
    source_address_prefix      = "161.18.77.83"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "nsg_association_back" {
  #network_interface_id      = "${azurerm_linux_virtual_machine_scale_set.zipkin_vmss.network_interface_ids[0]}"
  #network_security_group_id = azurerm_network_security_group.nsg_back.id
  count                      = length("${azurerm_virtual_machine_scale_set.zipkin_vmss.network_interface}")
  network_interface_id       = "${azurerm_virtual_machine_scale_set.zipkin_vmss.network_interface[count.index].id}"
  network_security_group_id  = azurerm_network_security_group.nsg_back.id

  depends_on = [
    azurerm_virtual_machine_scale_set.zipkin_vmss,
  ]
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
    
    network_interface {
        name    = "${local.naming_convention}-users-api-nic"
        primary = true
        ip_configuration {
            name                          = "config_users_api"
            subnet_id                     = azurerm_subnet.subnet_backend.id
            #private_ip_address  = "10.0.2.10"
            application_gateway_backend_address_pool_ids = "${azurerm_application_gateway.app_gateway.backend_address_pool[*].id}"
            #private_ip_address_allocation = "Dynamic"
            #public_ip_address_id          = azurerm_public_ip.app_gateway_public_ip.id
        }
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }
    os_disk {
        storage_account_type = "Standard_LRS"
        caching              = "ReadWrite"
    }
    /*resource "azurerm_linux_virtual_machine_scale_set_extension" "users_api_extension" {
        name                = "users-api-extension"
        virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.users_api_vmss.id
        publisher           = "Microsoft.Azure.Extensions"
        type                = "CustomScriptForLinux"
        type_handler_version = "1.8"
        settings = <<SETTINGS
        {
            "fileUris": ["https://raw.githubusercontent.com/ChristianFlor/mappe-scripting/feature/vagrant/vagrant/provision/users-api.sh"],
            "commandToExecute": "bash users-api.sh"
        }
        SETTINGS
    }*/
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
    
    network_interface {
        name    = "${local.naming_convention}-auth-api-nic"
        primary = true
        ip_configuration {
            name                          = "config_auth_api"
            subnet_id                     = azurerm_subnet.subnet_backend.id
           
            #private_ip_address             = "10.0.2.11"
            application_gateway_backend_address_pool_ids = "${azurerm_application_gateway.app_gateway.backend_address_pool[*].id}"
            #private_ip_address_allocation = "Dynamic"
            #public_ip_address_id          = azurerm_public_ip.app_gateway_public_ip.id
        }
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }
    os_disk {
        storage_account_type = "Standard_LRS"
        caching              = "ReadWrite"
    }
    /*resource "azurerm_linux_virtual_machine_scale_set_extension" "auth_api_extension" {
        name                = "auth-api-extension"
        virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.auth_api_vmss.id
        publisher           = "Microsoft.Azure.Extensions"
        type                = "CustomScriptForLinux"
        type_handler_version = "1.8"
        settings = <<SETTINGS
        {
            "fileUris": ["https://raw.githubusercontent.com/ChristianFlor/mappe-scripting/feature/vagrant/vagrant/provision/auth-api.sh"],
            "commandToExecute": "bash auth-api.sh"
        }
        SETTINGS
    }*/
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
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }
    os_disk {
        storage_account_type = "Standard_LRS"
        caching              = "ReadWrite"
    }
    /*resource "azurerm_linux_virtual_machine_scale_set_extension" "log_processor_extension" {
        name                = "log-processor-extension"
        virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.log_processor_vmss.id
        publisher           = "Microsoft.Azure.Extensions"
        type                = "CustomScriptForLinux"
        type_handler_version = "1.8"
        settings = <<SETTINGS
        {
            "fileUris": ["https://raw.githubusercontent.com/ChristianFlor/mappe-scripting/feature/vagrant/vagrant/provision/log-processor.sh"],
            "commandToExecute": "bash log-processor.sh"
        }
        SETTINGS
    }*/
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
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04-LTS"
        version   = "latest"
    }
    os_disk {
        storage_account_type = "Standard_LRS"
        caching              = "ReadWrite"
    }
    /*resource "azurerm_linux_virtual_machine_scale_set_extension" "todos_api_extension" {
        name                = "todos-api-extension"
        virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.todos_api_vmss.id
        publisher           = "Microsoft.Azure.Extensions"
        type                = "CustomScriptForLinux"
        type_handler_version = "1.8"
        settings = <<SETTINGS
        {
            "fileUris": ["https://raw.githubusercontent.com/ChristianFlor/mappe-scripting/feature/vagrant/vagrant/provision/todos-api.sh"],
            "commandToExecute": "bash todos-api.sh"
        }
        SETTINGS
    }*/
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
    name = "${local.naming_convention}-frontend_port_80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${local.naming_convention}-frontend_ip_configuration"
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }

  backend_address_pool {
    name = "${local.naming_convention}-backend_address_pool"
  }

  backend_http_settings {
    name                  = "${local.naming_convention}-backend_http_settings"
    cookie_based_affinity = "Disabled"
    path                  = "/back/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "${local.naming_convention}-http_listener"
    frontend_ip_configuration_name = "${local.naming_convention}-frontend_ip_configuration"
    frontend_port_name             = "${local.naming_convention}-frontend_port_80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${local.naming_convention}-request_routing_rule"
    rule_type                  = "Basic"
    http_listener_name         = "${local.naming_convention}-http_listener"
    backend_address_pool_name  = "${local.naming_convention}-backend_address_pool"
    backend_http_settings_name = "${local.naming_convention}-backend_http_settings"
  }
}


#resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "back_nic_app_gateway" {
 # count = 2
  #network_interface_id    = azurerm_linux_virtual_machine_scale_set.back_vmss.network_interface_id
  #ip_configuration_name   = "nic-ipconfig-${count.index+1}"
  #backend_address_pool_id = azurerm_application_gateway.app_gateway.backend_address_pool[0].id
#}