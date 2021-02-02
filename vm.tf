resource "azurerm_public_ip" "linux-vm-ip" {
  allocation_method = "Dynamic"
  name = "${var.project_name}-kubectl-vm-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku = "Basic"
}

resource "azurerm_network_interface" "net-interface" {
  name                = "${var.project_name}-kubectl-net-interface"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.linux-vm-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "linux-kubectl" {
  name                = "${var.project_name}-kubectl"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.net-interface.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

output "jumpbox_ip" {
  value       = azurerm_linux_virtual_machine.linux-kubectl.public_ip_address
}