provider "azurerm" {
  features {}
}

module "resource_group" {
  source      = "git::https://github.com/opz0/terraform-azure-resource-group.git?ref=v1.0.0"
  name        = "load-basic"
  environment = "tested"
  location    = "North Europe"
}

module "vnet" {
  source              = "git::https://github.com/opz0/terraform-azure-vnet.git?ref=v1.0.0"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}

module "subnet" {
  source = "git::https://github.com/opz0/terraform-azure-subnet.git?ref=v1.0.0"

  name                 = "app"
  environment          = "test"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.name

  #subnet
  subnet_names    = ["subnet2"]
  subnet_prefixes = ["10.0.1.0/24"]

  # route_table
  enable_route_table = true
  route_table_name   = "default_subnet"
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}

module "network_security_group" {
  source                  = "git::https://github.com/opz0/terraform-azure-network-security-group.git?ref=v1.0.0"
  name                    = "app"
  environment             = "test"
  resource_group_name     = module.resource_group.resource_group_name
  resource_group_location = module.resource_group.resource_group_location
  subnet_ids              = [module.subnet.default_subnet_id]
  inbound_rules = [
    {
      name                       = "ssh"
      priority                   = 101
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "0.0.0.0/0"
      destination_port_range     = "*"
      description                = "ssh allowed port"
    },
    {
      name                       = "https"
      priority                   = 102
      access                     = "Allow"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "80,443"
      destination_address_prefix = "0.0.0.0/0"
      destination_port_range     = "22"
      description                = "ssh allowed port"
    }
  ]
}

module "virtual-machine" {
  source = "git::https://github.com/opz0/terraform-azure-virtual-machine.git?ref=v1.0.0"
  #Tags
  name        = "app"
  environment = "test"
  label_order = ["environment", "name"]
  #Common
  is_vm_linux                     = true
  enabled                         = true
  machine_count                   = 2
  resource_group_name             = module.resource_group.resource_group_name
  location                        = module.resource_group.resource_group_location
  disable_password_authentication = true
  #Network Interface
  subnet_id                     = [module.subnet.default_subnet_id]
  private_ip_address_version    = "IPv4"
  private_ip_address_allocation = "Dynamic"
  availability_set_enabled      = true
  platform_update_domain_count  = 7
  platform_fault_domain_count   = 3
  #Public IP
  public_ip_enabled = true
  sku               = "Standard"
  allocation_method = "Static"
  ip_version        = "IPv4"
  #Virtual Machine
  vm_size        = "Standard_B1s"
  public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBaGAWXkDdhpEcj61gTFCV0Y97sW2YX4aD0ydNsU44yl/OGA14P7sBnXCoDhIHp7xrIJeKuPuoCli9sO7zZXhICzYvIczX3U8oOtPifje08glKbYT00mrl4lGnfQOlr50mJuTIY6b7ocs9oGi1S+oH/H0r+pEr/9gJgdkk7jE/kQOY9OfC/tcoi0dgeYKFJYe2FCU6LI+ZZA6lsz31Zl1ymv1JnwCck7yY+OFtqHxjVsmDeFz99GLmhnlAB2DOTgaOJer4gjA6JQ6Ii97KuZiIWgCkW8DQcUNYhWhZHyH9w5KT8Ug6dlIjM1w95fadkHjpt0J1QEzPQp7lvhNj1IVOnZYfu5rw5HHHyhVoglSXbCcXj9xPyEH5Yq5wdYNBgi/Q6c31riOANppfn2R++VUMaVBPyglSrKS3r39EgwTnAwK1luS13YZAN8jh2p3r9hfCD5mw23g8Z5l1qrmXM7yye53jbEUEcCShV2TGdFA2cydWwR1G1/n7DM61+EFHLSc= arjun@arjun"
  admin_username = "ubuntu"
  # admin_password                = "P@ssw0rd!123!" # It is compulsory when disable_password_authentication = false
  caching                         = "ReadWrite"
  disk_size_gb                    = 30
  storage_image_reference_enabled = true
  image_publisher                 = "Canonical"
  image_offer                     = "0001-com-ubuntu-server-focal"
  image_sku                       = "20_04-lts"
  image_version                   = "latest"
  enable_disk_encryption_set      = false
  #key_vault_id                   = key_vault_idmodule.vault.id
  addtional_capabilities_enabled = true
  ultra_ssd_enabled              = false
  enable_encryption_at_host      = false
  key_vault_rbac_auth_enabled    = false
  #  data_disks = [
  #    {
  #      name                 = "disk8"
  #      disk_size_gb         = 100
  #      storage_account_type = "StandardSSD_LRS"
  #    }
  #  ]

  # Extension
  extensions = [{
    extension_publisher            = "Microsoft.Azure.Extensions"
    extension_name                 = "hostname"
    extension_type                 = "CustomScript"
    extension_type_handler_version = "2.0"
    auto_upgrade_minor_version     = true
    automatic_upgrade_enabled      = false
    settings                       = <<SETTINGS
    {
      "commandToExecute": "hostname && uptime"
     }
     SETTINGS
  }]

}


module "load-balancer" {
  source = "../.."
  #Labels
  name        = "app"
  environment = "test"
  #Common
  enabled             = true
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  #Load Balancer
  frontend_name = "mypublicIP"
  lb_sku        = "Basic"
  # Public IP
  ip_count          = 1
  allocation_method = "Static"
  sku               = "Basic"
  nat_protocol      = "Tcp"
  public_ip_enabled = true
  ip_version        = "IPv4"
  #Backend Pool
  is_enable_backend_pool = true
  #network_interaface_id_association = [module.virtual-machine.network_interface_id[0], module.virtual-machine.network_interface_id[1]]
  ip_configuration_name_association = ["app-test-public-ip-1", "app-test-public-ip-2"]
  #virtual_network_id                = module.vnet.vnet_id[0]
  remote_port = {
    ssh   = ["Tcp", "22"]
    https = ["Tcp", "80"]
  }

  lb_port = {
    http  = ["80", "Tcp", "80"]
    https = ["443", "Tcp", "443"]
  }

  lb_probe = {
    http  = ["Tcp", "80", ""]
    http2 = ["Http", "1443", "/"]
  }

  depends_on = [module.resource_group]
}

