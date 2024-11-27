#!/bin/bash

sudo useradd nagios

# install nagios plugins

cd /tmp
wget http://www.nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
tar zxf nagios-plugins-2.3.3.tar.gz
cd nagios-plugins-2.3.3
./configure
make -j
sudo make install

# install nagios nrpe

cd /tmp
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.3/nrpe-4.0.3.tar.gz
tar zxf nrpe-4.0.3.tar.gz

cd nrpe-4.0.3
./configure --disable-ssl

make  nrpe -j
sudo make install-daemon
sudo make install-config
sudo make install-init


sed -i -e "s/#server_address=127.0.0.1/server_address=`hostname -s`/g" /usr/local/nagios/etc/nrpe.cfg 
sed -i -e "s/allowed_hosts=127.0.0.1,::1/allowed_hosts=127.0.0.1,::1,node-0/g" /usr/local/nagios/etc/nrpe.cfg 
sed -i -e "s/#include_dir=<somedirectory>/include_dir=\/usr\/local\/nagios\/etc\/confs/g"  /usr/local/nagios/etc/nrpe.cfg


# default configuration and checks !

sudo mkdir /usr/local/nagios/etc/confs

cat>/usr/local/nagios/etc/confs/base.cfg<<EOF

command[check_disk]=/usr/local/nagios/libexec/check_disk -w 20% -c 10% -p /dev/sda1
#command[check_ssh]=/usr/local/nagios/libexec/check_ssh -H 1.2.123.234
#command[check_tcp_80]=/usr/local/nagios/libexec/check_http -H 1.2.123.234 -p 80
command[check_load]=/usr/local/nagios/libexec/check_load -r -w 1.0,0.9,0.8 -c 1.5,1.25,1.0
command[check_zombie_procs]=/usr/local/nagios/libexec/check_procs -w 5 -c 10 -s Z

EOF

# enable nrpe services


sudo chown -R nagios:nagios /usr/local/nagios/etc/confs
sudo systemctl start nrpe.service
#sudo systemctl status nrpe.service
sudo ufw allow 5666/tcp

exit 0
