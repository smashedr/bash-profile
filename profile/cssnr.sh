[[ -z "$PS1" ]] && return

if [[ $(id -u) = 0 ]];then
    if [[ -f "/usr/local/public/.prod" ]];then
        # root - prod
        PS1="\[\033[01;37m\]\$? \[\033[01;33m\]\u\[\033[00m\]@\[\033[01;31m\]\H\[\033[00m\] [\[\033[01;37m\]\$PWD\[\033[00m\]]\[\033[01;31m\]\$\[\033[00m\] "
    else
        # root - non-prod
        PS1="\[\033[01;37m\]\$? \[\033[00;33m\]\u\[\033[00m\]@\[\033[00;31m\]\H\[\033[00m\] [\[\033[01;37m\]\$PWD\[\033[00m\]]\[\033[00;31m\]\$\[\033[00m\] "
    fi
else
    if [[ -f "/usr/local/public/.prod" ]];then
        # non-root - prod
        PS1="\[\033[01;37m\]\$? \[\033[01;36m\]\u\[\033[00m\]@\[\033[01;32m\]\H\[\033[00m\] [\[\033[01;37m\]\$PWD\[\033[00m\]]\[\033[01;32m\]\$\[\033[00m\] "
    else
        #non-root - non-prod
        PS1="\[\033[01;37m\]\$? \[\033[00;36m\]\u\[\033[00m\]@\[\033[00;32m\]\H\[\033[00m\] [\[\033[01;37m\]\$PWD\[\033[00m\]]\[\033[00;32m\]\$\[\033[00m\] "
    fi
fi

shopt -s histappend
shopt -s checkwinsize

export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT="%y/%m/%d %T "

export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH
export EDITOR='/usr/bin/vim'
export LOGLEVEL=DEBUG

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias l='ls -hl --color=auto'
alias ls='ls --color=auto'
alias ll='ls -Ahl --color=auto'
alias la='ls -ahl --color=auto'

alias g='glances'
alias n='sudo nmap'
alias p='ping'
alias v='view'
alias h='hostname'
alias t='traceroute'
alias sv='sudo vim'
alias svim='sudo vim'

alias scat='sudo cat'
alias ccat="grep -v '^$\|^\s*\#'"
alias cls="clear && printf '\e[3J'"
alias cpd='cp -r'
alias ssu='sudo -E su -l'
alias listen='sudo ss -ltpn'
alias sc='sudo systemctl --no-pager -l'

function c() { cd "$@" && ls -lAh ; }
function mkdc() { mkdir -p "$1" && cd "$1" ; }

function lower() { tr '[:upper:]' '[:lower:]' ; }
function upper() { tr '[:lower:]' '[:upper:]' ; }

alias rmpyc='find . -type f -name "*.pyc" -exec rm -f {} \;; find . -type d -name '__pycache__' -exec rm -rf {} \;'
alias rmmigrations='find . -type f -name "00*" -not -path "./venv/*" -exec rm -vf {} \;'

alias ntest='sudo nginx -t'
alias atest='sudo apachectl configtest'
alias vhosts='sudo apachectl -S | grep namevhost | sort | uniq'

alias dls='sudo /usr/bin/docker container ls'
alias dsls='sudo /usr/bin/docker service ls'
alias dcup='sudo /usr/local/bin/docker-compose up --remove-orphans --build -d'
alias dcdown='sudo /usr/local/bin/docker-compose down --remove-orphans'

alias certexp='openssl x509 -enddate -noout -in'
alias ipp='curl -LksSm5 ip.me 2>/dev/null || curl -LksSm5 ifconfig.me 2>/dev/null || echo "Error."'

alias dm='python manage.py'
alias dmrs='python manage.py runserver_plus 0.0.0.0:8000'
alias dmcs='python manage.py createsuperuser'
alias dmmm='python manage.py makemigrations'
alias dmm='python manage.py migrate'

function s() { sudo -E su; }

function dexec() {
    _id="$1";shift 1
    [[ -n "$1" ]] && _exec="$@" || _exec="/bin/sh"
    sudo /usr/bin/docker exec -it "${_id}" ${_exec}
}

alias highstate='sudo salt-call state.highstate'
alias state='sudo salt-call state.apply'

function myhighstate() {
    [[ -n "$1" ]] && SALTENV="saltenv=$1" && shift 1
    sudo salt-call state.highstate "${SALTENV}" $@
}

function mystate() {
    [[ -z "$2" ]] && echo "Usage: mystate [state] [branch]" && return
    _state="$1";_branch="$2";shift 2
    sudo salt-call state.apply "$_state" saltenv="$_branch" $@
}

function epoch() { date -d \@$1 ; }

function windate() {
    _epoch=$((($1/10000000)-11676009600));
    date -d \@${_epoch};
}

function distro() {
    python -mplatform 2>/dev/null || python3 -mplatform || echo "python not found."
}

function rand() {
    [[ -n "$1" ]] && _L="$1" || _L="32"
    _T=(expr 0 + "${_L}")
    [[ "$?" != "0" ]] && return
    cat /dev/urandom | tr -dc 'A-Za-z0-9' | head -c ${_L}
    echo
}

function i() {
    _H=$(host $1)
    [[ "$?" != "0" ]] && echo "${_H}" && return 1
    _P=$(ping -c3 -W3 $1 &)
    _N=$(sudo nmap --host-timeout 4 $1 &)
    wait
    echo -e "-- host --\n${_H}\n-- ping --\n${_P}\n-- nmap --\n${_N}"
}

function backup() {
    [[ -z "$1" ]] && echo "Usage: backup [file] (stored in ~/.backup)" && return;
    mkdir ~/.backup >/dev/null 2>&1;
    i="$(date +%m%d%H%M%S)";
    for s in "$@";
    do
        d=$(basename "$s");
        cp -rf "${s}" "${HOME}/.backup/${d}_${i}";
    done
}
function trash() {
    [[ -z "$1" ]] && echo "Usage: trash [file] (-e to empty the ~/.trash)" && return;
    if [ "$1" = "-e" ]; then
        echo -n "Empty ~/.trash? [yes]: ";
        read;
        rm -i -rf ~/.trash/*;
        return;
    fi;
    mkdir ~/.trash >/dev/null 2>&1;
    i="$(date +%m%d%H%M%S)";
    for s in "$@";
    do
        d=$(basename "$s");
        mv -f "${s}" "${HOME}/.trash/${d}_${i}";
    done
}

function shutdown() {
    echo -n "Are you sure you want to shutdown ${HOSTNAME} ? (y/n) ";
    read ANSWER;
    [[ "${ANSWER}" = "y" ]] && /sbin/shutdown $@
}
function reboot() {
    echo -n "Are you sure you want to reboot ${HOSTNAME} ? (y/n) ";
    read ANSWER;
    [[ "${ANSWER}" = "y" ]] && /sbin/reboot $@
}

function venv2() {
    echo "WARNING: This version of python is deprecated! DO NOT USE!"
    [[ -n "$1" ]] && _VENV="$1" || _VENV="venv"
    [[ -n "$2" ]] && _RTXT="$2" || _RTXT="requirements.txt"
    if [[ ! -d "${_VENV}" ]];then
        virtualenv "${_VENV}"
    fi
    source "${_VENV}/bin/activate"
    python -m pip install --upgrade pip
    [[ -f "${_RTXT}" ]] && python -m pip install -Ur "${_RTXT}"
}
function _venv3() {
    [[ -n "$1" ]] && _PYV="$1" || _PYV="python3"
    [[ -n "$2" ]] && _VENV="$2" || _VENV="venv"
    [[ -n "$3" ]] && _RTXT="$3" || _RTXT="requirements.txt"
    if ! command -v "${_PYV}";then
        echo "${_PYV} not found." && return
    fi
    if [[ ! -d "${_VENV}" ]];then
        ${_PYV} -m venv "${_VENV}"
    fi
    source "${_VENV}/bin/activate"
    python -m pip install --upgrade pip
    [[ -f "${_RTXT}" ]] && python -m pip install -Ur "${_RTXT}"
}
alias venv3='_venv3 python3'
alias venv36='_venv3 python3.6'
alias venv38='_venv3 python3.8'
alias venv39='_venv3 python3.9'

function prod() {
    if [[ -f "/usr/local/public/.prod" ]];then
        rm -f "/usr/local/public/.prod" && \
            bash "/etc/motd.sh" "quiet" && \
            echo "Prodduction: off" && \
            source "/etc/profile.d/cssnr.sh"
    else
        touch "/usr/local/public/.prod" && \
            chmod 0666 "/usr/local/public/.prod"
            bash "/etc/motd.sh" "quiet" && \
            echo "Prodduction: on" && \
            source "/etc/profile.d/cssnr.sh"
    fi
}

if [[ -r ~/.hostrc ]];then
    source ~/.hostrc;
fi

[[ -n "${_cssnr}" ]] && return

if [[ $(id -u) = 0 ]];then
    echo -e "\033[01;31mYou are logged in as the \"${USER}\" user. Please be careful!\033[00m"
else
    echo -e "\033[01;32mYou are logged in as \"${USER}\". You can type \"s\" to become root.\033[00m"
fi

_cssnr="true"
