## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

#######################################################
# network: VCN, subnets, security lists, route tables #
#######################################################
resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_id
  display_name   = "${var.prefix} VCN"
  dns_label      = lower(replace(var.prefix, " ", ""))
  freeform_tags  = {}
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_internet_gateway" "internet_gateway" {
  count          = var.public_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  enabled       = true
  display_name  = "Internet Gateway"
  freeform_tags = {}
  defined_tags  = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_default_route_table" "default_route_table" {
  display_name               = "Default Route Table for ${oci_core_vcn.vcn.display_name}"
  freeform_tags              = {}
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_default_security_list" "default_security_list" {
  display_name = "Default Security List for ${oci_core_vcn.vcn.display_name}"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }

  freeform_tags = {}

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }

    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }

    protocol    = "1"
    source      = oci_core_vcn.vcn.cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

module "ingress_sr_tcp_9990" {
  source      = "./modules/network/security_list_rules/"
  type        = "ingress"
  protocol    = "tcp"
  source_cidr = "0.0.0.0/0"
  port        = "9990"
}
module "ingress_sr_tcp_9993" {
  source      = "./modules/network/security_list_rules/"
  type        = "ingress"
  protocol    = "tcp"
  source_cidr = "0.0.0.0/0"
  port        = "9993"
}
module "ingress_sr_tcp_8080" {
  source      = "./modules/network/security_list_rules/"
  type        = "ingress"
  protocol    = "tcp"
  source_cidr = "0.0.0.0/0"
  port        = "8080"
}
module "ingress_sr_tcp_8443" {
  source      = "./modules/network/security_list_rules/"
  type        = "ingress"
  protocol    = "tcp"
  source_cidr = "0.0.0.0/0"
  port        = "8443"
}
module "ingress_sr_tcp_80" {
  source      = "./modules/network/security_list_rules/"
  type        = "ingress"
  protocol    = "tcp"
  source_cidr = "0.0.0.0/0"
  port        = "80"
}
module "ingress_sr_tcp_443" {
  source      = "./modules/network/security_list_rules/"
  type        = "ingress"
  protocol    = "tcp"
  source_cidr = "0.0.0.0/0"
  port        = "443"
}
module "ingress_sr_tcp_1522" {
  source      = "./modules/network/security_list_rules/"
  type        = "ingress"
  protocol    = "tcp"
  source_cidr = "0.0.0.0/0"
  port        = "1522"
}
module "jboss_security_list" {
  source       = "./modules/network/security_lists/"
  vcn_id       = oci_core_vcn.vcn.id
  display_name = "JBoss Security List"
  ingress_security_rules = [module.ingress_sr_tcp_9990.security_rule,
    module.ingress_sr_tcp_9993.security_rule,
    module.ingress_sr_tcp_8080.security_rule,
    module.ingress_sr_tcp_8443.security_rule
  ]
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
module "loadbalancer_security_list" {
  source       = "./modules/network/security_lists/"
  vcn_id       = oci_core_vcn.vcn.id
  display_name = "Load Balancer Security List"
  ingress_security_rules = [module.ingress_sr_tcp_80.security_rule,
  module.ingress_sr_tcp_443.security_rule]
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
module "atp_security_list" {
  source                 = "./modules/network/security_lists/"
  vcn_id                 = oci_core_vcn.vcn.id
  display_name           = "ATP Security List"
  ingress_security_rules = [module.ingress_sr_tcp_1522.security_rule]
  defined_tags           = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
resource "oci_core_default_dhcp_options" "default_dhcp_options" {

  display_name  = "Default DHCP Options for ${oci_core_vcn.vcn.display_name}"
  freeform_tags = {}

  manage_default_resource_id = oci_core_vcn.vcn.default_dhcp_options_id

  options {
    custom_dns_servers = []

    #search_domain_names = <<Optional value not found in discovery>>
    server_type = "VcnLocalPlusInternet"
    type        = "DomainNameServer"
  }

  options {
    #custom_dns_servers = <<Optional value not found in discovery>>
    search_domain_names = [
      oci_core_vcn.vcn.vcn_domain_name
    ]

    #server_type = <<Optional value not found in discovery>>
    type = "SearchDomain"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
resource "oci_core_route_table" "public_subnet_route_table" {
  count = var.public_subnet ? 1 : 0
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  display_name  = "Public Subnet Route Table"
  freeform_tags = {}
  route_rules {
    #Required
    network_entity_id = join("", oci_core_internet_gateway.internet_gateway[*].id)

    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Internet Gateway"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
resource "oci_core_nat_gateway" "nat_gateway" {
  count          = 1
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  block_traffic = false
  # defined_tags = {}
  display_name = "NAT Gateway"
  # freeform_tags = {}
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
resource "oci_core_route_table" "private_subnet_route_table" {
  count = 1
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  display_name  = "Private Subnet Route Table"
  freeform_tags = {}
  route_rules {
    #Required
    network_entity_id = join("", oci_core_nat_gateway.nat_gateway[*].id)

    #Optional
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "NAT Gateway"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

module "app_private_subnet" {
  source         = "./modules/network/subnet/"
  create_subnet  = true
  display_name   = "App Private Subnet"
  is_private     = true
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  cidr_block     = cidrsubnet(var.vcn_cidr_block, 8, 2)
  security_list_ids = [oci_core_default_security_list.default_security_list.id,
  module.jboss_security_list.id]
  route_table_id = join("", oci_core_route_table.private_subnet_route_table[*].id)
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
module "db_private_subnet" {
  source         = "./modules/network/subnet/"
  create_subnet  = var.provision_atp
  display_name   = "DB Private Subnet"
  is_private     = true
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  cidr_block     = cidrsubnet(var.vcn_cidr_block, 8, 3)
  security_list_ids = [oci_core_default_security_list.default_security_list.id,
  module.atp_security_list.id]
  route_table_id = join("", oci_core_route_table.private_subnet_route_table[*].id)
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
module "public_subnet" {
  source         = "./modules/network/subnet/"
  create_subnet  = var.public_subnet
  display_name   = "Public Subnet"
  is_private     = false
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  cidr_block     = cidrsubnet(var.vcn_cidr_block, 8, 1)
  security_list_ids = [oci_core_default_security_list.default_security_list.id,
  module.loadbalancer_security_list.id]
  route_table_id = join("", oci_core_route_table.public_subnet_route_table[*].id)
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
