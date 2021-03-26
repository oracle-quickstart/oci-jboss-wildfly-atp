## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "public_ip" {
    value = zipmap(oci_core_instance.compute[*].display_name, oci_core_instance.compute[*].public_ip)
}

output "public_ips" {
    value = oci_core_instance.compute[*].public_ip
}
output "private_ip" {
    value = zipmap(oci_core_instance.compute[*].display_name, oci_core_instance.compute[*].private_ip)
}

output "private_ips" {
    value = oci_core_instance.compute[*].private_ip
}