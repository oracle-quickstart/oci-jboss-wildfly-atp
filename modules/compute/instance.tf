## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_core_subnet" "subnet" {
  subnet_id = var.subnet_id
}

data "oci_core_vcn" "vcn" {
  vcn_id = local.vcn_id
}

locals {
  compartment_id = data.oci_core_vcn.vcn.compartment_id
}

locals {
  hostname_label   = replace(lower(var.display_name), " ", "")
  assign_public_ip = data.oci_core_subnet.subnet.prohibit_public_ip_on_vnic ? false : true
  vcn_id           = data.oci_core_subnet.subnet.vcn_id
  ad_names         = keys(var.fd_map)
  num_ads          = length(var.fd_map)
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.vm_shape)
}

resource "oci_core_instance" "compute" {
  count = var.node_count

  availability_domain = element(local.ad_names, count.index)
  fault_domain        = lookup(element(var.fd_map[element(local.ad_names, count.index)], floor(count.index / local.num_ads)), "name")

  compartment_id = local.compartment_id
  display_name   = "${local.hostname_label}${count.index}"
  shape          = var.vm_shape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.vm_flex_shape_mem
      ocpus         = var.vm_flex_shape_ocpu
    }
  }

  defined_tags = var.defined_tags
  # freeform_tags = "var.freeform_tags"

  create_vnic_details {
    subnet_id = var.subnet_id
    # skip_source_dest_check = true
    assign_public_ip = local.assign_public_ip
    hostname_label   = "${local.hostname_label}${count.index}"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = var.cloud_init
    index               = count.index
    master              = "${local.hostname_label}0"
    nb_nodes            = var.node_count
    prefix              = local.hostname_label
    domain              = var.domain
  }

  source_details {
    source_type = "image"
    source_id   = var.source_id
  }

  timeouts {
    create = "10m"
  }
}
