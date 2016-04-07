# vagrant-shibboleth-sp-nginx

An example shibboleth Service Provider that running on nginx and Ubuntu.

## Overview

This is an automated process to set up Shibboleth Service Provider on a
virtual machine hosted in VirtualBox.

Once completed you will have a hosted website [https://localhost:50080/secure](https://localhost:50080/secure)
that redirects to Harvard IdP. Since Harvard do not know who we are, they will
throw an error, but the demo will prove we have set up Shibboleth correctly and
you can alter the IdP as required.

It uses ```vagrant up``` to do 2 things

First, using its VagrantFile
- Downloads, installs and starts an Ubuntu image
- Forwards ports on host 50080 & 50443 to VM ports 80 and 443  

Then, uses the [install script](./install.sh) which does most of the heavy work:
- Updates and installs required packages
- Downloads/installs Shibboleth and its dependencies
- Configures Shibboleth to use an external IdP

## Prerequisites

You'll need both these free apps to get going.

Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
Install [Vagrant](https://www.vagrantup.com/)

## Setup

```
vagrant up --provider=virtualbox
```

## Troubleshooting

## References

[Shibboleth Home](https://shibboleth.net/)

[Integrating Nginx and a Shibboleth SP with FastCGI](https://wiki.shibboleth.net/confluence/display/SHIB2/Integrating+Nginx+and+a+Shibboleth+SP+with+FastCGI)

[NGINX with nginx-http-shibboleth](https://github.com/jitsi/jicofo/blob/master/doc/shibboleth.md)

[NGINX with nginx-http-shibboleth module - Dockerfiles](https://github.com/criluc/docker-nginx-http-shibboleth)
