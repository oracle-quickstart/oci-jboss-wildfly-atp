## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Latest Oracle Linux image
module "latest_ol8_jboss" {
  source           = "./modules/datasources/images/"
  compartment_id   = var.compartment_id
  instance_os      = "Oracle Linux"
  linux_os_version = "8"
  shape            = var.jboss_vm_shape
}

# Latest Oracle Linux image
module "latest_ol8_bastion" {
  source           = "./modules/datasources/images/"
  compartment_id   = var.compartment_id
  instance_os      = "Oracle Linux"
  linux_os_version = "8"
  shape            = var.bastion_vm_shape
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

data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}
