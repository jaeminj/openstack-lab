#!/bin/bash

configure_network_interface()
{

cat << 'EOF' > /etc/network/interface
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet manual
up ifconfig $IFACE 0.0.0.0 up
up ip link set $IFACE promisc on
down ip link set $IFACE promisc off
down ifconfig $IFACE down

EOF
}


prepare_dep() {
sudo apt-get install bridge-utils
sudo su - 
adduser stack 
echo "stack ALL=(ALL) NOPASSWD: ALL" » /etc/sudoers 
exit 
su stack 
sudo apt-get install git -y 
}

git clone git://github.com/openstack-dev/devstack.git

cd devstack

cat << 'EOF' > localrc
# Devstack localrc for Quantum all in one
# default
HOST_IP=192.168.19.128
# network
FLAT_INTERFACE=eth0
FIXED_RANGE=10.0.0.0/20
NETWORK_GATEWAY=10.0.0.1
FLOATING_RANGE=192.168.174.1/24
EXT_GW_IP=192.168.174.1
# vnc
VNCSERVER_LISTEN=0.0.0.0
VNCSERVER_PROXYCLIENT_ADDRESS=$HOST_IP
# logs
DEST=/opt/stack
LOGFILE=$DEST/logs/stack.sh.log
SCREEN_LOGDIR=$DEST/logs/screen
# system password
ADMIN_PASSWORD=openstack
MYSQL_PASSWORD=openstack
RABBIT_PASSWORD=openstack
SERVICE_PASSWORD=openstack
SERVICE_TOKEN=openstackservicetoken
# cinder
VOLUME_GROUP="cinder-volume"
VOLUME_NAME_PREFIX="volume-"
# install service
disable_service n-net
enable_service q-svc q-agt q-dhcp q-l3 q-meta quantum
EOF

./stack.sh

}
