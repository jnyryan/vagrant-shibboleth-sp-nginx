#!/bin/bash

set -e

# Prerequisites
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
apt-get update -y
apt-get install -y build-essential checkinstall make unzip git
apt-get install -y libpcre3 libpcre3-dev libssl-dev
apt-get install -y libmemcached11 libodbc1 shibboleth-sp2-common libshibsp6 libshibsp-plugins shibboleth-sp2-utils

# install Supervisor - utility used to integrate Shibboleth SP with Nginx through fast-cgi
apt-get install -y supervisor
cp /vagrant/etc/supervisor/shib.conf /etc/supervisor/conf.d/shib.conf
service supervisor restart

# Get the sources
wget https://github.com/openresty/headers-more-nginx-module/archive/v0.25.zip
# unpack them to /opt
git clone https://github.com/nginx-shib/nginx-http-shibboleth /opt/nginx-http-shibboleth
unzip v0.25.zip -d /opt

# Download, compile and install nginx source
wget http://nginx.org/download/nginx-1.6.2.tar.gz
tar -xzvf nginx-1.6.2.tar.gz -C /opt
cd /opt/nginx-1.6.2
./configure --sbin-path=/usr/sbin/nginx \
 --conf-path=/etc/nginx/nginx.conf \
 --pid-path=/run/nginx.pid \
 --error-log-path=/var/log/nginx/error.log \
 --http-log-path=/var/log/nginx/access.log \
 --with-http_ssl_module \
 --with-ipv6 \
 --add-module=/opt/nginx-http-shibboleth \
 --add-module=/opt/headers-more-nginx-module-0.25 \
&& make && make install
cd -

#cat /vagrant/etc/nginx/sites-available/secure_site.conf >> /etc/nginx/nginx.conf

#NGINX systemd service file
cp /vagrant/etc/lib/systemd/system/nginx.service /lib/systemd/system/nginx.service
systemctl daemon-reload
service nginx start

# Configure Shibboleth metadata for the IdP, in this case the Harvard Idp
cp /vagrant/etc/shibboleth/stage-idp-metadata.xml /etc/shibboleth/stage-idp-metadata.xml
cp /vagrant/etc/shibboleth/shibboleth2.xml /etc/shibboleth/shibboleth2.xml
mkdir -p /var/log/shibboleth
service shibd start
service shibd status
