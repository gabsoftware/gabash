#### internal helpers for gabash

if [[ -z "${__GABASH_INTERNAL_LOADED:-}" ]]; then
  __GABASH_INTERNAL_LOADED=1
  __GABASH_VERSION="${GABASH_VERSION:-dev}"
  declare -ag __GABASH_ENABLED_MODULES=()

  __gabash_has_module() {
    local module="$1"
    local existing
    for existing in "${__GABASH_ENABLED_MODULES[@]}"; do
      if [[ "$existing" == "$module" ]]; then
        return 0
      fi
    done
    return 1
  }

  __gabash_register_module() {
    local module="$1"
    if [[ -z "$module" ]]; then
      return 1
    fi

    if ! __gabash_has_module "$module"; then
      __GABASH_ENABLED_MODULES+=("$module")
    fi
  }

  __gabash_list_module_command_names() {
    local module="$1"

    case "$module" in
      nginx)
        echo "ngr"
        echo "ngt"
        ;;
      git)
        echo "cb"
        echo "ga"
        echo "gb"
        echo "gc"
        echo "gd"
        echo "gf"
        echo "gr"
        echo "gs"
        echo "gcom"
        echo "glog"
        echo "gpull"
        echo "gpush"
        echo "gmerge"
        echo "gclean"
        echo "gx"
        ;;
      docker)
        echo "de"
        echo "dt"
        echo "dtl"
        echo "dp"
        echo "dpl"
        echo "dpush"
        echo "dpull"
        echo "dl"
        echo "dcb"
        echo "dcbnc"
        echo "dcu"
        echo "dcund"
        echo "dstop"
        echo "ddown"
        echo "dkill"
        echo "dps"
        echo "dlogs"
        echo "dexec"
        echo "dx"
;;
    esac
  }

  __gabash_list_loaded_command_names() {
    local module
    local ordered_modules=(nginx git docker)
    for module in "${ordered_modules[@]}"; do
      if __gabash_has_module "$module"; then
        __gabash_list_module_command_names "$module"
      fi
    done
  }

  __gabash_print_module_commands() {
    local module="$1"

    case "$module" in
      nginx)
        cat <<'EONGINX'
### Nginx
- ngr : Redemarre le service nginx
- ngt : Verifie la configuration du service nginx (nginx -t)
EONGINX
        ;;
      git)
        cat <<'EOGIT'
### Git
- cb : Nettoyage des branches locales supprimees du serveur
- ga : git add
- gb : git branch
- gc : git switch (branches) ou git restore (fichiers/chemins)
- gd : git diff
- gf : git fetch --all
- gr : git reset
- gs : git status
- gcom : git commit
- glog [number] : git log -n [number] (optionnel ; par defaut 1)
- gpull : git pull
- gpush : git push
- gmerge : git merge
- gclean --confirm : git reset --hard HEAD && git clean -fd
- gx : git update-index --chmod=+x
EOGIT
        ;;
      docker)
        cat <<'EODOCKER'
### Docker
- de <image_name> <tag> : verifie si l'image existe dans le votre registry perso
- dt <image_name> <tag> : docker tag (avec verification si le tag existe deja)
- dtl <image_name> <tag> : tag l'image avec le tag donne puis avec latest
- dp <image_name> <tag> : docker push (avec verification si le tag existe deja dans le registry)
- dpl <image_name> <tag> : push le tag donne puis latest
- dpush <image_name> <tag> : alias de dp
- dpull <image_name> [tag] : docker pull (tag par defaut: latest)
- dl : liste les images du votre registry perso
- dl <image_name> : liste les tags de l'image
- dcb <service_name> [service_name2 ...] : docker compose build
- dcbnc <service_name> [service_name2 ...] : docker compose build avec --no-cache
- dcu <service_name> [service_name2 ...] : docker compose up -d
- dcund <service_name> [service_name2 ...] : docker compose up -d --no-deps
- dstop <service_name> [service_name2 ...] : docker compose stop (docker stop si en dehors d'un projet avec compose)
- ddown <service_name> [service_name2 ...] : docker compose down
- dkill <service_name> [service_name2 ...] : docker compose kill (docker kill si en dehors d'un projet avec compose)
- dps [args ...] : docker compose ps (docker ps si en dehors d'un projet avec compose)
- dlogs <container_name_or_id> : docker logs --follow
- dexec <container_name_or_id> [args ...] : docker exec
- dx <container_name_or_id> [args ...] : alias de dexec
EODOCKER
        ;;
    esac
  }

  __gabash_print_command_help() {
    local command="$1"
    local module=""
    local usage=""
    local description=""

    case "$command" in
      gabash)
        module="internal"
        usage="gabash --help [command] | gabash --version"
        description="commande interne gabash"
        ;;
      ngr)
        module="nginx"
        usage="ngr"
        description="Redemarre le service nginx"
        ;;
      ngt)
        module="nginx"
        usage="ngt"
        description="Verifie la configuration du service nginx (nginx -t)"
        ;;
      cb)
        module="git"
        usage="cb"
        description="Nettoyage des branches locales supprimees du serveur"
        ;;
      ga)
        module="git"
        usage="ga <path_or_file> [path_or_file2 ...]"
        description="git add"
        ;;
      gb)
        module="git"
        usage="gb [args ...]"
        description="git branch"
        ;;
      gc)
        module="git"
        usage="gc <branch_or_path> [args ...]"
        description="git switch (branches) ou git restore (fichiers/chemins)"
        ;;
      gd)
        module="git"
        usage="gd [args ...]"
        description="git diff"
        ;;
      gf)
        module="git"
        usage="gf"
        description="git fetch --all"
        ;;
      gr)
        module="git"
        usage="gr <args ...>"
        description="git reset"
        ;;
      gs)
        module="git"
        usage="gs"
        description="git status"
        ;;
      gcom)
        module="git"
        usage="gcom <message>"
        description="git commit"
        ;;
      glog)
        module="git"
        usage="glog [number]"
        description="git log -n [number] (optionnel ; par defaut 1)"
        ;;
      gpull)
        module="git"
        usage="gpull [args ...]"
        description="git pull"
        ;;
      gpush)
        module="git"
        usage="gpush [args ...]"
        description="git push"
        ;;
      gmerge)
        module="git"
        usage="gmerge [args ...]"
        description="git merge"
        ;;
      gclean)
        module="git"
        usage="gclean --confirm"
        description="git reset --hard HEAD && git clean -fd"
        ;;
      gx)
        module="git"
        usage="gx <path_or_file> [path_or_file2 ...]"
        description="git update-index --chmod=+x"
        ;;
      de)
        module="docker"
        usage="de <image_name> <tag>"
        description="verifie si l'image existe dans le votre registry perso"
        ;;
      dt)
        module="docker"
        usage="dt <image_name> <tag>"
        description="docker tag (avec verification si le tag existe deja)"
        ;;
      dtl)
        module="docker"
        usage="dtl <image_name> <tag>"
        description="tag l'image avec le tag donne puis avec latest"
        ;;
      dp)
        module="docker"
        usage="dp <image_name> <tag>"
        description="docker push (avec verification si le tag existe deja dans le registry)"
        ;;
      dpl)
        module="docker"
        usage="dpl <image_name> <tag>"
        description="push le tag donne puis latest"
        ;;
      dpush)
        module="docker"
        usage="dpush <image_name> <tag>"
        description="alias de dp"
        ;;
      dpull)
        module="docker"
        usage="dpull <image_name> [tag]"
        description="docker pull (tag par defaut: latest)"
        ;;
      dl)
        module="docker"
        usage="dl [image_name]"
        description="liste les images du votre registry perso ou les tags d'une image"
        ;;
      dcb)
        module="docker"
        usage="dcb <service_name> [service_name2 ...]"
        description="docker compose build"
        ;;
      dcbnc)
        module="docker"
        usage="dcbnc <service_name> [service_name2 ...]"
        description="docker compose build avec --no-cache"
        ;;
      dcu)
        module="docker"
        usage="dcu <service_name> [service_name2 ...]"
        description="docker compose up -d"
        ;;
      dcund)
        module="docker"
        usage="dcund <service_name> [service_name2 ...]"
        description="docker compose up -d --no-deps"
        ;;
      dstop)
        module="docker"
        usage="dstop <service_name> [service_name2 ...]"
        description="docker compose stop (docker stop si en dehors d'un projet avec compose)"
        ;;
      ddown)
        module="docker"
        usage="ddown <service_name> [service_name2 ...]"
        description="docker compose down"
        ;;
      dkill)
        module="docker"
        usage="dkill <service_name> [service_name2 ...]"
        description="docker compose kill (docker kill si en dehors d'un projet avec compose)"
        ;;
      dps)
        module="docker"
        usage="dps [args ...]"
        description="docker compose ps (docker ps si en dehors d'un projet avec compose)"
        ;;
      dlogs)
        module="docker"
        usage="dlogs <container_name_or_id>"
        description="docker logs --follow"
        ;;
      dexec)
        module="docker"
        usage="dexec <container_name_or_id> [args ...]"
        description="docker exec"
        ;;
      dx)
        module="docker"
        usage="dx <container_name_or_id> [args ...]"
        description="alias de dexec"
        ;;
*)
        echo "Unknown command: $command"
        echo "Try: gabash --help"
        return 1
        ;;
    esac

    if [[ "$module" != "internal" ]] && ! __gabash_has_module "$module"; then
      echo "Command '$command' is not available because module '$module' is not loaded."
      echo "Load the module, then retry."
      return 1
    fi

    echo "Command: $command"
    echo "Module: $module"
    echo "Usage: $usage"
    echo "Description: $description"
    return 0
  }

  __gabash_print_help() {
    echo "gabash: fonctions pratiques pour bash et powershell."
    echo ""
    echo "Usage: gabash --help [command] | gabash --version"
    echo ""

    if [[ ${#__GABASH_ENABLED_MODULES[@]} -eq 0 ]]; then
      echo "No module loaded yet. Source a gabash module (git, docker, nginx, all)."
      return 0
    fi

    echo "Loaded modules: ${__GABASH_ENABLED_MODULES[*]}"
    echo ""

    local module
    local ordered_modules=(nginx git docker)
    for module in "${ordered_modules[@]}"; do
      if __gabash_has_module "$module"; then
        __gabash_print_module_commands "$module"
        echo ""
      fi
    done

    return 0
  }

  __gabash_print_version() {
    echo "gabash version ${GABASH_VERSION:-${__GABASH_VERSION}}"
    return 0
  }

  __gabash_complete() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ $COMP_CWORD -eq 1 ]]; then
      COMPREPLY=($(compgen -W "--help -h help --version -v version" -- "$cur"))
      return 0
    fi

    if [[ $COMP_CWORD -eq 2 ]] && [[ "$prev" == "--help" || "$prev" == "-h" || "$prev" == "help" ]]; then
      COMPREPLY=($(compgen -W "$(__gabash_list_loaded_command_names)" -- "$cur"))
      return 0
    fi

    COMPREPLY=()
    return 0
  }

  gabash() {
    local action="${1:---help}"
    local subject="${2:-}"

    case "$action" in
      --help|-h|help)
        if [[ -n "$subject" ]]; then
          __gabash_print_command_help "$subject"
        else
          __gabash_print_help
        fi
        ;;
      --version|-v|version)
        __gabash_print_version
        ;;
      *)
        echo "Unknown argument: $action"
        echo "Try: gabash --help"
        return 1
        ;;
    esac
  }

  if type complete >/dev/null 2>&1; then
    complete -F __gabash_complete gabash
  fi
fi
