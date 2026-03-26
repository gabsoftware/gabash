$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Get-Command Register-GabashModule -ErrorAction SilentlyContinue)) {
    . (Join-Path $ScriptDir "gabash_internernal.ps1")
}
Register-GabashModule "docker"

#### functions for working with your personal Docker registry

$YOUR_DOCKER_REGISTRY = "your.docker.registry:5000"

function Get-NaturalSortKey {
    param([string]$Value)

    [regex]::Replace($Value, '\d+', { param($m) $m.Value.PadLeft(20, '0') })
}

function Get-YourRegistryJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$Registry = $YOUR_DOCKER_REGISTRY
    )

    $url = "https://$Registry/$Path"
    $response = curl.exe -s -k -H "Accept: */*" $url

    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($response)) {
        return $null
    }

    try {
        return $response | ConvertFrom-Json
    } catch {
        return $null
    }
}

function check_tag_exists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LOCAL_YOUR_DOCKER_REGISTRY,
        [Parameter(Mandatory = $true)]
        [string]$IMAGE_NAME,
        [Parameter(Mandatory = $true)]
        [string]$TAG,
        [string]$SILENT
    )

    $data = Get-YourRegistryJson -Path "v2/$IMAGE_NAME/tags/list" -Registry $LOCAL_YOUR_DOCKER_REGISTRY
    if ($null -eq $data) {
        Write-Host "Error: empty or failed response from registry $LOCAL_YOUR_DOCKER_REGISTRY."
        return $false
    }

    $tagList = @($data.tags)
    $tagExists = $tagList -contains $TAG

    if ($tagExists) {
        if ($SILENT -ne "silent") {
            Write-Host "Warning: Tag '$TAG' already exists for image '$IMAGE_NAME' in registry '$LOCAL_YOUR_DOCKER_REGISTRY'."
        }
        return $true
    }

    return $false
}

function de {
    if ($args.Count -ne 2) {
        Write-Host "Usage: de <image_name> <tag>"
        return
    }

    $IMAGE_NAME = $args[0]
    $TAG = $args[1]

    if (check_tag_exists $YOUR_DOCKER_REGISTRY $IMAGE_NAME $TAG "silent") {
        Write-Host "Tag '$TAG' exists for image '$IMAGE_NAME' in registry '$YOUR_DOCKER_REGISTRY'."
    } else {
        Write-Host "Tag '$TAG' does NOT exist for image '$IMAGE_NAME' in registry '$YOUR_DOCKER_REGISTRY'."
    }
}

function dt {
    if ($args.Count -ne 2) {
        Write-Host "Usage: dt <image_name> <tag>"
        return
    }

    $IMAGE_NAME = $args[0]
    $TAG = $args[1]

    if (check_tag_exists $YOUR_DOCKER_REGISTRY $IMAGE_NAME $TAG) {
        $user_input = Read-Host "Do you want to replace the existing tag? (y/n)"
        if ($user_input -notmatch '^[Yy]$') {
            Write-Host "Aborting operation. Tag '$TAG' not replaced."
            return
        }
    }

    docker tag "$IMAGE_NAME" "$YOUR_DOCKER_REGISTRY/$IMAGE_NAME`:$TAG"
    Write-Host "Image $IMAGE_NAME`:$TAG tagged with $YOUR_DOCKER_REGISTRY/$IMAGE_NAME`:$TAG"
}

function dtl {
    if ($args.Count -ne 2) {
        Write-Host "Usage: dtl <image_name> <tag>"
        return
    }

    $IMAGE_NAME = $args[0]
    $TAG = $args[1]

    dt $IMAGE_NAME $TAG
    dt $IMAGE_NAME "latest"
}

function dp {
    if ($args.Count -ne 2) {
        Write-Host "Usage: dp <image_name> <tag>"
        return
    }

    $IMAGE_NAME = $args[0]
    $TAG = $args[1]

    $tagExistsLocally = docker images -q "$YOUR_DOCKER_REGISTRY/$IMAGE_NAME`:$TAG"
    if ([string]::IsNullOrWhiteSpace(($tagExistsLocally | Out-String))) {
        Write-Host "Error: Tag '$YOUR_DOCKER_REGISTRY/$IMAGE_NAME`:$TAG' does not exist locally."
        return
    }

    if (check_tag_exists $YOUR_DOCKER_REGISTRY $IMAGE_NAME $TAG) {
        $user_input = Read-Host "Do you want to replace the existing tag? (y/n)"
        if ($user_input -notmatch '^[Yy]$') {
            Write-Host "Aborting operation. Tag '$TAG' not pushed."
            return
        }
    }

    docker push "$YOUR_DOCKER_REGISTRY/$IMAGE_NAME`:$TAG"
    Write-Host "Image $IMAGE_NAME`:$TAG pushed to $YOUR_DOCKER_REGISTRY"
}

function dpl {
    if ($args.Count -ne 2) {
        Write-Host "Usage: dpl <image_name> <tag>"
        return
    }

    $IMAGE_NAME = $args[0]
    $TAG = $args[1]

    dp $IMAGE_NAME $TAG
    dp $IMAGE_NAME "latest"
}

function dpush {
    if ($args.Count -eq 0) {
        Write-Host "Usage: dpush <image_name> <tag>"
        return
    }

    dp @args
}

function dpull {
    if ($args.Count -lt 1 -or $args.Count -gt 2) {
        Write-Host "Usage: dpull <image_name> [tag]"
        return
    }

    $IMAGE_NAME = $args[0]
    $TAG = if ($args.Count -eq 2) { $args[1] } else { "latest" }

    docker pull "$YOUR_DOCKER_REGISTRY/$IMAGE_NAME`:$TAG"
}

function dlogs {
    if ($args.Count -ne 1) {
        Write-Host "Usage: dlogs <container_name_or_id>"
        return
    }

    $CONTAINER = $args[0]
    docker logs --follow $CONTAINER
}

function dl {
    if ($args.Count -eq 0) {
        $data = Get-YourRegistryJson -Path "v2/_catalog"
        if ($null -eq $data) {
            Write-Host "Error: empty response from registry $YOUR_DOCKER_REGISTRY"
            return
        }

        @($data.repositories) |
            Sort-Object { Get-NaturalSortKey $_ } |
            ForEach-Object { Write-Output $_ }
        return
    }

    if ($args.Count -eq 1) {
        $IMAGE_NAME = $args[0]
        $data = Get-YourRegistryJson -Path "v2/$IMAGE_NAME/tags/list"
        if ($null -eq $data) {
            Write-Host "Error: empty response from registry $YOUR_DOCKER_REGISTRY"
            return
        }

        if ($null -ne $data.errors) {
            $message = @($data.errors | ForEach-Object { $_.message }) -join "; "
            Write-Output "Registry error: $message"
            return
        }

        $tags = @($data.tags)
        if ($tags.Count -eq 0) {
            Write-Output "No tags found for '$IMAGE_NAME'"
            return
        }

        $tags |
            Sort-Object { Get-NaturalSortKey $_ } |
            ForEach-Object { Write-Output $_ }
        return
    }

    Write-Host "Usage: dl [image_name]"
}

function dcb {
    if ($args.Count -eq 0) {
        Write-Host "Usage: dcb <service_name> [service_name2 ...]"
        return
    }

    docker compose --progress=plain build @args
}

function dcbnc {
    if ($args.Count -eq 0) {
        Write-Host "Usage: dcbnc <service_name> [service_name2 ...]"
        return
    }

    docker compose --progress=plain build --no-cache @args
}

function dcu {
    if ($args.Count -eq 0) {
        Write-Host "Usage: dcu <service_name> [service_name2 ...]"
        return
    }

    docker compose up -d @args
}

function dcund {
    if ($args.Count -eq 0) {
        Write-Host "Usage: dcund <service_name> [service_name2 ...]"
        return
    }

    docker compose up -d --no-deps @args
}

function dstop {
    if ($args.Count -eq 0) {
        Write-Host "Usage: dstop <service_name> [service_name2 ...]"
        return
    }

    docker compose stop @args
    if ($LASTEXITCODE -ne 0) {
        docker stop @args
    }
}

function ddown {
    if ($args.Count -eq 0) {
        Write-Host "Usage: ddown <service_name> [service_name2 ...]"
        return
    }

    docker compose down @args
}

function dkill {
    if ($args.Count -eq 0) {
        Write-Host "Usage: dkill <service_name> [service_name2 ...]"
        return
    }

    docker compose kill @args
    if ($LASTEXITCODE -ne 0) {
        docker kill @args
    }
}

function dps {
    docker compose ps @args
    if ($LASTEXITCODE -ne 0) {
        docker ps @args
    }
}

function dexec {
    if ($args.Count -eq 0) {
        Write-Host "Usage: dexec <container_name_or_id> [args ...]"
        Write-Host "   or: dx <container_name_or_id> [args ...]"
        return
    }

    $container = $args[0]
    $remaining = @()
    if ($args.Count -gt 1) {
        $remaining = $args[1..($args.Count - 1)]
    }

    if ($remaining.Count -eq 0) {
        docker exec -e TERM=xterm-256color -it $container bash
    } else {
        docker exec -e TERM=xterm-256color -it $container @remaining
    }
}
Set-Alias -Name dx -Value dexec
