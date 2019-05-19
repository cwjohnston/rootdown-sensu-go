#!/usr/bin/env bash
    
backend_url="wss://192.168.10.102:8081"
subscriptions=docker,linux

case $1 in
create)
  count=0

  if [ -n "${2}" ] && [ "${2}" -eq "${2}" ] 2>/dev/null; then
    count=$2
  else
    echo "${0} create: \"${2}\" is not a number"
    exit 1
  fi
  
  for _ in $(seq "$count") ; do
    name=sensu-agent-$(openssl rand -hex 6)
    docker run -d --name "${name}" docker.io/sensu/sensu:latest sensu-agent start \
                --backend-url "${backend_url}" \
                --insecure-skip-tls-verify \
                --subscriptions=${subscriptions} \
                --deregister=true \
                --name "${name}"
  done
  ;;
cleanup)
  docker ps --format '{{.Names}}\t{{.ID}}' | grep -E 'sensu-agent-[0-9a-fA-F]+' | cut  -f 2 | xargs docker kill
  ;;
*)
  cat <<EOH
Usage: $0 COMMAND"
Commands:
  create COUNT              Provisions indicated count of sensu-agent 
  cleanup                   Kill containers provisioned by this script"
EOH
esac