## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "null_resource" "atp_provisioning" {
  count = var.provision_atp ? length(var.instance_ips) : 0

  triggers = {
    instance_ids = join(",", var.instance_ips)
  }

  // Upload wallet files + datasource and script
  provisioner "file" {
    content = templatefile("${path.module}/configure_atp_wallet.sh.tpl", {
      "atp_wallet_password" = join(",", random_string.wallet_password[*].result)
    })
    destination = "/home/opc/configure_atp_wallet.sh"

    connection {
      agent       = false
      timeout     = "10m"
      host        = var.instance_ips[count.index]
      user        = "opc"
      private_key = var.ssh_private_key

      bastion_user        = "opc"
      bastion_private_key = var.ssh_private_key
      bastion_host        = var.bastion_host
    }
  }
  provisioner "file" {
    content     = join(",", oci_database_autonomous_database_wallet.atp_database_wallet[*].content)
    destination = "/home/opc/atp_wallet.b64"

    connection {
      agent       = false
      timeout     = "10m"
      host        = var.instance_ips[count.index]
      user        = "opc"
      private_key = var.ssh_private_key

      bastion_user        = "opc"
      bastion_private_key = var.ssh_private_key
      bastion_host        = var.bastion_host
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo su - -c 'chmod +x /home/opc/configure_atp_wallet.sh'",
      "sudo su - -c '/home/opc/configure_atp_wallet.sh'",
      "sudo su - -c 'rm /home/opc/configure_atp_wallet.sh'",
    ]
    connection {
      agent       = false
      timeout     = "10m"
      host        = var.instance_ips[count.index]
      user        = "opc"
      private_key = var.ssh_private_key

      bastion_user        = "opc"
      bastion_private_key = var.ssh_private_key
      bastion_host        = var.bastion_host
    }
  }
}
