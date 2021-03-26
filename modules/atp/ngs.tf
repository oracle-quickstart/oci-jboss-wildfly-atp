## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_network_security_group" "atp_security_group" {
    count = var.provision_atp ? 1: 0
    compartment_id = var.compartment_id
    vcn_id = var.vcn_id
    display_name = "ATPDB_NSG"
}

resource "oci_core_network_security_group_security_rule" "atp_ngs_ingress_rule" {
    count = var.provision_atp ? 1: 0
    network_security_group_id = join(",",oci_core_network_security_group.atp_security_group[*].id)
    direction = "INGRESS"
    protocol = "6"
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = 1522
            min = 1522
        }
    }
}
