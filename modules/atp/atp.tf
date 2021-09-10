## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_database_autonomous_database" "atp_database" {
  count                    = var.provision_atp ? 1 : 0
  admin_password           = var.admin_password
  compartment_id           = var.compartment_id
  cpu_core_count           = var.cpu_core_count
  data_storage_size_in_tbs = var.storage_tbs
  db_name                  = var.db_name
  display_name             = var.display_name
  is_auto_scaling_enabled  = var.autoscaling
  nsg_ids                  = var.atp_private_subnet ? [join(",", oci_core_network_security_group.atp_security_group[*].id)] : null
  subnet_id                = var.atp_private_subnet ? var.subnet_id : null
  is_dedicated             = false
  defined_tags             = var.defined_tags
}

output "id" {
  value = join(",", oci_database_autonomous_database.atp_database[*].id)
}

output "private_ip" {
  value = var.atp_private_subnet ? join(",", oci_database_autonomous_database.atp_database[*].private_endpoint_ip) : ""
}
