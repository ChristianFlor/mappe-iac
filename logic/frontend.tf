resource "azurerm_availability_set" "front_availability_set" {
  name                = "${local.naming_convention}-front-avs"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

}
resource "azurerm_public_ip" "front_public_ip" {
  name                = "${local.naming_convention}-front-public-ip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"


}
resource "azurerm_network_interface" "front_nic" {
  name                = "${local.naming_convention}-front-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.subnet_fronted.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.front_public_ip.id
  }
}
/*
data "azurerm_image" "frontend_image" {
  name                = "dev-prft-eastus-rg-frontend-img"
  resource_group_name = azurerm_resource_group.resource_group.name 
}
resource "azurerm_linux_virtual_machine" "front_vm" {
  name                = "${local.naming_convention}-front-vm"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "#Tomate2022"
  disable_password_authentication = false
  availability_set_id = azurerm_availability_set.front_availability_set.id
  network_interface_ids = [
    azurerm_network_interface.front_nic.id,
  ]
  source_image_id = data.azurerm_image.frontend_image.id
#  admin_ssh_key {
 #   username   = "adminuser"
  #  public_key = file("~/.ssh/id_rsa.pub")
 # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 

}

resource "azurerm_public_ip" "public_ip_lb" {
  name                = "${local.naming_convention}-lb-public-ip"
  domain_name_label = "lbiprft"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Dynamic"
}

resource "azurerm_lb" "load_balancer" {
  name                = "${local.naming_convention}-lb"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip_lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool_lb" {
  name                = "BackEndAddressPool"
  loadbalancer_id     = azurerm_lb.load_balancer.id
}

resource "azurerm_network_interface_backend_address_pool_association" "backend_association" {
    network_interface_id      = azurerm_network_interface.front_nic.id
    ip_configuration_name     = "public"
    backend_address_pool_id   = azurerm_lb_backend_address_pool.backend_pool_lb.id 
}

resource "azurerm_network_security_group" "nsg" {
  name                = "myNetworkSecurityGroup"
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
    source_address_prefix      = "200.3.193.77"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowMyIpAddressCustom80Inbound"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "161.18.74.141/32"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.front_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
*/