## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# if [[ -f 'atp_wallet.b64' ]]; then
# wait for wildfly to be setup
while [[ ! -f '/opt/wildfly/bin/launch.sh' ]]
do
    sleep 1
done
echo "Installing ATP wallet" > /tmp/init.log
mkdir -p /atp/wallet
# the wallet is base64 encoded, so decode
base64 -d /home/opc/atp_wallet.b64 > /home/opc/atp_wallet.zip
unzip -o /home/opc/atp_wallet.zip -d /atp/wallet/

printf "\noracle.net.ssl_server_dn_match=true\n" >> /atp/wallet/ojdbc.properties
# comment out wallet location
sed -i 's|oracle.net.wallet_location|#oracle.net.wallet_location|' /atp/wallet/ojdbc.properties
# uncomment the javax.net.ssl entries
sed -i 's|#javax.net.ssl|javax.net.ssl|g' /atp/wallet/ojdbc.properties
# set the password in the file
sed -i "s|<password_from_console>|${atp_wallet_password}|g" /atp/wallet/ojdbc.properties

rm /home/opc/atp_*
chown -R wildfly:wildfly /atp
# fi
