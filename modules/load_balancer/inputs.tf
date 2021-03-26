## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "compartment_id" {}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_private_ips" {
  type = list(string)
}

variable "shape" {
  default = "400Mbps"
}

variable "name" {
  default = "jboss-loadbalancer"
}

variable "is_private" {
  type = bool
  default = false
}

variable "protocol" {
  default = "HTTP"
}
variable "http_server_port" {
  default = "8080"
}
variable "https_server_port" {
  default = "8443"
}
variable "http_listener_port" {
  default = "80"
}
variable "https_listener_port" {
  default = "443"
}

variable "use_http" { 
  type = bool
  default = true
}
variable "use_https" {
  type = bool
  default = true
}
variable "use_lb_termination" {
  type = bool
  default = false
}

variable "num_instances" {}

variable "return_code" {
  default = "200"
}

variable "policy_weight" {
  default = 1
}

variable "health_check_interval_ms" {
  default = 30000
}

variable "health_check_timeout_ms" {
  default = 10000
}
variable "health_check_path" {
  default = "/"
}
variable "add_load_balancer" {
  default = true
}

variable "backendset_name" {
  default = "jboss-backendset"
}

variable "policy" {
  default = "ROUND_ROBIN"
}

# variable "defined_tags" {
#   type = "map"
#   default = {}
# }
# variable "freeform_tags" {
#   type = "map"
#   default = {}
# }