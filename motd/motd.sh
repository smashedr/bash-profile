#!/usr/bin/env bash

#[[ -f "/etc/motd.env" ]] && source "/etc/motd.env" || exit
source /etc/lsb-release

_PUB_IP=$(curl -LksSm4 ifconfig.me 2>/dev/null || \
          curl -LksSm4 api.ipify.org 2>/dev/null || \
          curl -LksSm2 ip.me 2>/dev/null || \
          echo Unknown)
_LOC_IP=$(ip route get 1.2.3.4 | awk '{print $7}' | head -1)

_LOAD="$(uptime | awk -F'[a-z]: ' '{ print $2}')"

_DF=$(df -h / | tail -n 1)
_DF_OUT="$(echo ${_DF} | awk '{print $3}')/$(echo ${_DF} | awk '{print $2}') ($(echo ${_DF} | awk '{print $5}'))"

_F_M=$(free -m | grep ^Mem )
_F_M_OUT="$(echo ${_F_M} | awk '{print $3}')/$(echo ${_F_M} | awk '{print $2}') ($(echo ${_F_M} | awk '{print $4}') free)"

_F_S=$(free -m | grep ^Swap )
_F_S_DATA="$(echo ${_F_S} | awk '{print $3}')/$(echo ${_F_S} | awk '{print $2}') ($(echo ${_F_S} | awk '{print $4}') free)"
[[ "$(echo ${_F_S} | awk '{print $2}')" -ne "0" ]] && _F_S_OUT="\n\033[01;36m Swap:\033[00m           ${_F_S_DATA}" || _F_S_OUT=""

_SALT_F=$(grep ^Failed /var/log/salt/cron | awk '{print $2}')
if [[ -n "${_SALT_F}" ]];then
    [[ "${_SALT_F}" = "0" ]] && _SALT_F_DATA="\033[00;32m${_SALT_F} - Salt OK" || _SALT_F_DATA="\033[00;31m${_SALT_F} - Salt ERRORS"
    _SALT_F_OUT="\n\033[01;36m Salt Failed:\033[00m    ${_SALT_F_DATA}"
fi

echo -ne "\
\033[01;32mHello and welcome to your host.\033[00m
\033[01;37m----------------------------------------\033[00m
\033[01;36m Distribution:\033[00m   ${DISTRIB_DESCRIPTION}
\033[01;36m Hostname:\033[00m       ${HOSTNAME//.*/} - ${HOSTNAME}
\033[01;36m Public IP:\033[00m      ${_PUB_IP}
\033[01;36m Local IP:\033[00m       ${_LOC_IP}
\033[01;36m Load:\033[00m           ${_LOAD}
\033[01;36m Disk:\033[00m           ${_DF_OUT}
\033[01;36m Memory:\033[00m         ${_F_M_OUT}${_F_S_OUT}${_SALT_F_OUT}
\033[01;37m----------------------------------------\033[00m
\n" > "/etc/motd"

if [[ -z "$1" ]];then
    echo -e "\nchanged=false comment='MOTD File OK'"
fi
