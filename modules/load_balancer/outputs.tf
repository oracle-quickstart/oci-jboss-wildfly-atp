## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  empty_list = tolist([""])
}
output "lb_ip" {
  value = coalescelist(oci_load_balancer_load_balancer.jboss_loadbalancer[*].ip_addresses, local.empty_list)
}

output "lb_type" {
  value = oci_load_balancer_load_balancer.jboss_loadbalancer[*].ip_address_details
}
