#!/bin/bash

set -e

BUILD_LOG=/vagrant/temp/build.log
echo "Starting Build" > $BUILD_LOG

# Prerequisites
  sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
  apt-get update -y
  apt-get install -y build-essential checkinstall make unzip git
  apt-get install -y libpcre3 libpcre3-dev libssl-dev
  apt-get install -y libmemcached11 libodbc1 shibboleth-sp2-common libshibsp6 libshibsp-plugins shibboleth-sp2-utils
  echo "Installed Packages" > $BUILD_LOG

# install Supervisor - utility used to integrate Shibboleth SP with Nginx through fast-cgi
  apt-get install -y supervisor
  cp /vagrant/etc/supervisor/shib.conf /etc/supervisor/conf.d/shib.conf
  service supervisor restart
  echo "Installed Supervisor" > $BUILD_LOG

# Get the sources and unpack them to /opt
  wget https://github.com/openresty/headers-more-nginx-module/archive/v0.25.zip \
   && unzip v0.25.zip -d /opt
  git clone https://github.com/nginx-shib/nginx-http-shibboleth /opt/nginx-http-shibboleth
  echo "Installed sources" > $BUILD_LOG

# Download, compile and install nginx source
  wget http://nginx.org/download/nginx-1.9.14.tar.gz \
    && tar -xzvf nginx-1.9.14.tar.gz -C /opt
  cd /opt/nginx-1.9.14
  ./configure --sbin-path=/usr/sbin/nginx \
   --conf-path=/etc/nginx/nginx.conf \
   --pid-path=/run/nginx.pid \
   --error-log-path=/var/log/nginx/error.log \
   --http-log-path=/var/log/nginx/access.log \
   --with-http_ssl_module \
   --with-ipv6 \
   --add-module=/opt/nginx-http-shibboleth \
   --add-module=/opt/headers-more-nginx-module-0.25 \
   && make && make install && echo "Installed nginx-1.9.14" >> $BUILD_LOG
  cd -

  # make nginx use the site-enabled folder
  mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled
  sed -i '/http {/a include /etc/nginx/sites-enabled/*;' /etc/nginx/nginx.conf
  #NGINX systemd service file
  cp /vagrant/etc/nginx/nginx.service /lib/systemd/system/nginx.service
  systemctl daemon-reload
  service nginx start

# Configure Shibboleth metadata for the IdP, in this case the Harvard Idp
  cp /vagrant/etc/shibboleth/stage-idp-metadata.xml /etc/shibboleth/stage-idp-metadata.xml
  cp /vagrant/etc/shibboleth/shibboleth2.xml /etc/shibboleth/shibboleth2.xml
  mkdir -p /var/log/shibboleth
  service shibd start
  service shibd status


# Add a new test website
  mkdir -p /var/www/example.com
  chmod 755 /var/www
  cp -r /vagrant/www/index.html /var/www/example.com/index.html
  cp /vagrant/etc/nginx/example.conf /etc/nginx/sites-available/example.conf
  ln -s /etc/nginx/sites-available/example.conf /etc/nginx/sites-enabled/example.conf


  cp /vagrant/etc/nginx/secure_site.conf /etc/nginx/sites-available/secure_site.conf
  ln -s /etc/nginx/sites-available/secure_site.conf /etc/nginx/sites-enabled/secure_site.conf
  service nginx restart
