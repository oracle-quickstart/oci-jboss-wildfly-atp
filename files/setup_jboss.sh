## Copyright (c) 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

set -x

mkdir -p /tmp
touch /tmp/init.log

sudo yum install -y java-11-openjdk-devel

echo "Download Wildfly" >> /tmp/init.log
export JBOSS_VERSION=20.0.1.Final
wget https://download.jboss.org/wildfly/${JBOSS_VERSION}/wildfly-${JBOSS_VERSION}.tar.gz

echo "Install Wildfly" >> /tmp/init.log
tar -xzvf wildfly-${JBOSS_VERSION}.tar.gz
mv wildfly-${JBOSS_VERSION} /opt/wildfly
rm wildfly-${JBOSS_VERSION}.tar.gz

echo "Install JDBC driver for Oracle DB" >> /tmp/init.log
JDBC_VERSION=ojdbc8-full
ORACLE_JDBC_MODULE_DIR=/opt/wildfly/modules/system/layers/base/com/oracle/main/

sudo curl -LO -O https://download.oracle.com/otn-pub/otn_software/jdbc/1918/${JDBC_VERSION}.tar.gz \
    && sudo mkdir -p ${ORACLE_JDBC_MODULE_DIR} \
    && sudo tar xf ${JDBC_VERSION}.tar.gz -C ${ORACLE_JDBC_MODULE_DIR} \
    && sudo rm ${JDBC_VERSION}.tar.gz

# mkdir -p ${ORACLE_JDBC_MODULE_DIR}
# wget -c https://download.oracle.com/otn-pub/otn_software/jdbc/1918/${JDBC_VERSION}.tar.gz -O - | tar -x -C ${ORACLE_JDBC_MODULE_DIR}

# echo "Move the module.xml file to the JDBC driver folder" >> /tmp/init.log
# Can't create a module in Domain mode, so creating with a file for all modes.
mv /module.xml ${ORACLE_JDBC_MODULE_DIR}

# open ports on firewall
firewall-offline-cmd --add-port=9990/tcp # admin console HTTP
firewall-offline-cmd --add-port=9993/tcp # admin console SSL
firewall-offline-cmd --add-port=8080/tcp # application server HTTP
firewall-offline-cmd --add-port=8443/tcp # application server SSL

systemctl restart firewalld

# setup Systemd for wildfly
groupadd --system wildfly
useradd -s /sbin/nologin --system -d /opt/wildfly  -g wildfly wildfly
mkdir /etc/wildfly

# copy templates
cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.conf /etc/wildfly/
cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.service /etc/systemd/system/
cp /opt/wildfly/docs/contrib/scripts/systemd/launch.sh /opt/wildfly/bin/
chmod +x /opt/wildfly/bin/launch.sh

# make sure admin console is bond to 0.0.0.0 so it can be accessed via bastion
echo "jboss.bind.address.management=0.0.0.0" > /opt/wildfly/jboss.properties

sed -i 's|\$3|\$3 --properties=/opt/wildfly/jboss.properties|g' /opt/wildfly/bin/launch.sh

chown -R wildfly:wildfly /opt/wildfly

systemctl daemon-reload

# Setup Selinux
semanage fcontext  -a -t bin_t  "/opt/wildfly/bin(/.*)?"
restorecon -Rv /opt/wildfly/bin/

systemctl start wildfly
systemctl enable wildfly
touch /initial_setup.marker
