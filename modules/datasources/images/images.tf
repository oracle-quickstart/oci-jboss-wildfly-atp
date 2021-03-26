## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable compartment_id {}
variable display_name {
    default = "Oracle-Linux-8.3-2021.01.12-0"
}

data "oci_core_images" "images" {
    #Required
    compartment_id = var.compartment_id

    #Optional
    state = "AVAILABLE"
    display_name = var.display_name
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}
output "image_id" {
    value = data.oci_core_images.images.images[0].id
}
