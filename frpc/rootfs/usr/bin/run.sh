#!/usr/bin/with-contenv bash
set -euo pipefail
. /usr/lib/bashio

CONFIG_DIR=/data/frpc
OPTIONS_FILE="/data/options.json"

mkdir -p "$CONFIG_DIR"

if [ ! -f "$OPTIONS_FILE" ]; then
  bashio::log.warning "No options.json found. Did Home Assistant pass options?"
fi

servers_count=$(jq '.servers | length' "$OPTIONS_FILE" 2>/dev/null || echo 0)

if [ "$servers_count" -eq 0 ]; then
  bashio::log.warning "No servers configured. Add at least one under 'servers' in the add-on options."
  # Keep the service alive so the container doesn't exit
  tail -f /dev/null
fi

# Generate a frpc ini per server
for idx in $(seq 0 $((servers_count-1))); do
  name=$(jq -r ".servers[$idx].name" "$OPTIONS_FILE")
  server_addr=$(jq -r ".servers[$idx].server_addr" "$OPTIONS_FILE")
  server_port=$(jq -r ".servers[$idx].server_port" "$OPTIONS_FILE")
  token=$(jq -r ".servers[$idx].token // empty" "$OPTIONS_FILE")
  user=$(jq -r ".servers[$idx].user // empty" "$OPTIONS_FILE")
  log_level=$(jq -r ".servers[$idx].log_level // \"info\"" "$OPTIONS_FILE")

  cfg="$CONFIG_DIR/${name}.ini"
  {
    echo "[common]"
    echo "server_addr = ${server_addr}"
    echo "server_port = ${server_port}"
    [ -n "$token" ] && echo "token = ${token}"
    [ -n "$user" ] && echo "user = ${user}"
    echo "log_level = ${log_level}"
  } > "$cfg"

  proxies_count=$(jq ".servers[$idx].proxies | length" "$OPTIONS_FILE" 2>/dev/null || echo 0)

  for p in $(seq 0 $((proxies_count-1))); do
    pname=$(jq -r ".servers[$idx].proxies[$p].name" "$OPTIONS_FILE")
    ptype=$(jq -r ".servers[$idx].proxies[$p].type" "$OPTIONS_FILE")
    local_ip=$(jq -r ".servers[$idx].proxies[$p].local_ip" "$OPTIONS_FILE")
    local_port=$(jq -r ".servers[$idx].proxies[$p].local_port" "$OPTIONS_FILE")
    remote_port=$(jq -r ".servers[$idx].proxies[$p].remote_port // empty" "$OPTIONS_FILE")
    subdomain=$(jq -r ".servers[$idx].proxies[$p].subdomain // empty" "$OPTIONS_FILE")

    {
      echo ""
      echo "[$pname]"
      echo "type = $ptype"
      echo "local_ip = $local_ip"
      echo "local_port = $local_port"
      [ -n "$remote_port" ] && echo "remote_port = $remote_port"
      [ -n "$subdomain" ] && echo "subdomain = $subdomain"
    } >> "$cfg"

    # custom_domains (multiple values allowed)
    has_custom=$(jq -r ".servers[$idx].proxies[$p].custom_domains | type" "$OPTIONS_FILE" 2>/dev/null || echo "")
    if [ "$has_custom" = "array" ]; then
      jq -r ".servers[$idx].proxies[$p].custom_domains[]?" "$OPTIONS_FILE" | while read -r domain; do
        echo "custom_domains = $domain" >> "$cfg"
      done
    fi

    # any extra raw lines like key=value
    jq -r ".servers[$idx].proxies[$p].additional_params[]?" "$OPTIONS_FILE" >> "$cfg"
  done

done

# Launch an frpc process per server config file
pids=()
for ini in "$CONFIG_DIR"/*.ini; do
  [ -e "$ini" ] || continue
  bashio::log.info "Starting frpc with $(basename "$ini")"
  /usr/local/bin/frpc -c "$ini" &
  pids+=($!)
done

# Wait on any child exit; if any quits, stop the container
wait -n "${pids[@]}"
exit $?
