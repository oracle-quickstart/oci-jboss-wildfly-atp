## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

###########################################
# Provisioners (through remote-exec, SSH) #
###########################################
# we use provisioners so as to send passwords 
# only within files ssh'ed to the host
# the files are removed after provisioning.


module "jboss_provisioning" {
  source          = "./modules/provisioners/jboss_provisioning/"
  admin_username  = var.jboss_admin_username
  admin_password  = var.jboss_admin_password
  ds_name         = var.ds_name
  domain_mode     = var.domain_mode
  atp_username    = var.atp_username
  atp_password    = var.atp_password
  atp_db_name     = var.atp_db_name
  jboss_username  = var.jboss_admin_username
  jboss_password  = var.jboss_admin_password
  ssh_private_key = module.sshkey.opc_private_key.private_key_pem
  instance_ips    = module.jboss.private_ips
  bastion_host    = module.bastion.public_ips[0]
}



########################
# Provision ATP_Wallet #
########################

module "atp_wallet_provisioning" {
  source          = "./modules/provisioners/atp_wallet/"
  provision_atp   = var.provision_atp
  atp_db_id       = module.atp_db.id
  ssh_private_key = module.sshkey.opc_private_key.private_key_pem
  instance_ips    = module.jboss.private_ips
  bastion_host    = module.bastion.public_ips[0]
}
