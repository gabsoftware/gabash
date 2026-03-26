__GABASH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! declare -F __gabash_register_module >/dev/null 2>&1; then
  source "$__GABASH_SCRIPT_DIR/gabash_internal.sh"
fi
__gabash_register_module "docker"
unset __GABASH_SCRIPT_DIR

#### fonctions pour travailler sur votre registry Docker perso

YOUR_DOCKER_REGISTRY="your.docker.registry:5000"

# Function to check if the tag exists
check_tag_exists() {
  local LOCAL_YOUR_DOCKER_REGISTRY=$1
  local IMAGE_NAME=$2
  local TAG=$3
  local SILENT=${4:-}   # optional: pass "silent" to suppress warning output

  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required to check tags." >&2
    return 1
  fi

  # Check if the tag already exists in the registry
  local RESP
  RESP=$(curl -s -k -H "Accept: */*" "https://${LOCAL_YOUR_DOCKER_REGISTRY}/v2/${IMAGE_NAME}/tags/list")
  if [ $? -ne 0 ] || [ -z "$RESP" ]; then
    echo "Error: empty or failed response from registry ${LOCAL_YOUR_DOCKER_REGISTRY}." >&2
    return 1
  fi

  local TAG_EXISTS
  TAG_EXISTS=$(printf '%s' "$RESP" | jq -r --arg tag "$TAG" '.tags | index($tag)' 2>/dev/null)
  if [ $? -ne 0 ] || [ -z "$TAG_EXISTS" ]; then
    echo "Error: invalid response while checking tags for ${IMAGE_NAME}." >&2
    return 1
  fi

  if [ "$TAG_EXISTS" != "null" ]; then
    if [ "$SILENT" != "silent" ]; then
      echo "Warning: Tag '${TAG}' already exists for image '${IMAGE_NAME}' in registry '${LOCAL_YOUR_DOCKER_REGISTRY}'."
    fi
    return 0  # Tag exists
  fi

  return 1  # Tag does not exist
}

# Check if a tag exists for a given image in the registry
de() {
  if [ $# -ne 2 ]; then
    echo "Usage: de <image_name> <tag>"
    return 2
  fi

  local IMAGE_NAME=$1
  local TAG=$2

  if check_tag_exists "$YOUR_DOCKER_REGISTRY" "$IMAGE_NAME" "$TAG" "silent"; then
    echo "Tag '${TAG}' exists for image '${IMAGE_NAME}' in registry '${YOUR_DOCKER_REGISTRY}'."
    return 0
  else
    echo "Tag '${TAG}' does NOT exist for image '${IMAGE_NAME}' in registry '${YOUR_DOCKER_REGISTRY}'."
    return 1
  fi
}

# docker tag
dt() {
  # Check if the required parameters are provided
  if [ $# -ne 2 ]; then
    echo "Usage: dt <image_name> <tag>"
    return 1
  fi

  # Get the image name and tag from arguments
  local IMAGE_NAME=$1
  local TAG=$2

  # Check if the tag already exists
  if check_tag_exists "$YOUR_DOCKER_REGISTRY" "$IMAGE_NAME" "$TAG"; then
    read -p "Do you want to replace the existing tag? (y/n): " user_input
    if [[ ! "$user_input" =~ ^[Yy]$ ]]; then
      echo "Aborting operation. Tag '${TAG}' not replaced."
      return 1
    fi
  fi

  # Tag the image
  docker tag "${IMAGE_NAME}" "${YOUR_DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG}"

  echo "Image ${IMAGE_NAME}:${TAG} tagged with ${YOUR_DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG}"
}

# docker tag <tag> + latest
dtl() {
  if [ $# -ne 2 ]; then
    echo "Usage: dtl <image_name> <tag>"
    return 1
  fi

  local IMAGE_NAME=$1
  local TAG=$2

  dt "$IMAGE_NAME" "$TAG" || return $?
  dt "$IMAGE_NAME" "latest"
}

# docker push
dp() {
  # Check if the required parameters are provided
  if [ $# -ne 2 ]; then
    echo "Usage: dp <image_name> <tag>"
    return 1
  fi

  # Get the image name and tag from arguments
  local IMAGE_NAME=$1
  local TAG=$2

  # Check if the tag exists locally
  local TAG_EXISTS_LOCALLY=$(docker images -q "${YOUR_DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG}")

  if [ -z "$TAG_EXISTS_LOCALLY" ]; then
    echo "Error: Tag '${YOUR_DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG}' does not exist locally."
    return 1
  fi

  # Check if the tag already exists
  if check_tag_exists "$YOUR_DOCKER_REGISTRY" "$IMAGE_NAME" "$TAG"; then
    read -p "Do you want to replace the existing tag? (y/n): " user_input
    if [[ ! "$user_input" =~ ^[Yy]$ ]]; then
      echo "Aborting operation. Tag '${TAG}' not pushed."
      return 1
    fi
  fi

  # Push the image
  docker push "${YOUR_DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG}"

  echo "Image ${IMAGE_NAME}:${TAG} pushed to ${YOUR_DOCKER_REGISTRY}"
}

# docker push <tag> + latest
dpl() {
  if [ $# -ne 2 ]; then
    echo "Usage: dpl <image_name> <tag>"
    return 1
  fi

  local IMAGE_NAME=$1
  local TAG=$2

  dp "$IMAGE_NAME" "$TAG" || return $?
  dp "$IMAGE_NAME" "latest"
}

# alias to dp
dpush() {
  dp "$@"
}

# docker pull
dpull() {
  # Check if the required parameters are provided
  if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: dpull <image_name> [tag]"
    return 1
  fi

  # Get the image name and tag from arguments
  local IMAGE_NAME=$1
  local TAG=${2:-latest}

  docker pull "${YOUR_DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG}"
}

# docker logs --follow
dlogs() {
  # Check if the required parameters are provided
  if [ $# -ne 1 ]; then
    echo "Usage: dlogs <container_name_or_id>"
    return 1
  fi

  # Get the image name and tag from arguments
  local CONTAINER=$1

  docker logs --follow "${CONTAINER}"
}

# List registry catalog or tags for a given image
dl() {
  # No args -> list all images in the registry catalog
  if [ $# -eq 0 ]; then
    local RESP
    RESP=$(curl -s -k -H "Accept: */*" "https://${YOUR_DOCKER_REGISTRY}/v2/_catalog")
    if [ -z "$RESP" ]; then
      echo "Error: empty response from registry ${YOUR_DOCKER_REGISTRY}"
      return 1
    fi

    if command -v jq >/dev/null 2>&1; then
      echo "$RESP" | jq -r '.repositories[]?' | sort -V
    else
      echo "$RESP"
    fi
    return 0
  fi

  # One arg -> list tags of a specific image
  if [ $# -eq 1 ]; then
    local IMAGE_NAME=$1
    local RESP
    RESP=$(curl -s -k -H "Accept: */*" "https://${YOUR_DOCKER_REGISTRY}/v2/${IMAGE_NAME}/tags/list")
    if [ -z "$RESP" ]; then
      echo "Error: empty response from registry ${YOUR_DOCKER_REGISTRY}"
      return 1
    fi

    if command -v jq >/dev/null 2>&1; then
      echo "$RESP" | jq -r '
        if (.errors) then
          "Registry error: " + (.errors | map(.message) | join("; "))
        elif (.tags == null) or (.tags | length == 0) then
          "No tags found for '"$IMAGE_NAME"'"
        else
          .tags[] | tostring
        end' | sort -V
    else
      echo "$RESP"
    fi
    return 0
  fi

  echo "Usage: dl [image_name]"
  return 1
}

# docker compose build
dcb() {
  if [ $# -eq 0 ]; then
    echo "Usage: dcb <service_name> [service_name2 ...]"
    return 1
  fi
  docker compose --progress=plain build "$@"
}

# docker compose build no cache
dcbnc() {
  if [ $# -eq 0 ]; then
    echo "Usage: dcbnc <service_name> [service_name2 ...]"
    return 1
  fi
  docker compose --progress=plain build --no-cache "$@"
}

# docker compose up -d
dcu() {
  if [ $# -eq 0 ]; then
    echo "Usage: dcu <service_name> [service_name2 ...]"
    return 1
  fi
  docker compose up -d "$@"
}

# docker compose up -d IMAGE --no-deps
dcund() {
  if [ $# -eq 0 ]; then
    echo "Usage: dcund <service_name> [service_name2 ...]"
    return 1
  fi
  docker compose up -d --no-deps "$@"
}

# docker compose stop
dstop() {
  if [ $# -eq 0 ]; then
    echo "Usage: dstop <service_name> [service_name2 ...]"
    return 1
  fi
  if ! docker compose stop "$@"; then
    docker stop "$@"
  fi
}

# docker compose down
ddown() {
  if [ $# -eq 0 ]; then
    echo "Usage: ddown <service_name> [service_name2 ...]"
    return 1
  fi
  docker compose down "$@"
}

# docker compose kill
dkill() {
  if [ $# -eq 0 ]; then
    echo "Usage: dkill <service_name> [service_name2 ...]"
    return 1
  fi
  if ! docker compose kill "$@"; then
    docker kill "$@"
  fi
}

# docker compose ps
dps() {
  if ! docker compose ps "$@"; then
    docker ps "$@"
  fi
}

# docker exec
dexec() {
  if [ $# -eq 0 ]; then
    echo "Usage: dexec <container_name_or_id> [args ...]"
    echo "   or: dx <container_name_or_id> [args ...]"
    return 1
  fi

  local container="$1"
  shift

  if [ $# -eq 0 ]; then
      docker exec -e TERM=xterm-256color -it "$container" bash
  else
      docker exec -e TERM=xterm-256color -it "$container" "$@"
  fi
}
alias dx='dexec'
