## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable type {
    default = "ingress"
}
variable protocol {
    default = "tcp"
}
variable source_cidr {}
variable port {}
variable description {
    default = ""
}
variable stateless {
    default = false
}
locals {
    protocols = {
        ICMP = "1",
        TCP  = "6",
        UDP = "17",
        ICMPv6 = "58"
    }
}

output "security_rule" {
    value = {
        "${var.type}_security_rules" = {
            description = var.description != "" ? var.description : "Port ${var.port}"
            protocol    = local.protocols[upper(var.protocol)]
            source      = var.source_cidr
            source_type = "CIDR_BLOCK"
            stateless   = var.stateless

            tcp_options = {
                max = var.port,
                min = var.port
            }
        }
    }
}