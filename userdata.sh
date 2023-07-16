#!/bin/bash
yum install httpd -y
service httpd start
chkconfig httpd on
cd /var/www/html
ip_address=$(curl -s http://checkip.amazonaws.com)
echo " your server ip address; $ip_address " > index.html
service httpd restart
