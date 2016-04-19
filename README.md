# vagrant-shibboleth-sp-nginx

An example Shibboleth Service Provider running on nginx and Ubuntu.

## Overview

Once completed you will have a hosted website [https://localhost:50080/secure](https://localhost:50080/secure)
that redirects to Harvard IdP. Since Harvard do not know who we are, they will
throw an error, but the demo will prove we have set up Shibboleth correctly and
you can alter the IdP as required.

***TODO's***

- Haven't configured the secure_site correctly yet.


## Prerequisites

You'll need both these to get going.

- Install [git - the source control tool ](https://git-scm.com/downloads)
- Install [VirtualBox - free virtualization software ](https://www.virtualbox.org/wiki/Downloads)
- Install [Vagrant - a tool easily manage and create virtual machines from online images ](https://www.vagrantup.com/)

## Usage

```
git clone https://github.com/jnyryan/vagrant-shibboleth-sp-nginx.git && cd vagrant-shibboleth-sp-nginx
vagrant up --provider=virtualbox
```

Browse to
  - localhost://50080
  - localhost://50443

## Under the hood

It uses ```vagrant up``` to do 2 things

First, using its VagrantFile
- Downloads, installs and starts an Ubuntu image
- Forwards ports on host 50080 & 50443 to VM ports 80 and 443  

Then, uses the [install script](./install.sh) which does most of the heavy work:
- Updates and installs required packages
- Downloads/installs Shibboleth and its dependencies
- Configures Shibboleth to use an external IdP

## References

This document is based on the hard work of others before me, so here's where I got my info from.

*Thanks to you all.*

[Shibboleth Home](https://shibboleth.net/)

[Integrating Nginx and a Shibboleth SP with FastCGI](https://wiki.shibboleth.net/confluence/display/SHIB2/Integrating+Nginx+and+a+Shibboleth+SP+with+FastCGI)

[NGINX with nginx-http-shibboleth](https://github.com/jitsi/jicofo/blob/master/doc/shibboleth.md)

[NGINX with nginx-http-shibboleth module - Dockerfiles](https://github.com/criluc/docker-nginx-http-shibboleth)

[Create Service File](http://serverfault.com/questions/735260/service-nginx-doesnt-work)
