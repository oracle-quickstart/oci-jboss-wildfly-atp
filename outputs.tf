## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "jboss_load_balancer_ip" {
  value = module.load_balancer.lb_ip
}
output "bastion_public_ip" {
  value = join("",module.bastion.public_ips[*])
}
output "jboss_private_ips" {
  value = module.jboss.private_ip
}
output "SSH_through_Bastion_Host" {
  value = var.jboss_node_count > 0 ? "ssh -J opc@${join("",module.bastion.public_ips[*])} opc@${values(module.jboss.private_ip)[0]}" : ""
}

output "SCP_through_Bastion_Host" {
  value = var.jboss_node_count > 0 ? "scp -o ProxyCommand=\"ssh -W %h:%p opc@${join("",module.bastion.public_ips[*])}\" <filename.ext> opc@${values(module.jboss.private_ip)[0]}:~/" : ""
}

output "Tunnel_to_admin_console" {
  value = var.jboss_node_count > 0 ? "ssh -M -fnNT -L 9990:${values(module.jboss.private_ip)[0]}:9990 opc@${join("",module.bastion.public_ips[*])} cat -" : ""
}

output "Tunnel_to_ATP_database" {
  value = var.provision_atp && var.atp_private_subnet ? "ssh -M -fnNT -L 1522:${module.atp_db.private_ip}:1522 opc@${join("",module.bastion.public_ips[*])} cat -" : ""
}

output "Sock5_Proxy_through_Bastion" {
  value = var.jboss_node_count > 0 ? "ssh -C -D 1088 opc@${join("",module.bastion.public_ips[*])}" : ""
}
