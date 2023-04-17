variable "resource_group_name" {
  description= "Name for resource group"
  default = "rg"
  type=string
}
variable "location" {
  description= "Azure location"
  default="East US"
}
variable "environment" {
  description = "environment name"
  default = "dev"
  type =string
}
variable "service" {
  description= "service name"
  default = "prft"
  type = string
}
variable "virtual_network_name" {
   description= "Virtual network name"
   default = "vnet"
   type=string
}

variable "frontend_ports" {
  type = map(object({
    name = string
    port = number
  }))
}
variable "backend_address_pool" {
  type = map(object({
    name = string
  }))
}
variable "http_listeners" {
  type = map(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port_name             = string
    protocol                       = string
  }))
}
variable "request_routing_rule" {
  type = map(object({
    name                       = string
    rule_type                  = string
    http_listener_name         = string
    backend_address_pool_name  = string
    backend_http_settings_name = string
   
  }))
}
variable "frontend_port_name_zipkin" {
  type = string
}

variable "backend_address_pool_name_zipkin" {
  type = string
}

variable "http_setting_name_zipkin" {
  type = string
}

variable "listener_name_zipkin" {
  type = string
}

variable "request_routing_rule_zipkin_name" {
  type = string
}

variable "frontend_port_name_users" {
  type = string
}

variable "backend_address_pool_name_users" {
  type = string
}

variable "http_setting_name_users" {
  type = string
}

variable "listener_name_users" {
  type = string
}

variable "request_routing_rule_users_name" {
  type = string
}