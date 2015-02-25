#!/bin/bash


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
# function controller_localrc
controller_localrc()
{

cat <<EOF
## Controller Host ##
HOST_IP=192.168.1.10
MULTI_HOST=1
## Network nova-network ##
FLAT_INTERFACE=eth0
FIXED_RANGE=172.24.17.0/24
FIXED_NETWORK_SIZE=254
FLOATING_RANGE=192.168.1.128/25
## Leaving Default Services Enabled ##
DISABLED_SERVICES=quantum
## Logs ##
LOGFILE=/opt/stack/logs/stack.sh.log
VERBOSE=True
LOG_COLOR=False
SCREEN_LOGDIR=/opt/stack/logs
EOF

}

# function controller_novaconf
controller_novaconf()
{
cat <<EOF
[DEFAULT]
verbose=True
auth_strategy=keystone
allow_resize_to_same_host=True
api_paste_config=/etc/nova/api-paste.ini
rootwrap_config=/etc/nova/rootwrap.conf
compute_scheduler_driver=nova.scheduler.filter_scheduler.FilterScheduler
dhcpbridge_flagfile=/etc/nova/nova.conf
force_dhcp_release=True
fixed_range=172.24.17.0/24
default_floating_pool=nova
s3_host=192.168.1.10
s3_port=3333
osapi_compute_extension=nova.api.openstack.compute.contrib.standard_extensions
my_ip=192.168.1.11
sql_connection=mysql://root:password@192.168.1.10/nova?charset=utf8
libvirt_type=kvm
libvirt_cpu_mode=none
instance_name_template=instance-%08x
enabled_apis=ec2,osapi_compute,metadata
state_path=/opt/stack/data/nova
lock_path=/opt/stack/data/nova
instances_path=/opt/stack/data/nova/instances
multi_host=True
send_arp_for_ha=True
logging_context_format_string=%(asctime)s %(levelname)s %(name)s [%(request_id)s %(user_name)s %(project_name)s] %(instance)s%(message)s
network_manager=nova.network.manager.FlatDHCPManager
public_interface=br100
vlan_interface=eth0
flat_network_bridge=br100
flat_interface=eth0
novncproxy_base_url=http://192.168.1.10:6080/vnc_auto.html
xvpvncproxy_base_url=http://192.168.1.10:6081/console
vncserver_listen=127.0.0.1
vncserver_proxyclient_address=127.0.0.1
ec2_dmz_host=192.168.1.10
rabbit_host=192.168.1.10
rabbit_password=password
glance_api_servers=192.168.1.10:9292
compute_driver=libvirt.LibvirtDriver
firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver
EOF
}


# function compute_locarc
compute_locarc()
{
cd $PREFIX_DEVSTACK
cat <<EOF
1## Compute Host ##
#SERVICE_HOST_NAME=controller
SERVICE_HOST=192.168.1.10
HOST_IP=192.168.1.11
MULTI_HOST=1
## Network nova-network ##
FLAT_INTERFACE=eth0
FIXED_RANGE=172.24.17.0/24
FIXED_NETWORK_SIZE=254
FLOATING_RANGE=192.168.1.128/25
## Compute Node Services ##
ENABLED_SERVICES=n-cpu,n-net,n-api,n-vol
## API URIs ##
Q_HOST=$SERVICE_HOST
MYSQL_HOST=$SERVICE_HOST
RABBIT_HOST=$SERVICE_HOST
GLANCE_HOSTPORT=$SERVICE_HOST:9292
KEYSTONE_AUTH_HOST=$SERVICE_HOST
KEYSTONE_SERVICE_HOST=$SERVICE_HOST
## Auth ##
ADMIN_PASSWORD=password
MYSQL_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password
SERVICE_TOKEN=password
## Logs ##
LOGFILE=/opt/stack/logs/stack.sh.log
VERBOSE=True
LOG_COLOR=False
SCREEN_LOGDIR=/opt/stack/logs
EOF

}

# function compute_novaconf
compute_novaconf()
{
cat <<EOF
[DEFAULT]
verbose=True
auth_strategy=keystone
allow_resize_to_same_host=True
api_paste_config=/etc/nova/api-paste.ini
rootwrap_config=/etc/nova/rootwrap.conf
compute_scheduler_driver=nova.scheduler.filter_scheduler.FilterScheduler
dhcpbridge_flagfile=/etc/nova/nova.conf
force_dhcp_release=True
fixed_range=172.24.17.0/24
default_floating_pool=nova
s3_host=192.168.1.10
s3_port=3333
osapi_compute_extension=nova.api.openstack.compute.contrib.standard_extensions
my_ip=192.168.1.11
sql_connection=mysql://root:password@192.168.1.10/nova?charset=utf8
libvirt_type=kvm
libvirt_cpu_mode=none
instance_name_template=instance-%08x
enabled_apis=ec2,osapi_compute,metadata
state_path=/opt/stack/data/nova
lock_path=/opt/stack/data/nova
instances_path=/opt/stack/data/nova/instances
multi_host=True
send_arp_for_ha=True
logging_context_format_string=%(asctime)s %(levelname)s %(name)s [%(request_id)s %(user_name)s %(project_name)s] %(instance)s%(message)s
network_manager=nova.network.manager.FlatDHCPManager
public_interface=br100
vlan_interface=eth0
flat_network_bridge=br100
flat_interface=eth0
novncproxy_base_url=http://192.168.1.10:6080/vnc_auto.html
xvpvncproxy_base_url=http://192.168.1.10:6081/console
vncserver_listen=127.0.0.1
vncserver_proxyclient_address=127.0.0.1
ec2_dmz_host=192.168.1.10
rabbit_host=192.168.1.10
rabbit_password=password
glance_api_servers=192.168.1.10:9292
compute_driver=libvirt.LibvirtDriver
firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver
EOF

}


# function bootup_vm
bootup_vm()
{
nova keypair-add ssh_key > ssh_key.pem 
chmod 0600 ~/ssh_key.pem
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
*)
	$1
;;
esac

