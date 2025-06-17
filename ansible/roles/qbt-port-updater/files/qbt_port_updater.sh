#!/usr/bin/env bash

QBT_USERNAME=${QBT_USERNAME:-admin}
QBT_PASSWORD=${QBT_PASSWORD:-adminadmin}

QBT_URL=${QBT_URL:-http://localhost:8080}

COOKIE_JAR=$(mktemp)

fail () {
  printf '%s\n' "$1" >&2
  return "${2:-1}"
}

login_qbt() {
  body=$(curl -s "${QBT_URL}/api/v2/auth/login" \
    --fail-with-body \
    -c $COOKIE_JAR \
    --data-urlencode username=${QBT_USERNAME} \
    --data-urlencode password=${QBT_PASSWORD}
  )
  code=$?

  [[ $body == "Fails." ]] && return 1
  return $code
}

logout_qbt() {
  curl -s "${QBT_URL}/api/v2/auth/logout" \
    -X POST \
    -b $COOKIE_JAR \
    -c $COOKIE_JAR \
    > /dev/null
}

get_current_qbt_port() {
  curl -s "${QBT_URL}/api/v2/app/preferences" \
    --fail-with-body \
    -b $COOKIE_JAR \
    -c $COOKIE_JAR \
  | perl -ne '/"listen_port":\s?(\d+),/ && print $1'
}

set_qbt_port() {
  body=$(printf '{"listen_port": %d}' "$1")

  curl "${QBT_URL}/api/v2/app/setPreferences" \
    --fail-with-body \
    -s \
    -X POST \
    -b $COOKIE_JAR \
    -c $COOKIE_JAR \
    --data-urlencode "json=${body}"
}

isnumber() {
  [[ $1 =~ ^[0-9]+$ ]]
}

run() {
  udp_port=$(natpmpc -a 1 0 udp 60 -g "$PROTONVPN_IP" 2>&1 | tee /root/natpmpc_udp.log | perl -ne '/Mapped public port (\d+)/ && print "$1"')
  tcp_port=$(natpmpc -a 1 0 tcp 60 -g "$PROTONVPN_IP" | perl -ne '/Mapped public port (\d+)/ && print "$1"')

  [[ -z $udp_port ]] && fail "failed to get port from natpmpc"

  [[ $udp_port == $tcp_port ]] || fail "ports are not the same udp=$udp_port tcp=$tcp_port"

  qbt_port=$(get_current_qbt_port)

  if isnumber $qbt_port && [[ $qbt_port == $udp_port ]] ; then
    echo "ports already match: $qbt_port" >&2
    return 0
  fi

  set_qbt_port $tcp_port
  echo "set qbittorrent port to: $tcp_port"
}

cleanup() {
  logout_qbt
  rm -f $COOKIE_JAR
}
trap cleanup SIGINT EXIT

login_qbt
while true ; do
  run
  sleep 45
done
