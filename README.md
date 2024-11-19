# Terraform-azure-load-balancer

# Terraform Azure Cloud Load-Balancer Module

## Table of Contents
- [Introduction](#introduction)
- [Usage](#usage)
- [Examples](#examples)
- [Author](#author)
- [License](#license)
- [Inputs](#inputs)
- [Outputs](#outputs)


## Introduction
This repository contains Terraform code to deploy resources on Microsoft Azure, including a resource group and a virtual network and load-balancer.

## Usage
To use this module, you should have Terraform installed and configured for AZURE. This module provides the necessary Terraform configuration
for creating AZURE resources, and you can customize the inputs as needed. Below is an example of how to use this module:

# Examples

# Example: basic

```hcl
module "basic-load-balancer" {
  source              = "cypik/load-balancer/azure"
  version             = "1.0.2"
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
  source                                = "cypik/load-balancer/azure"
  version                               = "1.0.2"
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
  source                            = "cypik/load-balancer/azure"
  version                           = "1.0.2"
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

# Examples
For detailed examples on how to use this module, please refer to the [examples](https://github.com/cypik/terraform-azure-lb/blob/master/_examples) directory within this repository.

# License
This Terraform module is provided under the **MIT** License. Please see the [LICENSE](https://github.com/cypik/terraform-azure-lb/blob/master/LICENSE) file for more details.

# Author
Your Name
Replace **MIT** and **Cypik** with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.2.0 |

## Providers

| Name | Version    |
|------|------------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.2.0   |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_labels"></a> [labels](#module\_labels) | cypik/labels/azure | 1.0.2 |

## Resources

| Name | Type |
|------|------|
| [azurerm_lb.load-balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.load-balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_nat_rule.load-balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_nat_rule) | resource |
| [azurerm_lb_probe.load-balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.load-balancer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_network_interface_backend_address_pool_association.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_public_ip.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocation_method"></a> [allocation\_method](#input\_allocation\_method) | Defines the allocation method for this IP address. Possible values are Static or Dynamic. | `string` | `""` | no |
| <a name="input_backendpoolname"></a> [backendpoolname](#input\_backendpoolname) | (Required) Specifies the name of the Backend Address Pool. Changing this forces a new resource to be created. | `string` | `"test-backendpool"` | no |
| <a name="input_create"></a> [create](#input\_create) | Used when creating the Resource Group. | `string` | `"60m"` | no |
| <a name="input_ddos_protection_mode"></a> [ddos\_protection\_mode](#input\_ddos\_protection\_mode) | (Optional) The DDoS protection mode of the public IP. Possible values are `Disabled`, `Enabled`, and `VirtualNetworkInherited`. Defaults to `VirtualNetworkInherited`. | `string` | `"VirtualNetworkInherited"` | no |
| <a name="input_delete"></a> [delete](#input\_delete) | Used when deleting the Resource Group. | `string` | `"60m"` | no |
| <a name="input_domain_name_label"></a> [domain\_name\_label](#input\_domain\_name\_label) | Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system. | `string` | `null` | no |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | (Optional) Specifies the Edge Zone within the Azure Region where this Public IP and Load Balancer should exist. Changing this forces new resources to be created. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the module creation. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_frontend_name"></a> [frontend\_name](#input\_frontend\_name) | (Required) Specifies the name of the frontend ip configuration. | `string` | `"myip"` | no |
| <a name="input_frontend_private_ip_address"></a> [frontend\_private\_ip\_address](#input\_frontend\_private\_ip\_address) | (Optional) Private ip address to assign to frontend. Use it with type = private | `string` | `""` | no |
| <a name="input_frontend_private_ip_address_allocation"></a> [frontend\_private\_ip\_address\_allocation](#input\_frontend\_private\_ip\_address\_allocation) | (Optional) Frontend ip allocation type (Static or Dynamic) | `string` | `"Dynamic"` | no |
| <a name="input_frontend_private_ip_address_version"></a> [frontend\_private\_ip\_address\_version](#input\_frontend\_private\_ip\_address\_version) | (Optional) The version of IP that the Private IP Address is. Possible values are `IPv4` or `IPv6`. | `string` | `null` | no |
| <a name="input_frontend_subnet_id"></a> [frontend\_subnet\_id](#input\_frontend\_subnet\_id) | (Optional) Frontend subnet id to use when in private mode | `string` | `null` | no |
| <a name="input_idle_timeout_in_minutes"></a> [idle\_timeout\_in\_minutes](#input\_idle\_timeout\_in\_minutes) | Specifies the timeout for the TCP idle connection. The value can be set between 4 and 60 minutes. | `number` | `10` | no |
| <a name="input_ip_configuration_name_association"></a> [ip\_configuration\_name\_association](#input\_ip\_configuration\_name\_association) | (Required) Ip Configuration name for Network Interaface Association with Load Balancer. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_ip_count"></a> [ip\_count](#input\_ip\_count) | Number of Public IP Addresses to create. | `number` | `0` | no |
| <a name="input_ip_version"></a> [ip\_version](#input\_ip\_version) | The IP Version to use, IPv6 or IPv4. | `string` | `""` | no |
| <a name="input_is_enable_backend_pool"></a> [is\_enable\_backend\_pool](#input\_is\_enable\_backend\_pool) | Backend Pool Configuration for the Load Balancer. | `bool` | `false` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| <a name="input_lb_port"></a> [lb\_port](#input\_lb\_port) | Protocols to be used for lb rules. Format as [frontend\_port, protocol, backend\_port] | `map(any)` | `{}` | no |
| <a name="input_lb_probe"></a> [lb\_probe](#input\_lb\_probe) | (Optional) Protocols to be used for lb health probes. Format as [protocol, port, request\_path] | `map(any)` | `{}` | no |
| <a name="input_lb_probe_interval"></a> [lb\_probe\_interval](#input\_lb\_probe\_interval) | Interval in seconds the load balancer health probe rule does a check | `number` | `5` | no |
| <a name="input_lb_probe_unhealthy_threshold"></a> [lb\_probe\_unhealthy\_threshold](#input\_lb\_probe\_unhealthy\_threshold) | Number of times the load balancer health probe has an unsuccessful attempt before considering the endpoint unhealthy. | `number` | `2` | no |
| <a name="input_lb_sku"></a> [lb\_sku](#input\_lb\_sku) | (Optional) The SKU of the Azure Load Balancer. Accepted values are Basic and Standard. | `string` | `"Basic"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location where resource should be created. | `string` | `""` | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'info@cypik.com' | `string` | `"info@cypik.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_nat_protocol"></a> [nat\_protocol](#input\_nat\_protocol) | (Required) The protocol of Load Balancer's NAT rule. | `string` | `"Tcp"` | no |
| <a name="input_network_interaface_id_association"></a> [network\_interaface\_id\_association](#input\_network\_interaface\_id\_association) | (Required) Network Interaface id for Network Interface Association with Load Balancer. | `list(string)` | `[]` | no |
| <a name="input_public_ip_enabled"></a> [public\_ip\_enabled](#input\_public\_ip\_enabled) | Whether public IP is enabled. | `bool` | `false` | no |
| <a name="input_public_ip_prefix_id"></a> [public\_ip\_prefix\_id](#input\_public\_ip\_prefix\_id) | If specified then public IP address allocated will be provided from the public IP prefix resource. | `string` | `null` | no |
| <a name="input_read"></a> [read](#input\_read) | Used when retrieving the Resource Group. | `string` | `"5m"` | no |
| <a name="input_remote_port"></a> [remote\_port](#input\_remote\_port) | Protocols to be used for remote vm access. [protocol, backend\_port].  Frontend port will be automatically generated starting at 50000 and in the output. | `map(any)` | `{}` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Terraform current module repo | `string` | `"https://github.com/cypik/terraform-azure-lb"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the virtual network. | `string` | `""` | no |
| <a name="input_reverse_fqdn"></a> [reverse\_fqdn](#input\_reverse\_fqdn) | A fully qualified domain name that resolves to this public IP address. If the reverseFqdn is specified, then a PTR DNS record is created pointing from the IP address in the in-addr.arpa domain to the reverse FQDN. | `string` | `""` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic. | `string` | `"Basic"` | no |
| <a name="input_update"></a> [update](#input\_update) | Used when updating the Resource Group. | `string` | `"60m"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | A collection containing the availability zone to allocate the Public IP in. | `list(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_lb_backend_address_pool_id"></a> [azurerm\_lb\_backend\_address\_pool\_id](#output\_azurerm\_lb\_backend\_address\_pool\_id) | the id for the azurerm\_lb\_backend\_address\_pool resource |
| <a name="output_azurerm_lb_frontend_ip_configuration"></a> [azurerm\_lb\_frontend\_ip\_configuration](#output\_azurerm\_lb\_frontend\_ip\_configuration) | the frontend\_ip\_configuration for the azurerm\_lb resource |
| <a name="output_azurerm_lb_id"></a> [azurerm\_lb\_id](#output\_azurerm\_lb\_id) | the id for the azurerm\_lb resource |
| <a name="output_azurerm_lb_nat_rule_ids"></a> [azurerm\_lb\_nat\_rule\_ids](#output\_azurerm\_lb\_nat\_rule\_ids) | the ids for the azurerm\_lb\_nat\_rule resources |
| <a name="output_azurerm_lb_probe_ids"></a> [azurerm\_lb\_probe\_ids](#output\_azurerm\_lb\_probe\_ids) | the ids for the azurerm\_lb\_probe resources |
| <a name="output_azurerm_public_ip_address"></a> [azurerm\_public\_ip\_address](#output\_azurerm\_public\_ip\_address) | the ip address for the azurerm\_lb\_public\_ip resource |
| <a name="output_azurerm_public_ip_id"></a> [azurerm\_public\_ip\_id](#output\_azurerm\_public\_ip\_id) | the id for the azurerm\_lb\_public\_ip resource |
<!-- END_TF_DOCS -->