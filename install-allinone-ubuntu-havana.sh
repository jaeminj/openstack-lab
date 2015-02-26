#!/bin/bash

BACKUP_ID=$(LANG=C date +%Y%m%d.%H%M)

preset_network()
{
cat <<EOF
auto eth0
iface eth0 inet static
  address 192.168.100.10
  netmask 255.255.255.0
  gateway 192.168.100.1
EOF
}

configure_network()
{
	cp /etc/network/interface /etc/network/interface.$BACKUP_ID
	preset_network >> /etc/network/interface
	cat /etc/network/interface
}

configure_hostname()
{
	hostname $1
	echo $1 > /etc/hostname

	if $(grep -c  $1 /etc/hostname ) -eq  0 ; then 
		echo "192.168.100.10  $1" >> /etc/hosts
	fi
}

add_repository()
{
	apt-get install python-software-properties
	add-apt-repository cloud-archive:havana
	apt-get update
	apt-get dist-upgrade
}

install_mysql()
{
apt-get install python-mysqldb mysql-server
sed -i 's/127.0.0.1/192.168.100.10/g' /etc/mysql/my.cnf
service mysql restart

}

install_rabitmq()
{
apt-get install rabbitmq-server
rabbitmqctl change_password guest ${RABITMQ_PASS}

apt-get install -y ntp
apt-get install -y vlan bridge-utils

}


configure_sysctl()
{
	echo "net.ipv4.forward = 1 " >> /etc/sysctl.conf

	sysctl net.ipv4.ip_forward=1

}

install_keystone()
{
	apt-get install -y keystone
	service keystone status

cat << 'EOF' | mysql -u root 	
CREATE DATABASE keystone ; 
GRANT ALL ON  keystone.* TO 'keystoneUser'@'%' IDENTIFIED BY 'keystonePass' ; 
quit ;
EOF
	
}


