#!/bin/bash



# Define NGINX version
NGINX_VERSION=$1
EMAIL_ADDRESS=$2

# Capture errors
function ppa_error()
{
	echo "[ `date` ] $(tput setaf 1)$@$(tput sgr0)" 
	exit $2
}

# Echo function
function ppa_lib_echo()
{
	echo $(tput setaf 4)$@$(tput sgr0)
}

# Update/Install Packages
ppa_lib_echo "Execute: apt-get update, please wait"
sudo apt-get update || ppa_error "Unable to update packages, exit status = " $?
ppa_lib_echo "Installing required packages, please wait"
sudo apt-get -y install git dh-make devscripts debhelper dput gnupg-agent || ppa_error "Unable to install packages, exit status = " $?

# Configure PPA
mkdir -p ~/PPA/nginx && cd ~/PPA/nginx \
|| ppa_error "Unable to create ~/PPA, exit status = " $?

# Download NGINX
ppa_lib_echo "Download nginx, please wait"
wget -c http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
|| ppa_error "Unable to download nginx-${NGINX_VERSION}.tar.gz, exit status = " $?
tar -zxvf nginx-${NGINX_VERSION}.tar.gz \
|| ppa_error "Unable to extract nginx, exit status = " $?
cd nginx-${NGINX_VERSION} \
|| ppa_error "Unable to change directory, exit status = " $?

# Lets start building
ppa_lib_echo "Execute: dh_make --single --native --copyright gpl --email $EMAIL_ADDRESS , please wait"
dh_make --single --native --copyright gpl --email $EMAIL_ADDRESS \
|| ppa_error "Unable to run dh_make command, exit status = " $?
rm debian/*.ex debian/*.EX \
|| ppa_error "Unable to remove unwanted files, exit status = " $?

# Lets copy files
ppa_lib_echo "Copy Launchpad Debian files, please wait"
rm -rf /tmp/launchpad && git clone https://github.com/MiteshShah/launchpad.git /tmp/launchpad \
|| ppa_error "Unable to clone launchpad repo, exit status = " $?
cp -av /tmp/launchpad/nginx/debian/* ~/PPA/nginx/nginx-${NGINX_VERSION}/debian/ && \
cp -v debian/changelog debian/NEWS.Debian \
|| ppa_error "Unable to copy launchpad debian files, exit status = " $?



# NGINX modules
ppa_lib_echo "Downloading NGINX modules, please wait"
mkdir ~/PPA/nginx/modules && cd ~/PPA/nginx/modules \
|| ppa_error "Unable to create ~/PPA/nginx/modules, exit status = " $?

ppa_lib_echo "1/13 headers-more-nginx-module"
git clone https://github.com/agentzh/headers-more-nginx-module.git \
|| ppa_error "Unable to clone headers-more-nginx-module repo, exit status = " $?

ppa_lib_echo "2/13 naxsi "
git clone https://github.com/nbs-system/naxsi \
|| ppa_error "Unable to clone naxsi repo, exit status = " $?
cp -av ~/PPA/nginx/modules/naxsi/naxsi_config/naxsi_core.rules ~/PPA/nginx/nginx-${NGINX_VERSION}/debian/conf/ \
|| ppa_error "Unable to copy naxsi files, exit status = " $?

ppa_lib_echo "3/13 nginx-auth-pam"
wget http://web.iti.upv.es/~sto/nginx/ngx_http_auth_pam_module-1.3.tar.gz \
|| ppa_error "Unable to download ngx_http_auth_pam_module-1.3.tar.gz, exit status = " $?
tar -zxvf ngx_http_auth_pam_module-1.3.tar.gz \
|| ppa_error "Unable to extract ngx_http_auth_pam_module-1.3, exit status = " $?
mv ngx_http_auth_pam_module-1.3 nginx-auth-pam \
|| ppa_error "Unable to rename ngx_http_auth_pam_module-1.3, exit status = " $?
rm ngx_http_auth_pam_module-1.3.tar.gz \
|| ppa_error "Unable to remove ngx_http_auth_pam_module-1.3.tar.gz, exit status = " $?

ppa_lib_echo "4/13 nginx-cache-purge"
git clone https://github.com/FRiCKLE/ngx_cache_purge.git nginx-cache-purge \
|| ppa_error "Unable to clone nginx-cache-purge repo, exit status = " $?

ppa_lib_echo "5/13 nginx-dav-ext-module"
git clone https://github.com/arut/nginx-dav-ext-module.git \
|| ppa_error "Unable to clone nginx-dav-ext-module repo, exit status = " $?

ppa_lib_echo "6/13 nginx-development-kit"
git clone https://github.com/simpl/ngx_devel_kit.git nginx-development-kit \
|| ppa_error "Unable to clone nginx-development-kit repo, exit status = " $?

ppa_lib_echo "7/13  nginx-echo"
git clone https://github.com/agentzh/echo-nginx-module.git nginx-echo \
|| ppa_error "Unable to clone nginx-echo repo, exit status = " $?

ppa_lib_echo "8/13 nginx-http-push"
git clone https://github.com/slact/nginx_http_push_module.git nginx-http-push \
|| ppa_error "Unable to clone nginx-http-push repo, exit status = " $?

ppa_lib_echo "9/13 nginx-lua"
git clone https://github.com/chaoslawful/lua-nginx-module.git nginx-lua \
|| ppa_error "Unable to clone nginx-lua repo, exit status = " $?

ppa_lib_echo "10/13 nginx-upload-progress-module"
git clone https://github.com/masterzen/nginx-upload-progress-module.git nginx-upload-progress \
|| ppa_error "Unable to clone nginx-upload-progress repo, exit status = " $?

ppa_lib_echo "11/13 nginx-upstream-fair"
git clone https://github.com/gnosek/nginx-upstream-fair.git \
|| ppa_error "Unable to clone nginx-upstream-fair repo, exit status = " $?

ppa_lib_echo "12/13 nginx-http-subs"
git clone git://github.com/yaoweibin/ngx_http_substitutions_filter_module.git nginx-http-subs \
|| ppa_error "Unable to clone nginx-http-subs repo, exit status = " $?

ppa_lib_echo "13/13 ngx_pagespeed"
NPS_VERSION=1.8.31.4
wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.tar.gz
tar -zxvf release-${NPS_VERSION}-beta.tar.gz
mv ngx_pagespeed-release-${NPS_VERSION}-beta  ngx_pagespeed
rm release-${NPS_VERSION}-beta.tar.gz

cd ngx_pagespeed
wget -O psol.tar.gz https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz


cp -av ~/PPA/nginx/modules ~/PPA/nginx/nginx-${NGINX_VERSION}/debian/ \
|| ppa_error "Unable to copy launchpad modules files, exit status = " $?
