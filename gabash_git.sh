__GABASH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! declare -F __gabash_register_module >/dev/null 2>&1; then
  source "$__GABASH_SCRIPT_DIR/gabash_internal.sh"
fi
__gabash_register_module "git"
unset __GABASH_SCRIPT_DIR

#### shortcuts for working with Git

function cb() {
  echo "Cleaning up local branches deleted from the server..."
  git fetch --prune && for branch in \
    $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | \
    awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); \
    do git branch -D $branch; done
  echo "Cleanup done!"
}

function gb() {
  if [[ -z "$1" ]]
  then
    git branch
  else
    git branch "$@"
  fi
}

function gd() {
  if [[ -z "$1" ]]
  then
    git diff .
  else
    git diff "$@"
  fi
}

function gf() {
  git fetch --all
}

function gpull() {
  if [[ -z "$1" ]]
  then
    git pull
  else
    git pull "$@"
  fi
}

function gpush() {
  if [[ -z "$1" ]]
  then
    git push
  else
    git push "$@"
  fi
}

function gmerge() {
  if [[ -z "$1" ]]
  then
    git merge
  else
    git merge "$@"
  fi
}

function gsb() {
  if [[ -z "$1" ]]
  then
    echo "Missing parameter: branch name"
  else
    git switch "$@"
  fi
}

function gr() {
  if [[ -z "$1" ]]
  then
    echo "Missing parameter: directory/directories or file(s)"
  else
    git restore "$@"
  fi
}

function gs() {
  git status
}

function glog() {
  local count="${1:-1}"
  git log -n "$count"
}


function ga() {
  if [[ -z "$1" ]]
  then
    echo "Missing parameter: directory/directories or file(s)"
  else
    git add "$@"
  fi
}


function gcom() {
  if [[ -z "$1" ]]
  then
    echo "Missing parameter: message"
  else
    git commit -m "$*"
  fi
}


function grs() {
  if [[ -z "$1" ]]
  then
    echo "Missing parameter: directory/directories or file(s)"
  else
    git reset "$@"
  fi
}


function gclean() {
  if [[ "$1" != "--confirm" ]]; then
    echo "Refused: gclean requires --confirm"
    return 1
  fi

  git reset --hard HEAD
  git clean -fd
}

function  gx() {
  if [[ -z "$1" ]]
  then
    echo "Missing parameter: directory/directories or file(s)"
  else
    git update-index --chmod=+x "$@"
  fi
}
