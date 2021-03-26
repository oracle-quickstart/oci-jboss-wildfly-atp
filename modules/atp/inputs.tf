## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable provision_atp {
    type = bool
    default = true
}
variable compartment_id {
    type = string
}
variable admin_password {
    type = string
}
variable cpu_core_count {
    type = number
    default = 1
}
variable display_name {
    type = string
}
variable db_name {
    type = string
}
variable storage_tbs {
    type = number
    default = 1
}
variable autoscaling {
    type = bool
    default = false
}
variable vcn_id {
    type = string
}
variable subnet_id {
    type = string
    default = null
}
variable atp_private_subnet {
    type = string
}