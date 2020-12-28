# Configure in here the provider plugin.
provider "azurerm" {
  version         = "~>2.16.0"
  subscription_id = var.subscription_id
  features {}
}

# Following configs are implicit dependency. Which means azure and terraform already
# knows which resources must be created in which order

# Create new resource group
resource "azurerm_resource_group" "octopodami-rg" {
  name     = "octopodami-rg"
  location = var.location

  tags = {
    Environment = "Terraform training"
    Team        = "DevOps"
  }
}

# network resource.
resource "azurerm_virtual_network" "octopodami-vnet" {
  name                = "octopodami-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.octopodami-rg.name

  tags = {
    Environment = "Terraform training"
    Team        = "DevOps"
  }
}

# the subnet
resource "azurerm_subnet" "octopodami-subnet" {
  name                 = "octopodami-subnet"
  resource_group_name  = azurerm_resource_group.octopodami-rg.name
  virtual_network_name = azurerm_virtual_network.octopodami-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# public ip
resource "azurerm_public_ip" "octopodami-publicip" {
  name                = "octopodami-publicip"
  location            = var.location
  resource_group_name = azurerm_resource_group.octopodami-rg.name
  allocation_method   = "Static"

  tags = {
    Environment = "Terraform Education"
    Team        = "DevOps"
  }
}

# get data of public ip created for the output.
data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.octopodami-publicip.name
  resource_group_name = azurerm_virtual_machine.octopodami-vm.resource_group_name
}

# network security group
resource "azurerm_network_security_group" "octopodami-nsg" {
  name                = "octopodami-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.octopodami-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Terraform Education"
    Team        = "DevOps"
  }
}

# network interface
resource "azurerm_network_interface" "octopodami-nic" {
  name                = "octopodami-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.octopodami-rg.name

  ip_configuration {
    name                          = "octopodami-nic-ip"
    subnet_id                     = azurerm_subnet.octopodami-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.octopodami-publicip.id
  }

  tags = {
    Environment = "Terraform Education"
    Team        = "DevOps"
  }
}

# the vm
resource "azurerm_virtual_machine" "octopodami-vm" {
  name                  = "octopodami-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.octopodami-rg.name
  network_interface_ids = [azurerm_network_interface.octopodami-nic.id]
  vm_size               = "Standard_B1ms"

  storage_os_disk {
    name              = "octopodami-vm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "octopodami-vm-training"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
    connection {
      host     = azurerm_public_ip.octopodami-publicip.ip_address
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
    }

    inline = [
      "cat /etc/os-release",
      "sudo apt update",
      "sudo apt -y install pwgen htop vim git"
    ]
  }

  tags = {
    Environment = "Terraform Education"
    Team        = "DevOps"
  }

}

# outputs
# ----- [PUBLICIP]----------
output "instance-public-ip" {
  value = azurerm_public_ip.octopodami-publicip.ip_address
}