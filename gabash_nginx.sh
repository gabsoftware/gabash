__GABASH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! declare -F __gabash_register_module >/dev/null 2>&1; then
  source "$__GABASH_SCRIPT_DIR/gabash_internal.sh"
fi
__gabash_register_module "nginx"
unset __GABASH_SCRIPT_DIR

#### shortcuts for working with nginx

function __nginx_has_service() {
  [ -x /usr/sbin/service ]
}

function __nginx_has_systemctl() {
  [ -x /usr/bin/systemctl ]
}

function ngr() {
  if __nginx_has_service; then
    if sudo service nginx status > /dev/null 2>&1; then
      sudo service nginx stop
    fi
    sudo service nginx start
  elif __nginx_has_systemctl; then
    if sudo systemctl is-active --quiet nginx; then
      sudo systemctl stop nginx
    fi
    sudo systemctl start nginx
  else
    echo "ngr: neither service nor systemctl found"
    return 1
  fi
}

function ngt() {
  sudo nginx -t
}

function ngs() {
  if __nginx_has_service; then
    sudo service nginx status
  elif __nginx_has_systemctl; then
    sudo systemctl status nginx
  else
    echo "ngs: neither service nor systemctl found"
    return 1
  fi
}

