#!/bin/bash -e

source /root/openrc

for agent in dhcp metadata l3; do
        echo "Disablng $agent neutron agent in pacemaker cluster."
        pcs resource disable clone_p_neutron-${agent}-agent
        for id in $(neutron agent-list | grep $agent | awk '{ print $2 }'); do
                echo "Deleting $agent $id from neutron."
                neutron agent-delete $id
        done
done

# The debian/ubuntu packaging has a bug that makes it impossible to gracefully
# load your specific config files without mangling its upstart conf.
sed -i 's/\$CONF_ARG$/--config-file \/etc\/neutron\/plugins\/ml2\/ml2_conf.ini/g' /etc/init/neutron-server.conf

# Kick neutron-server after everythings been installed + configured
service neutron-server restart || true

exit 0
