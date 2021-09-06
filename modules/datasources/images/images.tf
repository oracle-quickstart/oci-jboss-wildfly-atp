## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "compartment_id" {}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "8.4"
}

variable "shape" {
  description = "Operating system version for all Linux instances"
  default     = "VM.Standard.E2.1"
}

data "oci_core_images" "images" {
  compartment_id           = var.compartment_id
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

output "image_id" {
  value = lookup(data.oci_core_images.images.images[0], "id")
}
