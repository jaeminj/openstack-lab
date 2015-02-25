#!/bin/bash

# http://therandomsecurityguy.com/devstack-single-nic-configuration/

prepare_dep() {
sudo apt-get install bridge-utils
sudo su - 
adduser stack 
echo "stack ALL=(ALL) NOPASSWD: ALL" » /etc/sudoers 
exit 
su stack 
sudo apt-get install git -y 
}

preset_bridge_inf()
{
cat <<EOF
# Bridge interface 
auto br0 
iface br0 inet 
static address 192.168.1.145 # Reserve this IP from your DHCP server 
netmask 255.255.255.0 
broadcast 192.168.0.255 
gateway 192.168.1.1 # Use your local network gateway 
dns-nameserver 8.8.8.8 8.8.4.4 
bridge_ports eth0 
bridge_fd 0 
bridge_hello 2 
bridge_maxage 12 
bridge_stp off
EOF
}

preset_vlan_inf()
{
cat <<EOF
auto eth0.5 
iface eth0.5 inet static 
address 10.0.0.1 netmask 255.255.255.0 
vlan-raw-device eth0
EOF
}

preset_vlan()
{
modprobe 8021q 
vconfig add eth0 5 
ifconfig eth0.0:5 10.0.0.1 netmask 255.255.255.0 up
}

preset_network()
{
echo 1 > /proc/sys/net/ipv4/ip_forward 
echo 1 > /proc/sys/net/ipv4/conf/eth0/proxy_arp 

echo "net.ipv4.conf.eth0.proxy_arp = 1" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1"  >> /etc/sysctl.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

allinone_localrc()
{
cat <<EOF
HOST_IP=192.168.1.145 
FLOATING_RANGE=192.168.1.144/28 
Q_FLOATING_ALLOCATION_POOL=start=192.168.1.150,end=192.168.1.155  PUBLIC_NETWORK_GATEWAY=192.168.1.254 
FIXED_RANGE=10.0.0.0/24 
FIXED_NETWORK_SIZE=256 FLAT_INTERFACE=eth0
EOF
}

allione_localrc_default()
{

cat <<EOF
[[local|localrc]] 
FLOATING_RANGE=192.168.1.144/28 
FIXED_RANGE=10.0.1.0/24 
FIXED_NETWORK_SIZE=256 
FLAT_INTERFACE=eth0 LOGFILE=/opt/devstack/stack.sh.log 
Q_FLOATING_ALLOCATION_POOL=start=192.168.1.150,end=192.168.1.155 PUBLIC_NETWORK_GATEWAY=192.168.1.254 ADMIN_PASSWORD=mydevstackpassword MYSQL_PASSWORD=mydevstackpassword RABBIT_PASSWORD=mydevstackpassword SERVICE_PASSWORD=mydevstackpassword SERVICE_TOKEN=mydevstackpassword 
disable_service rabbit 
enable_service qpid 
enable_service quantum 
enable_service n-cpu 
enable_service n-cond 
disable_service n-net 
enable_service q-svc 
enable_service q-dhcp 
enable_service q-l3 
enable_service q-meta 
enable_service quantum 
enable_service tempest

EOF

}



# function devstack_install
devstack_download()
{

git clone https://github.com/openstack-dev/devstack.git
cd devstack
}
devstack_install()
{
./stack.sh
}




# function glance_images
glance_images()
{
wget https://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img
wget https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img
}


# function verify_services

verify_services()
{
export SERVICE_TOKEN=openstack
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=openstack
export OS_AUTH_URL=http://localhost:5000/v2.0/
export SERVICE_ENDPOINT=http://localhost:35357/v2.0

nova-manage service list
ps auwx |grep nova

}

# function setup_nova_network

setup_nova_network()
{
#Create the private address space where guest VMs will reside.
nova-manage network create private 172.24.17.0/24 1 254
 #Create the floating address pool and associate it to an object named Nova for something meaningful to tenants.
nova-manage floating create 192.168.1.128/25 --pool=nova

ip addr show 
brctl show 
}

if [ -f openstack.design ]  ; then
source openstack.design
fi 

case $1 in 
help)
grep "^#" $0 |grep function  |awk '{print $3}'
;;
controller_install)
	devstack_download
	controller_localrc > localrc 
	devstack_install
	controller_novaconf > /etc/nova/nova.conf
;;

compute_install)
	devstack_download
	compute_localrc > localrc 
	devstack_install
	compute_novaconf > /etc/nova/nova.conf
;;
postinstall)
	bootup_vm
	glance_images
	verify_services
	setup_nova_network
;;
uninstall)
	./unstack.sh
;;
shutdown)
	./clean.sh
;;
start)
	./rejoin-stack.sh
;;
*)
	$1
;;
esac

