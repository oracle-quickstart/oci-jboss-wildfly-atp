## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Creating OPC key for script copy
resource "tls_private_key" "opc_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "opc_private_key" {
  value = tls_private_key.opc_key
}
