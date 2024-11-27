#!/bin/bash 

# Get NRPE source code

cd /tmp
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.3/nrpe-4.0.3.tar.gz
tar zxf nrpe-4.0.3.tar.gz

# Install NRPE and check_nrpe from source code

cd nrpe-4.0.3
sudo ./configure --enable-command-args --with-ssl-lib=/usr/lib/x86_64-linux-gnu/ --disable-ssl
#sudo ./configure --enable-command-args --with-ssl-lib=/usr/lib/x86_64-linux-gnu/ --disable-ssl
sudo make all
sudo make install
sudo make install-config


# Run the service


sudo sh -c "sudo echo '# Nagios services' >> /etc/services"
sudo sh -c "sudo echo 'nrpe    5666/tcp' >> /etc/services"
sudo cp startup/default-service /etc/systemd/system/nrpe.service
sudo chmod 644 /etc/systemd/system/nrpe.service

# Adding node-x ip address to make it accessible from public network
sed -i -e 's/#server_address=127.0.0.1/server_address=127.0.0.1,`hostname -s`/g'

# restart 


sudo systemctl start nrpe.service
sudo systemctl enable nrpe.service


exit 0 
