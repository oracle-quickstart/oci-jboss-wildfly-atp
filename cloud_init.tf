## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "bootstrap_jboss" {
  template = file("./templates/jboss-cloud-config.tpl")
  vars = {
    "setup_jboss_sh" = "./files/setup_jboss.sh"
    "module_xml"     = "./files/module.xml"
  }
}

data "template_file" "key_script" {
  template = file("./templates/sshkey.tpl")
  vars = {
    "ssh_public_key" = module.sshkey.opc_private_key.public_key_openssh
  }
}

# Render a multi-part cloud-init config making use of the part
# above, and other source files
data "template_cloudinit_config" "jboss_cloud_init" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.bootstrap_jboss.rendered
  }
  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.key_script.rendered
  }

}

# Render a multi-part cloud-init config making use of the part
# above, and other source files
data "template_cloudinit_config" "bastion_cloud_init" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.key_script.rendered
  }

}
