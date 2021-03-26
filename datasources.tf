## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Latest Oracle Linux image
module "latest_ol8" {
  source                   = "./modules/datasources/images/"
  compartment_id           = var.compartment_id
  display_name             = "Oracle-Linux-8.3-2021.01.12-0"
}

# Availability domains
module "ADs" {
  source         = "./modules/datasources/availability_domains/"
  compartment_id = var.compartment_id
}
# Fault domain map per availability domain
module "fds" {
  source         = "./modules/datasources/domain/"
  compartment_id = var.compartment_id
  ad_names       = module.ADs.ad_names
}
