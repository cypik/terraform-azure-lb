# terraform-azure-load-balancer
# Terraform Azure Infrastructure

This Terraform configuration defines an Azure infrastructure using the Azure provider.

## Table of Contents

- [Introduction](#introduction)
- [Usage](#usage)
- [Module Inputs](#module-inputs)
- [Module Outputs](#module-outputs)
- [Examples](#examples)
- [License](#license)

## Introduction
This repository contains Terraform code to deploy resources on Microsoft Azure, including a resource group and a virtual network and load-balancer.

## Usage
To use this module, you should have Terraform installed and configured for AZURE. This module provides the necessary Terraform configuration
for creating AZURE resources, and you can customize the inputs as needed. Below is an example of how to use this module:

# Examples

# Example: basic

```hcl
module "basic-load-balancer" {
  source              = "git::https://github.com/opz0/terraform-azure-lb.git?ref=v1.0.0"
  #Labels
  name                = "app"
  environment         = "test"
  #Common
  enabled             = true
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  #Load Balancer
  frontend_name       = "mypublicIP"
  lb_sku              = "Basic"
  # Public IP
  ip_count            = 1
  allocation_method   = "Static"
  sku                 = "Basic"
  nat_protocol        = "Tcp"
  public_ip_enabled   = true
  ip_version          = "IPv4"
  #Backend Pool
  is_enable_backend_pool = true
  ip_configuration_name_association = ["app-test-public-ip-1", "app-test-public-ip-2"]
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
```
# Example: private

```hcl
module "private-load-balancer" {
  source                                = "git::https://github.com/opz0/terraform-azure-lb.git?ref=v1.0.0"
  #Labels
  name                                  = "app"
  environment                           = "test"
  #Common
  enabled                                = true
  resource_group_name                    = module.resource_group.resource_group_name
  location                               = module.resource_group.resource_group_location
  # Load Balancer
  frontend_name                          = "mypublicIP"
  frontend_private_ip_address_allocation = "Static"
  frontend_private_ip_address            = "10.0.1.6"
  lb_sku                                 = "Standard"
  frontend_subnet_id                     = module.subnet.default_subnet_id
  # Backend Pool
  is_enable_backend_pool = false
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
```
# Example: public

```hcl
module "public-load-balancer" {
  source                            = "git::https://github.com/opz0/terraform-azure-lb.git?ref=v1.0.0"
  #Labels
  name                              = "app"
  environment                       =  "test"
  #Common
  enabled                           = true
  resource_group_name               = module.resource_group.resource_group_name
  location                          = module.resource_group.resource_group_location
  #Load Balancer
  frontend_name                     = "mypublicIP"
  lb_sku                            = "Standard"
  #Public IP
  ip_count                          = 1
  allocation_method                 = "Static"
  sku                               = "Standard"
  nat_protocol                      = "Tcp"
  public_ip_enabled                 = true
  ip_version                        = "IPv4"
  #Backend Pool
  is_enable_backend_pool            = true
  ip_configuration_name_association = ["test-app-ip-configuration-1", "test-app-ip-configuration-2"]
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
```

This example demonstrates how to create various AZURE resources using the provided modules. Adjust the input values to suit your specific requirements.

## Module Inputs
The following input variables can be configured:

- 'name': Specifies the name of the Load Balancer.
- 'resource_group_name': The name of the Resource Group in which to create the Load Balancer.
- 'location': Specifies the supported Azure Region where the Load Balancer should be created.
- 'sku ': The SKU tier of this Load Balancer.

## Module Outputs
This module provides the following outputs:

- 'id': The Load Balancer ID.
- 'inbound_nat_rules': The list of IDs of inbound rules that use this frontend IP.


# Examples
For detailed examples on how to use this module, please refer to the 'examples' directory within this repository.

# License
This Terraform module is provided under the '[License Name]' License. Please see the [LICENSE](https://github.com/opz0/terraform-azure-load-balancer/blob/readme/LICENSE) file for more details.

# Author
Your Name
Replace '[License Name]' and '[Your Name]' with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.
