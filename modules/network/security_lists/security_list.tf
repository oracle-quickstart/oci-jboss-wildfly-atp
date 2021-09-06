## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "vcn_id" {}
variable "ingress_security_rules" {
  default = []
}
variable "display_name" {
  default = "Custom Security List"
}

variable "defined_tags" {
  default = ""
}

data "oci_core_vcn" "vcn" {
  vcn_id = var.vcn_id
}
resource "oci_core_security_list" "security-list" {
  compartment_id = data.oci_core_vcn.vcn.compartment_id

  display_name  = var.display_name
  freeform_tags = {}

  dynamic "ingress_security_rules" {
    for_each = [for rule in var.ingress_security_rules : rule.ingress_security_rules]
    content {
      description = ingress_security_rules.value.description
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = ingress_security_rules.value.source_type
      stateless   = ingress_security_rules.value.stateless
      dynamic "tcp_options" {
        # a bit of a hack here, as it will end up creating 2 of the same content that gets merged into one
        for_each = length(ingress_security_rules.value.tcp_options.*) > 0 ? [1] : []
        content {
          min = ingress_security_rules.value.tcp_options.min
          max = ingress_security_rules.value.tcp_options.max
        }
      }
    }
  }
  vcn_id       = var.vcn_id
  defined_tags = var.defined_tags
}

output "id" {
  value = oci_core_security_list.security-list.id
}
