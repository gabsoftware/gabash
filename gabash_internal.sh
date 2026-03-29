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
        echo "ngs"
        echo "ngv"
        ;;
      git)
        echo "cb"
        echo "ga"
        echo "gb"
        echo "gsb"
        echo "gd"
        echo "gf"
        echo "gr"
        echo "grs"
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
- ngr : Restarts the nginx service
- ngt : Checks the nginx configuration (nginx -t)
- ngs : Shows the nginx service status
- ngv : Shows the nginx version
EONGINX
        ;;
      git)
        cat <<'EOGIT'
### Git
- cb : Cleans up local branches deleted from the server
- ga : git add
- gb : git branch
- gsb : git switch (branches)
- gd : git diff
- gf : git fetch --all
- gr : git restore (files/paths)
- grs : git reset
- gs : git status
- gcom : git commit
- glog [number] : git log -n [number] (optional; default 1)
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
- de <image_name> <tag> : checks if the image exists in your personal registry
- dt <image_name> <tag> : docker tag (checks if tag already exists)
- dtl <image_name> <tag> : tags the image with the given tag then with latest
- dp <image_name> <tag> : docker push (checks if tag already exists in registry)
- dpl <image_name> <tag> : pushes the given tag then latest
- dpush <image_name> <tag> : alias for dp
- dpull <image_name> [tag] : docker pull (default tag: latest)
- dl : lists images in your personal registry
- dl <image_name> : lists tags for the image
- dcb <service_name> [service_name2 ...] : docker compose build
- dcbnc <service_name> [service_name2 ...] : docker compose build with --no-cache
- dcu <service_name> [service_name2 ...] : docker compose up -d
- dcund <service_name> [service_name2 ...] : docker compose up -d --no-deps
- dstop <service_name> [service_name2 ...] : docker compose stop (docker stop if outside a compose project)
- ddown <service_name> [service_name2 ...] : docker compose down
- dkill <service_name> [service_name2 ...] : docker compose kill (docker kill if outside a compose project)
- dps [args ...] : docker compose ps (docker ps if outside a compose project)
- dlogs <container_name_or_id> : docker logs --follow
- dexec <container_name_or_id> [args ...] : docker exec
- dx <container_name_or_id> [args ...] : alias for dexec
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
        description="gabash internal command"
        ;;
      ngr)
        module="nginx"
        usage="ngr"
        description="Restarts the nginx service"
        ;;
      ngt)
        module="nginx"
        usage="ngt"
        description="Checks the nginx configuration (nginx -t)"
        ;;
      ngs)
        module="nginx"
        usage="ngs"
        description="Shows the nginx service status"
        ;;
      ngv)
        module="nginx"
        usage="ngv"
        description="Shows the nginx version"
        ;;
      cb)
        module="git"
        usage="cb"
        description="Cleans up local branches deleted from the server"
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
      gsb)
        module="git"
        usage="gsb <branch> [args ...]"
        description="git switch (branches)"
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
        usage="gr <path_or_file> [path_or_file2 ...]"
        description="git restore (files/paths)"
        ;;
      grs)
        module="git"
        usage="grs <args ...>"
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
        description="git log -n [number] (optional; default 1)"
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
        description="checks if the image exists in your personal registry"
        ;;
      dt)
        module="docker"
        usage="dt <image_name> <tag>"
        description="docker tag (checks if tag already exists)"
        ;;
      dtl)
        module="docker"
        usage="dtl <image_name> <tag>"
        description="tags the image with the given tag then with latest"
        ;;
      dp)
        module="docker"
        usage="dp <image_name> <tag>"
        description="docker push (checks if tag already exists in registry)"
        ;;
      dpl)
        module="docker"
        usage="dpl <image_name> <tag>"
        description="pushes the given tag then latest"
        ;;
      dpush)
        module="docker"
        usage="dpush <image_name> <tag>"
        description="alias for dp"
        ;;
      dpull)
        module="docker"
        usage="dpull <image_name> [tag]"
        description="docker pull (default tag: latest)"
        ;;
      dl)
        module="docker"
        usage="dl [image_name]"
        description="lists images in your personal registry or tags for an image"
        ;;
      dcb)
        module="docker"
        usage="dcb <service_name> [service_name2 ...]"
        description="docker compose build"
        ;;
      dcbnc)
        module="docker"
        usage="dcbnc <service_name> [service_name2 ...]"
        description="docker compose build with --no-cache"
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
        description="docker compose stop (docker stop if outside a compose project)"
        ;;
      ddown)
        module="docker"
        usage="ddown <service_name> [service_name2 ...]"
        description="docker compose down"
        ;;
      dkill)
        module="docker"
        usage="dkill <service_name> [service_name2 ...]"
        description="docker compose kill (docker kill if outside a compose project)"
        ;;
      dps)
        module="docker"
        usage="dps [args ...]"
        description="docker compose ps (docker ps if outside a compose project)"
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
        description="alias for dexec"
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
    echo "gabash: handy functions for bash and powershell."
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
