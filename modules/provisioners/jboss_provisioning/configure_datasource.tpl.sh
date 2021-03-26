## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

if [[ "${domain_mode}" == "standalone" ]]; then

    # wait for node to be ready
    while [[ "$STATUS" != "1" ]]; do
        STATUS=$(/opt/wildfly/bin/jboss-cli.sh --connect -u=${jboss_username} -p="${jboss_password}" --command=":read-attribute(name=server-state)" | grep running | wc -l)
    done

    /opt/wildfly/bin/jboss-cli.sh --connect -u=${jboss_username} -p="${jboss_password}" --command-timeout=300 <<EOF
data-source add --name=${ds_name} --jndi-name=java:jboss/jdbc/${ds_name} --driver-name=oracle --connection-url=jdbc:oracle:thin:@${atp_db_name}_high?TNS_ADMIN=/atp/wallet/ --user-name=${username} --password=${password}
exit
EOF
else
    if [[ "${index}" == "0" ]]; then
        # if master wait for all nodes to be ready
        while [[ $(printf '%s\n' "$STATUS" | grep "STARTED" | wc -l) != $(printf '%s\n' "$STATUS" | wc -l) ]]; do
            STATUS=$(/opt/wildfly/bin/jboss-cli.sh --connect -u=${jboss_username} -p="${jboss_password}" --command="/host=*/server-config=*/:read-attribute(name=status)" | grep result | grep -v "\[")
        done

        /opt/wildfly/bin/jboss-cli.sh --connect -u=${jboss_username} -p="${jboss_password}" --command-timeout=300 <<EOF
data-source add --name=${ds_name} --jndi-name=java:jboss/jdbc/${ds_name} --driver-name=oracle --connection-url=jdbc:oracle:thin:@${atp_db_name}_high?TNS_ADMIN=/atp/wallet/ --user-name=${username} --password=${password} --profile=full
data-source add --name=${ds_name} --jndi-name=java:jboss/jdbc/${ds_name} --driver-name=oracle --connection-url=jdbc:oracle:thin:@${atp_db_name}_high?TNS_ADMIN=/atp/wallet/ --user-name=${username} --password=${password} --profile=full-ha
data-source add --name=${ds_name} --jndi-name=java:jboss/jdbc/${ds_name} --driver-name=oracle --connection-url=jdbc:oracle:thin:@${atp_db_name}_high?TNS_ADMIN=/atp/wallet/ --user-name=${username} --password=${password} --profile=default
data-source add --name=${ds_name} --jndi-name=java:jboss/jdbc/${ds_name} --driver-name=oracle --connection-url=jdbc:oracle:thin:@${atp_db_name}_high?TNS_ADMIN=/atp/wallet/ --user-name=${username} --password=${password} --profile=ha
exit
EOF
    fi
fi