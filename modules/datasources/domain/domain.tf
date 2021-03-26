## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Get a list of Fault Domains and Availability domains
variable compartment_id {}
variable availability_domain {
    default = ""
}
variable ad_names {}

locals {
    ha_mode = var.availability_domain == "" ? true : false
    num_ads = length(var.ad_names)
}

# Datasources
data "oci_identity_fault_domains" "FDs" {
  count = local.num_ads
  availability_domain = element(var.ad_names, count.index)
  compartment_id      = var.compartment_id
}

# Outputs

# Map of fault domains in each availability domains for easy extraction of an AD/FD pair
output "fd_map" {
    value = zipmap(
                data.oci_identity_fault_domains.FDs[*].availability_domain, 
                data.oci_identity_fault_domains.FDs[*].fault_domains
            )
}
output "num_ads" {
  value = local.num_ads
}

# list of all fault domains
output "fd_list" {
    value = flatten(data.oci_identity_fault_domains.FDs[*].fault_domains)
}