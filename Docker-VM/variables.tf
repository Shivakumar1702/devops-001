variable "name" {
  type    = string
  default = "resource-group-001"

}

variable "location" {
  type    = string
  default = "eastus"

}

variable "vnetname" {
  type    = string
  default = "vnet-001"

}

variable "address_space" {
  type    = string
  default = "10.0.0.0/16"

}

variable "snetname" {
  type    = string
  default = "snet-001"

}

variable "address_prefixes" {
  type    = string
  default = "10.0.1.0/24"

}

variable "nsgname" {
  type    = string
  default = "nsg-001"

}

variable "ipname" {
  type    = string
  default = "public-ip-001"

}

variable "nicname" {
  type    = string
  default = "nic-001"

}

variable "vmname" {
  type    = string
  default = "docker-linux-001"

}