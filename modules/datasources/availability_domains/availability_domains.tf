## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Get a list of Availability Domains names and number of ADs

# Variables
variable "compartment_id" {}

# Datasources
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.compartment_id
} 

# Outputs
output "ad_names" {
  value = data.oci_identity_availability_domains.ADs.availability_domains[*].name
}
output "num_ads" {
  value = length(data.oci_identity_availability_domains.ADs.availability_domains)
}
