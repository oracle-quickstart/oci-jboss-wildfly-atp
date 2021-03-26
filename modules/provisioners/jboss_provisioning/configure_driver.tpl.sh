## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

if [[ "${domain_mode}" == "standalone" ]]; then
    # wait for node to be ready
    while [[ "$STATUS" != "1" ]]; do
        STATUS=$(/opt/wildfly/bin/jboss-cli.sh --connect -u=${jboss_username} -p="${jboss_password}" --command=":read-attribute(name=server-state)" | grep running | wc -l)
    done

    # Standalone mode, define oracle diver, and datasource
    /opt/wildfly/bin/jboss-cli.sh --connect -u=${jboss_username} -p="${jboss_password}" --command-timeout=300 <<EOF
/subsystem=datasources/jdbc-driver=oracle:add(driver-name="oracle",driver-module-name="com.oracle",driver-class-name=oracle.jdbc.driver.OracleDriver)
exit
EOF
else
    if [[ "${index}" == "0" ]]; then

        # if master wait for all nodes to be ready
        while [[ $(printf '%s\n' "$STATUS" | grep "STARTED" | wc -l) != $(printf '%s\n' "$STATUS" | wc -l) ]]; do
            STATUS=$(/opt/wildfly/bin/jboss-cli.sh --connect -u=${jboss_username} -p="${jboss_password}" --command="/host=*/server-config=*/:read-attribute(name=status)" | grep result | grep -v "\[")
        done

        /opt/wildfly/bin/jboss-cli.sh --connect -u=${jboss_username} -p="${jboss_password}" --command-timeout=300 <<EOF
/profile=default/subsystem=datasources/jdbc-driver=oracle:add(driver-name="oracle",driver-module-name="com.oracle",driver-class-name=oracle.jdbc.driver.OracleDriver)
/profile=full/subsystem=datasources/jdbc-driver=oracle:add(driver-name="oracle",driver-module-name="com.oracle",driver-class-name=oracle.jdbc.driver.OracleDriver)
/profile=full-ha/subsystem=datasources/jdbc-driver=oracle:add(driver-name="oracle",driver-module-name="com.oracle",driver-class-name=oracle.jdbc.driver.OracleDriver)
/profile=ha/subsystem=datasources/jdbc-driver=oracle:add(driver-name="oracle",driver-module-name="com.oracle",driver-class-name=oracle.jdbc.driver.OracleDriver)
exit
EOF
    fi
fi