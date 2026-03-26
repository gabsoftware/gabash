__GABASH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! declare -F __gabash_register_module >/dev/null 2>&1; then
  source "$__GABASH_SCRIPT_DIR/gabash_internal.sh"
fi
__gabash_register_module "git"
unset __GABASH_SCRIPT_DIR

#### raccourcis pour travailler avec Git

function cb() {
  echo "Nettoyage des branches locales supprimées du serveur..."
  git fetch --prune && for branch in \
    $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | \
    awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); \
    do git branch -D $branch; done
  echo "Nettoyage terminé !"
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

function gc() {
  if [[ -z "$1" ]]
  then
    echo "Paramètre manquant : répertoire(s), fichier(s) ou nom de branche"
  else
    local has_path_arg=0
    local has_explicit_separator=0
    local arg
    for arg in "$@"; do
      if [[ "$arg" == "--" ]]; then
        has_explicit_separator=1
        break
      fi
      if [[ -e "$arg" ]]; then
        has_path_arg=1
        break
      fi
    done

    if [[ $has_explicit_separator -eq 1 || $has_path_arg -eq 1 ]]; then
      git restore "$@"
    else
      git switch "$@"
    fi
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
    echo "Paramètre manquant : répertoire(s) ou fichier(s)"
  else
    git add "$@"
  fi
}


function gcom() {
  if [[ -z "$1" ]]
  then
    echo "Paramètre manquant : message"
  else
    git commit -m "$*"
  fi
}


function gr() {
  if [[ -z "$1" ]]
  then
    echo "Paramètre manquant : répertoire(s) ou fichier(s)"
  else
    git reset "$@"
  fi
}


function gclean() {
  if [[ "$1" != "--confirm" ]]; then
    echo "Refus: gclean requires --confirm"
    return 1
  fi

  git reset --hard HEAD
  git clean -fd
}

function  gx() {
  if [[ -z "$1" ]]
  then
    echo "Paramètre manquant : répertoire(s) ou fichier(s)"
  else
    git update-index --chmod=+x "$@"
  fi
}
