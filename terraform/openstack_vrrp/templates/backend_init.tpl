#!/bin/bash


apt update -y
DEBIAN_FRONTEND=noninteractive apt install -y python3-pip keepalived vim python3-openstackclient
PORT_IDS="${_port_ids}"
MY_PORT_ID=${_my_port_id}
KEEPALIVED_MAC_ADDRESS=${_keepalived_mac_address}
KEEPALIVED_IP_ADDRESS=${_keepalived_ip_address}

cat > /etc/sysctl.d/vrrp.conf <<EOF
net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.all.arp_announce=1
net.ipv4.conf.all.arp_filter=0
net.ipv4.conf.ens3.arp_filter = 1
EOF

sysctl -p /etc/sysctl.d/vrrp.conf

cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_instance VI_1 {
    interface ens3
    virtual_router_id 50
    nopreempt
    priority 100
    advert_int 1
    virtual_ipaddress {
        $KEEPALIVED_IP_ADDRESS
    }

    notify_master "/etc/keepalived/notify_master.sh"

    use_vmac
    vmac_xmit_base
}
EOF

mkdir -p /etc/openstack/
cat > /etc/openstack/clouds.yaml <<EOF
${_clouds_yaml}
EOF

cat > /etc/keepalived/notify_master.sh <<EOF
#!/bin/bash

set -ex

export OS_CLOUD=${_os_cloud_name}

for port in $PORT_IDS; do
    if [[ "\$port" == $MY_PORT_ID ]]; then
        openstack port set \$port --allowed-address ip-address=$KEEPALIVED_IP_ADDRESS,mac-address=$KEEPALIVED_MAC_ADDRESS || true
        openstack port set \$port --allowed-address ip-address=0.0.0.0/0 || true
    else
        openstack port set \$port --no-allowed-address
    fi
done
EOF

chmod +x /etc/keepalived/notify_master.sh

systemctl restart keepalived
