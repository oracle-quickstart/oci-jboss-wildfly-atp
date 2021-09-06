## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

module "sshkey" {
  source = "./modules/sshkey"
}

#######################
# compute instance(s) #
#######################

module "jboss" {
  source              = "./modules/compute/"
  display_name        = var.prefix
  prefix              = var.prefix
  domain              = module.app_private_subnet.domain
  node_count          = var.jboss_node_count
  source_id           = module.latest_ol8.image_id
  vm_shape            = var.jboss_vm_shape
  vm_flex_shape_ocpu  = var.jboss_vm_flex_shape_ocpu
  vm_flex_shape_mem   = var.jboss_vm_flex_shape_mem
  subnet_id           = module.app_private_subnet.id
  ssh_authorized_keys = var.ssh_authorized_keys == "" ? module.sshkey.opc_private_key.public_key_openssh : "${var.ssh_authorized_keys}\n${module.sshkey.opc_private_key.public_key_openssh}"
  fd_map              = module.fds.fd_map
  cloud_init          = data.template_cloudinit_config.jboss_cloud_init.rendered
  defined_tags        = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

module "bastion" {
  source              = "./modules/compute/"
  display_name        = "${var.prefix}-bastion"
  prefix              = "${var.prefix}-bastion"
  domain              = module.public_subnet.domain
  node_count          = 1
  source_id           = module.latest_ol8.image_id
  vm_shape            = var.bastion_vm_shape
  vm_flex_shape_ocpu  = var.bastion_vm_flex_shape_ocpu
  vm_flex_shape_mem   = var.bastion_vm_flex_shape_mem
  subnet_id           = module.public_subnet.id
  ssh_authorized_keys = var.ssh_authorized_keys == "" ? module.sshkey.opc_private_key.public_key_openssh : "${var.ssh_authorized_keys}\n${module.sshkey.opc_private_key.public_key_openssh}"
  fd_map              = module.fds.fd_map
  cloud_init          = data.template_cloudinit_config.bastion_cloud_init.rendered
  defined_tags        = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#################
# Load balancer #
#################

module "load_balancer" {
  source               = "./modules/load_balancer/"
  compartment_id       = var.compartment_id
  lb_shape             = var.lb_shape
  flex_lb_min_shape    = var.flex_lb_min_shape
  flex_lb_max_shape    = var.flex_lb_max_shape
  subnet_ids           = [module.public_subnet.id]
  instance_private_ips = values(module.jboss.private_ip)
  num_instances        = length(values(module.jboss.private_ip))
  use_http             = true
  use_https            = true
  use_lb_termination   = false
  defined_tags         = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

