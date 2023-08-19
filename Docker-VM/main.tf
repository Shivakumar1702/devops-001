terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location

}

locals {
  rgname   = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnetname
  location            = local.location
  resource_group_name = local.rgname
  address_space       = [var.address_space]

}

locals {
  vnet = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "snet" {
  name                 = var.snetname
  resource_group_name  = local.rgname
  virtual_network_name = local.vnet
  address_prefixes     = [var.address_prefixes]
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsgname
  location            = local.location
  resource_group_name = local.rgname
}

locals {
  nsgname = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "nsr1" {

  name                        = "rule1"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.rgname
  network_security_group_name = local.nsgname
}

resource "azurerm_network_security_rule" "nsr2" {

  name                        = "rule2"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.rgname
  network_security_group_name = local.nsgname

}

resource "azurerm_network_security_rule" "nsr3" {

  name                        = "rule3"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.rgname
  network_security_group_name = local.nsgname

}

resource "azurerm_subnet_network_security_group_association" "snetass" {
  subnet_id                 = azurerm_subnet.snet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

}

resource "azurerm_public_ip" "ip" {
  name                = var.ipname
  resource_group_name = local.rgname
  location            = local.location
  allocation_method   = "Dynamic"

}

resource "azurerm_network_interface" "nic" {
  name                = var.nicname
  resource_group_name = local.rgname
  location            = local.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }

}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                            = var.vmname
  resource_group_name             = local.rgname
  location                        = local.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  network_interface_ids           = [azurerm_network_interface.nic.id]
  admin_password                  = "Shiva@170296"
  disable_password_authentication = false
  custom_data                     = filebase64("./docker.tpl")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

output "public_ip" {
  value = azurerm_public_ip.ip.ip_address
}