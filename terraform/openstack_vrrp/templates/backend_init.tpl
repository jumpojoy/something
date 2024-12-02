#!/bin/bash


apt update -y
DEBIAN_FRONTEND=noninteractive apt install -y python3-pip keepalived vim

cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_instance VI_1 {
    interface ens3
    virtual_router_id 50
    nopreempt
    priority 100
    advert_int 1
    virtual_ipaddress {
        192.168.0.10
    }
    use_vmac
}
EOF

systemctl restart keepalived
