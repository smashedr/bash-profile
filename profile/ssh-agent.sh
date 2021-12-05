[[ -z "$PS1" ]] && return
[[ "$(id -u)" = "0" ]] && return

SSH_AUTH_SOCK=$(ls -l /tmp/ssh-*/agent.* 2>/dev/null | grep "${USER}" | awk '{print $NF}' | head -n1)
SSH_AGENT_PID=$(pgrep ssh-agent | xargs --no-run-if-empty ps -fp | grep "${USER}" | awk '{print $2}' | head -n1)
if [[ -S "${SSH_AUTH_SOCK}" ]] && [[ -n "${SSH_AGENT_PID}" ]];then
   export SSH_AUTH_SOCK SSH_AGENT_PID
else
   eval $(ssh-agent -s) >/dev/null 2>&1
fi

if ! ssh-add -l 2>/dev/null;then
    if ! ssh-add;then
        echo "ssh-agent.sh error running: ssh-add"
        if [[ $(ls -l /tmp/ssh-*/agent.* 2>/dev/null | wc -l) -gt 1 ]];then
            echo "Found multiple ssh agent sockets for your user:"
            ls -l /tmp/ssh-*/agent.*
        fi
    fi
fi
