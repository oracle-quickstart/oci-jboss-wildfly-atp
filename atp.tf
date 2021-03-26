## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

################
# ATP database #
################

module "atp_db" {
  source         = "./modules/atp/"
  provision_atp  = var.provision_atp
  atp_private_subnet = var.atp_private_subnet
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  subnet_id      = module.db_private_subnet.id
  admin_password = var.atp_admin_password
  cpu_core_count = var.atp_cpu_core_count
  display_name   = var.atp_display_name
  db_name        = var.atp_db_name
  storage_tbs    = var.atp_storage_tbs
  autoscaling    = var.atp_autoscaling
}