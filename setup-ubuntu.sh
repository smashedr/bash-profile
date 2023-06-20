#!/usr/bin/env bash
# bash <(curl -sL http://scripts.cssnr.com/systems/setup-ubuntu.sh)

# arbitrary certificate information - the empty 2 lines at the end are required
_domain="cssnr.com"
_resp="US
Washington
Seattle
cssnr
Hosting
${_domain}
admin@cssnr.com

"

source /etc/lsb-release
if [[ "${DISTRIB_ID}" != "Ubuntu" ]];then
    echo "Unsupported operating system: $(cat /etc/lsb-release)" 2>&1
    exit 1
fi

[[ ! -$(id -u) -eq 0 ]] && echo "Must be root." 2>&1 && exit 1

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Updating and installing programs via apt..."

apt-get -y purge \
    popularity-contest \
    unattended-upgrades

apt-get -y update
apt-get -y install \
    apache2-utils \
    build-essential \
    ca-certificates \
    git \
    glances \
    gnupg \
    htop \
    iotop \
    iperf3 \
    lftp \
    mtr \
    net-tools \
    nmap \
    python3-dev \
    python3-pip \
    rsync \
    screen \
    strace \
    tree \
    unzip \
    vim \
    whois \


apt-get -y autoremove --purge
apt-get -y clean

if [ ! -f "/etc/ssl/private/${_domain}.key" ];then
    echo "Generating SSL Certificate: /etc/ssl/private/${_domain}.crt"
    echo "${_resp}" | openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout \
        "/etc/ssl/private/${_domain}.key" -out \
        "/etc/ssl/private/${_domain}.crt"
    mkdir -p /etc/ssl/private/
    ln -sf "/etc/ssl/private/${_domain}.key" "/etc/ssl/certs/${_domain}.key"
    ln -sf "/etc/ssl/private/${_domain}.crt" "/etc/ssl/certs/${_domain}.crt"
fi

if [ -n "${SUDO_USER}" ];then
    echo "Enable sudo for: ${SUDO_USER}"
    echo "${SUDO_USER} ALL=(ALL) NOPASSWD: ALL" >"/etc/sudoers.d/${SUDO_USER}"
    echo 'shane:$apr1$8fQDoiqW$FqqtZZ4SHqjfkOMF1.zFs.' > "/home/${SUDO_USER}/basic_http_auth"
    chmod "${SUDO_USER}:${SUDO_USER}" "/home/${SUDO_USER}/basic_http_auth"
#    sudo -H -u "${SUDO_USER}" bash -c 'bash <(curl -Lks http://scripts.cssnr.com/key.sh)'
fi
#bash <(curl -Lks http://scripts.cssnr.com/key.sh)

_tmp=$(mktemp -d)
curl -LsS "https://github.com/smashedr/bash-profile/archive/refs/heads/master.zip" -o "${_tmp}/master.zip"
unzip "${_tmp}/master.zip" -d "${_tmp}"
echo Adding bash profiles to /etc/profile.d: $(ls ${_tmp}/bash-profile-master/profile/*.sh | xargs -n 1 basename)
cp -f "${_tmp}"/bash-profile-master/profile/*.sh /etc/profile.d

# sysctl

sysctl vm.swappiness=30
sysctl net.ipv4.ip_forward=1
sysctl net.ipv6.conf.all.forwarding=1
echo '
vm.swappiness = 30
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
' >> /etc/sysctl.d/99-cssnr.conf

if [ -n "${SUDO_USER}" ];then
    echo "source /etc/profile.d/cssnr.sh" >> "/home/${SUDO_USER}/.bashrc"
fi
echo "source /etc/profile.d/cssnr.sh" >> "/root/.bashrc"

echo "All done."
