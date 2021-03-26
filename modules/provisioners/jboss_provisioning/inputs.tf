## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable ssh_private_key {
    type = string
}
variable instance_ips {
    type = list(string)
}
variable bastion_host {
    type = string
}
variable create_ds {
    type = bool
    default = true
}
variable admin_username {
    type = string
}
variable admin_password {
    type = string
}
variable jboss_username {
    type = string
}
variable jboss_password {
    type = string
}
variable domain_mode {
    type = bool
}
variable atp_username {
    type = string
}
variable atp_password {
    type = string
}
variable atp_db_name {
    type = string
}
variable ds_name {
    type = string
}
