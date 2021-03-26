## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "random_string" "wallet_password" {
  count = var.provision_atp ? 1 : 0
  length  = 30
  special = true
  override_special = "#[]{}_-"
}

data "oci_database_autonomous_database_wallet" "atp_database_wallet" {
  count = var.provision_atp ? 1 : 0
  autonomous_database_id = var.atp_db_id
  password               = join(",",random_string.wallet_password[*].result)
  base64_encode_content  = true
}
