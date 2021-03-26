## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "null_resource" "jboss_provisioning" {
  count = length(var.instance_ips)

  triggers = {
    instance_ids = join(",", var.instance_ips)
    domain_mode = var.domain_mode
  }

    connection {
        agent = false
        timeout = "10m"
        host = var.instance_ips[count.index]
        user = "opc"
        private_key = var.ssh_private_key

        bastion_user = "opc"
        bastion_private_key = var.ssh_private_key
        bastion_host = var.bastion_host
    }

  # Admin console login
  provisioner "remote-exec" {
    inline = [
        "echo 'Configure Admin console'",
        "while [ ! -f /initial_setup.marker ]; do sleep 5; done",
        "sudo su - -c \"/opt/wildfly/bin/add-user.sh -u ${var.admin_username} -r ManagementRealm -p \"${var.admin_password}\"\""
    ]
  }

  provisioner "file" {
    content = file("${path.module}/domain_controller.sh")
    destination = "/home/opc/domain_controller.sh"
  }

  provisioner "file" {
    content = file("${path.module}/hostm.xml")
    destination = "/home/opc/hostm.xml"
  }

  # provision domain mode if activated
  provisioner "remote-exec" {
    inline = [
        "${var.domain_mode} && echo 'Configure Domain controller'",
        "while [ ! -f /opt/wildfly/bin/add-user.sh ]; do sleep 5; done",
        "chmod +x /home/opc/domain_controller.sh",        
        "${var.domain_mode} && sudo su - -c '/home/opc/domain_controller.sh'",
        "sudo su - -c 'rm /home/opc/domain_controller.sh'"
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/configure_driver.tpl.sh", {
        "jboss_username" = var.jboss_username,
        "jboss_password" = var.jboss_password,
        "domain_mode" = var.domain_mode ? "domain" : "standalone"
        "index" = count.index
        "nb_nodes" = length(var.instance_ips)
        })
    destination = "/home/opc/configure_driver.sh"
  }

  # provision Oracle JDBC driver
  provisioner "remote-exec" {
    inline = [
      "echo 'Configuring JDBC driver'",
      "sudo su - -c 'chmod +x /home/opc/configure_driver.sh'",
      "sudo su - -c '/home/opc/configure_driver.sh'",
      "sudo su - -c 'rm /home/opc/configure_driver.sh'"
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/configure_datasource.tpl.sh", {
        "password" = var.atp_password
        "username" = var.atp_username
        "atp_db_name" = var.atp_db_name
        "jboss_username" = var.jboss_username
        "jboss_password" = var.jboss_password
        "ds_name" = var.ds_name
        "domain_mode" = var.domain_mode ? "domain" : "standalone"
        "index" = count.index
        "nb_nodes" = var.create_ds ? length(var.instance_ips) : 0
        })
    destination = "/home/opc/configure_datasource.sh"
  }

  # Configure 
  provisioner "remote-exec" {
    inline = [
      "${var.create_ds} && echo 'Configuring Datasource'",
      "sudo su - -c 'chmod +x /home/opc/configure_datasource.sh'",
      "${var.create_ds} && sudo su - -c '/home/opc/configure_datasource.sh'",
      "sudo su - -c 'rm /home/opc/configure_datasource.sh'"
    ]
  }

}

