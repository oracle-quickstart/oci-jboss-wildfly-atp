## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable provision_atp {
    type = bool
    default = true
}
variable ssh_private_key {
    type = string
}
variable instance_ips {
    type = list(string)
}
variable bastion_host {
    type = string
}
variable atp_db_id {
    type = string
}
