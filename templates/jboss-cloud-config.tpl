#cloud-config
write_files:
-   content: |
        ${indent(8,"${file("${setup_jboss_sh}")}")}
    path: /setup_jboss.sh
    permissions: '0755'
-   content: |
        ${indent(8,"${file("${module_xml}")}")}
    path: /module.xml
    permissions: '0755'
runcmd: 
    # run setup on first boot
    - /setup_jboss.sh
