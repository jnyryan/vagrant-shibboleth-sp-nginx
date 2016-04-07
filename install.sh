#!/bin/bash

set -e

# Prerequisites
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
apt-get update -y
apt-get install -y build-essential checkinstall make unzip git
apt-get install -y libpcre3 libpcre3-dev libssl-dev
apt-get install -y libmemcached11 libodbc1 shibboleth-sp2-common libshibsp6 libshibsp-plugins shibboleth-sp2-utils
apt-get install -y supervisor

cat > /etc/supervisor/conf.d/shib.conf << EOL
[fcgi-program:shibauthorizer]
command=/usr/lib/x86_64-linux-gnu/shibboleth/shibauthorizer
socket=unix:///opt/shibboleth/shibauthorizer.sock
socket_owner=_shibd:_shibd
socket_mode=0666
user=_shibd
stdout_logfile=/var/log/supervisor/shibauthorizer.log
stderr_logfile=/var/log/supervisor/shibauthorizer.error.log

[fcgi-program:shibresponder]
command=/usr/lib/x86_64-linux-gnu/shibboleth/shibresponder
socket=unix:///opt/shibboleth/shibresponder.sock
socket_owner=_shibd:_shibd
socket_mode=0666
user=_shibd
stdout_logfile=/var/log/supervisor/shibresponder.log
stderr_logfile=/var/log/supervisor/shibresponder.error.log
EOL

#service supervisor restart

# Get the sources
wget https://github.com/openresty/headers-more-nginx-module/archive/v0.25.zip
wget http://nginx.org/download/nginx-1.6.2.tar.gz
# unpack them to /opt
git clone https://github.com/nginx-shib/nginx-http-shibboleth /opt/nginx-http-shibboleth
unzip v0.25.zip -d /opt
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
 --add-module=/opt/headers-more-nginx-module-0.25
# --without-http_rewrite_module
# added the last one as i oculdn't get PCRE to install

make
make install
