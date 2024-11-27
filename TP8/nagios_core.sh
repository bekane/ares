#!/bin/bash

# get nagios source code

wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz
tar xzf nagioscore.tar.gz


# install nagios from source code
cd nagioscore-nagios-4.4.6/
sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled



sudo make all

sudo make install-groups-users
sudo usermod -a -G nagios www-data

sudo make install
sudo make install-daemoninit
sudo make install-commandmode
sudo make install-config

sudo make install-webconf
sudo a2enmod rewrite
sudo a2enmod cgi


# allow apache2


sudo ufw allow Apache
sudo ufw reload


# set nagios admin password
sudo htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin ares1234


# enable nagios services


sudo systemctl restart apache2.service
sudo systemctl start nagios.service

# access the nagios web interface at http://<cloulab_public_ip>/nagios , then test the login

# Enable apache on boot
sudo systemctl enable apache2.service






exit 0
