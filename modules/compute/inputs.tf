## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable display_name {
  default = "test"
}
variable prefix {
  default = "jboss"
}
variable domain {
  default = ""
}
variable vm_shape {
  default = "VM.Standard.E2.1"
}
variable node_count {
  default = 1
}
variable subnet_id {}
variable source_id {}
variable ssh_authorized_keys {}
variable fd_map {}
variable cloud_init {
  default = ""
}