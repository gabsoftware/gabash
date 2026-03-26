__GABASH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! declare -F __gabash_register_module >/dev/null 2>&1; then
  source "$__GABASH_SCRIPT_DIR/gabash_internal.sh"
fi
__gabash_register_module "nginx"
unset __GABASH_SCRIPT_DIR

#### raccourcis pour travailler avec nginx

function ngr() {
  sudo service nginx restart
}

function ngt() {
  sudo nginx -t
}
