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