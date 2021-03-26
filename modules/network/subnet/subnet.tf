## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Variables
variable cidr_block {}
variable compartment_id {}
variable vcn_id {}
variable display_name {}
variable is_private {
  default = true
}
variable "create_subnet" {
  default = false
}
variable security_list_ids {
  default = []
}
variable route_table_id {}

# Datasources
data "oci_core_vcn" "vcn" {
  vcn_id = var.vcn_id
}

# Resource
resource "oci_core_subnet" "subnet" {
  count = var.create_subnet ? 1 : 0
  #availability_domain = <<Optional value not found in discovery>>
  cidr_block     = var.cidr_block
  compartment_id = var.compartment_id

  dhcp_options_id = data.oci_core_vcn.vcn.default_dhcp_options_id
  display_name    = var.display_name
  dns_label       = substr(replace(replace(lower(var.display_name), " ", ""), "_", ""),0, 15)
  freeform_tags   = {}

  #ipv6cidr_block = <<Optional value not found in discovery>>
  prohibit_public_ip_on_vnic = var.is_private
  route_table_id             = var.route_table_id != null ? var.route_table_id : data.oci_core_vcn.vcn.default_route_table_id

  security_list_ids = var.security_list_ids

  vcn_id = data.oci_core_vcn.vcn.id
}

# Outputs
output "id" {
  value = join("",oci_core_subnet.subnet[*].id)
}
output "cidr_block" {
  value = join("",oci_core_subnet.subnet[*].cidr_block)
}
output "domain" {
  value = join("",oci_core_subnet.subnet[*].subnet_domain_name)
}