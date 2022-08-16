provider "azurerm" {
  
  subscription_id = var.subscriptionId
  client_id       = var.clientId
  client_secret   = var.clientSecret
  tenant_id       = var.tenantId
  environment     = "usgovernment"
  features {}
}
#File =template.tf


resource "azurerm_resource_group" "main" {
  name     = var.resourceGroup
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = var.prefix-network
  address_space       = [var.address_space]
  location            = "azurerm_resource_group.main.location"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = var.prefix-subnet
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = var.subnet_prefix
}

resource "azurerm_network_interface" "main" {
  name                = "var.prefix-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = var.prefix-ipconfiguration
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_virtual_machine" "main" {
  name                  =  "Check4"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = var.vmSize

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.hostname
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_public_ip" "test" {
  name                = var.prefix-PublicIp
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"

  tags = {
    environment = "staging"
  }
}
#File =var.tf
variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "sNowyouseeme"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created"
}

variable "test2" {
  description = "administrator user name"
  default     = "vmadmin"
}

variable "dm" {}

variable "subscriptionId" {}
variable "clientId" {}
variable "clientSecret" {}
variable "resourceGroup" {}
variable "tenantId" {}
variable "vmSize" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_D1_v2"
}
variable "admin_username" {
  description = "administrator user name"
  default     = "vmadmin"
}

variable "admin_password" {
  description = "administrator password (recommended to disable password auth)"
  default = "admin01!"
}
variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}
variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}
variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "Canonical"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "16.04-LTS"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}
variable "hostname" {
  description = "VM name referenced also in storage-related names."
  default="tf"
}
