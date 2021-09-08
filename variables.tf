## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_id" {}
#variable "fingerprint" {}
#variable "user_ocid" {}
#variable "private_key_path" {}

variable "public_subnet" {
  type    = bool
  default = true
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.1"
}

# Network
variable "vcn_cidr_block" {
  default = "10.1.0.0/16"
}

variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = "10"
}

variable "flex_lb_max_shape" {
  default = "100"
}

variable "prefix" {
  default = "jboss"
}
# JBoss instances
variable "jboss_node_count" {
  default = 1
}
variable "jboss_vm_shape" {
  default = "VM.Standard.E3.Flex"
}

variable "jboss_vm_flex_shape_ocpu" {
  default = 1
}

variable "jboss_vm_flex_shape_mem" {
  default = 10
}

variable "ssh_authorized_keys" {
  type    = string
  default = ""
}

variable "jboss_admin_username" {
  default = "admin"
}
variable "jboss_admin_password" {
  type = string
}

# Bastion
variable "bastion_vm_shape" {
  default = "VM.Standard.E3.Flex"
}

variable "bastion_vm_flex_shape_ocpu" {
  default = 1
}

variable "bastion_vm_flex_shape_mem" {
  default = 1
}

# ATP
variable "provision_atp" {
  type    = bool
  default = true
}
variable "atp_private_subnet" {
  type    = bool
  default = false
}
variable "atp_admin_password" {
  type    = string
  default = ""
}
variable "atp_display_name" {
  type    = string
  default = "JBossATP"
}
variable "atp_db_name" {
  type    = string
  default = "db"
}
variable "atp_cpu_core_count" {
  type    = number
  default = 1
}
variable "atp_storage_tbs" {
  type    = number
  default = 1
}
variable "atp_autoscaling" {
  type    = bool
  default = false
}

# JDBC connection
variable "create_jdbc_ds" {
  type    = bool
  default = true
}
variable "ds_name" {
  type    = string
  default = "OracleDS"
}
variable "atp_username" {
  type    = string
  default = ""
}
variable "atp_password" {
  type    = string
  default = ""
}

variable "domain_mode" {
  type    = bool
  default = true
}
