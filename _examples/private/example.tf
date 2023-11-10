provider "azurerm" {
  features {}
}

module "resource_group" {
  source      = "git::https://github.com/opz0/terraform-azure-resource-group.git?ref=v1.0.0"
  name        = "appvm-private"
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


module "load-balancer" {
  source = "../.."
  #Labels
  name        = "app"
  environment = "test"
  #Common
  enabled             = true
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  # Load Balancer
  frontend_name                          = "mypublicIP"
  frontend_private_ip_address_allocation = "Static"
  frontend_private_ip_address            = "10.0.1.6"
  lb_sku                                 = "Standard"
  frontend_subnet_id                     = module.subnet.default_subnet_id
  # Backend Pool
  is_enable_backend_pool = false
  # network_interaface_id_association = ""
  # ip_configuration_name_association = ""
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
