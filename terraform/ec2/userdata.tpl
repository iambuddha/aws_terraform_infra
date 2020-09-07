yum -y install httpd
echo "This is comming from terraform" >> /var/www/html/index.html
service httpd start
chkconfig httpd on
