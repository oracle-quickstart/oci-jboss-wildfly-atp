## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Get metadata information
INDEX=$(curl http://169.254.169.254/opc/v1/instance/metadata/index)
MASTER_HOSTNAME=$(curl http://169.254.169.254/opc/v1/instance/metadata/master)
NB_NODES=$(curl http://169.254.169.254/opc/v1/instance/metadata/nb_nodes)
PREFIX=$(curl http://169.254.169.254/opc/v1/instance/metadata/prefix)

DOMAIN=$(hostname -f | sed -e "s|`hostname`\.||g")

echo $INDEX, $MASTER_HOSTNAME, $NB_NODES, $PREFIX

# Wait for WildFly to finish setup
while [[ ! -f '/etc/wildfly/wildfly.conf' ]]
do
    sleep 1
done

# MASTER OR SLAVE?
if [[ "$INDEX" == "0" ]]; then
    # MASTER MODE    
    cp /home/opc/hostm.xml /opt/wildfly/domain/configuration/host.xml
    # Register slave users, including this host
    for i in $(seq 0 $(($NB_NODES-1))); do
        # md5sum outputs " -" at the end, so remove it
        echo ${PREFIX}${i}.${DOMAIN}
        PASSW=$(printf ${PREFIX}${i}.${DOMAIN} | md5sum | tr -d ' ' | tr -d '-')
        # username can't contain '-'
        # add -ds to display secret
        /opt/wildfly/bin/add-user.sh -u ${PREFIX}${i} -p ${PASSW} -r "ManagementRealm"
    done
    sed -i "s|<host xmlns=\"urn:jboss:domain:13.0\" name=\"master\">|<host xmlns=\"urn:jboss:domain:13.0\" name=\"${PREFIX}0\">|g" /opt/wildfly/domain/configuration/host.xml
else
    # SLAVE MODE    
    cp /opt/wildfly/domain/configuration/host-slave.xml /opt/wildfly/domain/configuration/host.xml
    sed -i "s|<host xmlns=\"urn:jboss:domain:13.0\">|<host xmlns=\"urn:jboss:domain:13.0\" name=\"${PREFIX}${INDEX}\">|g" /opt/wildfly/domain/configuration/host.xml
fi
echo "jboss.domain.master.address=${PREFIX}0.${DOMAIN}" >> /opt/wildfly/jboss.properties
cat /opt/wildfly/jboss.properties
# Set slave user password based on hostname (base64 encoded)
PASSW=$(printf ${PREFIX}${INDEX}.${DOMAIN} | md5sum | tr -d ' ' | tr -d '-')
B64PWD=$(printf $PASSW | base64)
sed -i "s|<secret value=\"c2xhdmVfdXMzcl9wYXNzd29yZA==\"/>|<secret value=\"${B64PWD}\"/>|g" /opt/wildfly/domain/configuration/host.xml
# # Set slave name (= hostname)
# don't need name as hostname will be used
sed -i "s|<remote security-realm=\"ManagementRealm\">|<remote security-realm=\"ManagementRealm\" username=\"${PREFIX}${INDEX}\">|g" /opt/wildfly/domain/configuration/host.xml
# Set master instance IP
# update the systemd unit to start in domain mode

sed -i 's|standalone|domain|g' /etc/wildfly/wildfly.conf

systemctl daemon-reload
systemctl restart wildfly
