#dev=$(ip r | grep '^default' | awk '{print $5}')
#local=$(ip a show dev "${dev}" | grep -m1 inet | awk '{print $2}' | cut -d/ -f1)

local=$(ip route get 1.2.3.4 | awk '{print $7}' | head -1)
remote=$(curl -LksSm5 ifconfig.me 2>/dev/null || \
         curl -LksSm5 api.ipify.org 2>/dev/null || \
         echo Unknown)

echo -ne "\n
\033[01;37m----------------------------------------\033[00m
\033[01;36m OS Finger:\033[00m      ${OSFINGER}
\033[01;36m Hostname:\033[00m       ${HOSTNAME} - ${BASENAME}
\033[01;36m Public IP:\033[00m      ${_PUB_IP}
\033[01;36m Load:\033[00m           ${_LOAD}
\033[01;36m Disk:\033[00m           ${_DF_OUT}
\033[01;36m Memory:\033[00m         ${_F_M_OUT}${_F_S_OUT}${_SALT_F_OUT}
\033[01;37m----------------------------------------\033[00m
\n" >> "/etc/motd"