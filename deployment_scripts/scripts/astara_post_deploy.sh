#!/bin/bash -e

# Publish or find the astara image, set its id in config
# Install the fuel public ssh pub key as the astara ssh key
# Restart astara + neutron l2

source $(dirname $0)/functions
source /root/openrc
export OS_ENDPOINT_TYPE=internalURL

ROLE=${1:-"network-orchestrator-node"}

echo "Running post-deployment task for $role"

TIMEOUT=600

IMG_FILE="/root/astara_appliance.qcow2"
IMG_NAME="astara_appliance"

if [[ ! -e $IMG_FILE ]]; then
        echo "No image file found at $IMG_FILE" && exit 1
fi

if ! which glance; then
        sudo apt-get install -y python-glanceclient
fi

if ! which openstack; then
        sudo apt-get install -y python-openstackclient
fi

if ! which neutron; then
        sudo apt-get -y install python-neutronclient
fi

# glanceclient + openstack clients are a mess and cannot request at the internal
# url.... :(
internal_url=`openstack catalog show image -c endpoints -f value | grep internal | awk '{ print $2 }'`
OS_IMG_URL="--os-image-url=$internal_url"

function publish_image {
    if glance $OS_IMG_URL image-list | grep $IMG_NAME; then
        return
    fi
    echo "Publishing astara image into glance"
    glance $OS_IMG_URL image-create --name $IMG_NAME --visibility=public --container-format=bare --disk-format=qcow2 --file $IMG_FILE
    echo "Published astara image $IMG_FILE into glance"
}


function find_image {
    echo "Finding astara image in glance"
    for i in $(seq 0 $TIMEOUT); do
        IMG_ID=$(glance $OS_IMG_URL image-list | grep $IMG_NAME | awk '{ print $2 }')
        echo $IMG_ID
        if [[ -n "$IMG_ID" ]]; then
            echo "Found astara applinace image in glance /w id $IMG_ID"
            return
        fi
        echo 'zzz'
        sleep 1
    done
    echo "Did not find astara appliance image in glance after $TIMEOUT seconds"
    exit 1
}

function scrub_neutron {
    # scrub the fuel created routers and ports that existed before the l3 agent was
    # removed
    for router in $(neutron router-list -c id -f value); do
        subnets=$(neutron router-port-list -c id -c fixed_ips -f value $router | awk '{ print $3 }' | sed -e 's/,//g')
        for subnet in $subnets; do
        subnet=$(echo $subnet | sed -e's/"//g')
            neutron router-gateway-clear $router $subnet || true
            neutron router-interface-delete $router $subnet || true
        done
    done

    for router in $(neutron router-list -c id -f value); do
        neutron router-delete $router
    done
    sleep 3
    for port in $(neutron port-list -c id -f value); do
        neutron port-delete $port
    done
}

if [[ "$ROLE" == "primary-network-orchestrator-node" ]]; then
    publish_image
    scrub_neutron
fi

find_image

iniset /etc/astara/orchestrator.ini router image_uuid $IMG_ID
iniset /etc/astara/orchestrator.ini loadbalancer image_uuid $IMG_ID

# ssh key installation
echo "$(cat /root/.ssh/authorized_keys)" >/etc/astara/appliance_key.pub
iniset /etc/astara/orchestrator.ini DEFAULT ssh_public_key /etc/astara/appliance_key.pub

service astara-orchestrator stop || true

service neutron-plugin-openvswitch-agent restart

# ensure bridges get created first
sleep 5

service astara-orchestrator start

exit 0
