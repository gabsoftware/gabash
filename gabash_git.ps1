$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Get-Command Register-GabashModule -ErrorAction SilentlyContinue)) {
    . (Join-Path $ScriptDir "gabash_internernal.ps1")
}
Register-GabashModule "git"

#### shortcuts for working with Git

function cb {
    Write-Host "Cleaning up local branches deleted from the server..."
    git fetch --prune | Out-Null

    # List local branches where upstream is [gone]
    $branches = git for-each-ref --format '%(refname) %(upstream:track)' refs/heads `
        | Where-Object { $_ -match '\[gone\]' } `
        | ForEach-Object {
            ($_ -replace '^refs/heads/', '') -replace '\s*\[gone\].*',''
        }

    foreach ($b in $branches) {
        git branch -D $b
    }

    Write-Host "Cleanup done!"
}

function gb {
    if ($args.Count -eq 0) {
        git branch
    } else {
        git branch @args
    }
}

function gd {
    if ($args.Count -eq 0) {
        git diff .
    } else {
        git diff @args
    }
}

function gf {
    git fetch --all
}

function gpull {
    if ($args.Count -eq 0) {
        git pull
    } else {
        git pull @args
    }
}

function gpush {
    if ($args.Count -eq 0) {
        git push
    } else {
        git push @args
    }
}

function gmerge {
    if ($args.Count -eq 0) {
        git merge
    } else {
        git merge @args
    }
}

function gsb {
    if ($args.Count -eq 0) {
        Write-Host "Missing parameter: branch name"
    } else {
        git switch @args
    }
}

function gr() {
    if ($args.Count -eq 0) {
        Write-Host "Missing parameter: directory/directories or file(s)"
    } else {
        git restore @args
    }
}

function gs {
    git status
}

function glog {
    $count = 1
    if ($args.Count -ge 1) {
        $count = $args[0]
    }
    git log -n $count
}

function ga {
    if ($args.Count -eq 0) {
        Write-Host "Missing parameter: directory/directories or file(s)"
    } else {
        git add @args
    }
}

function gcom {
    if ($args.Count -eq 0) {
        Write-Host "Missing parameter: message"
    } else {
        git commit -m ($args -join " ")
    }
}

function grs {
    if ($args.Count -eq 0) {
        Write-Host "Missing parameter: directory/directories or file(s)"
    } else {
        git reset @args
    }
}

function gclean {
    param(
        [string]$Confirm
    )

    if ($Confirm -ne "--confirm") {
        Write-Host "Refused: gclean requires --confirm"
        return
    }

    git reset --hard HEAD
    git clean -fd
}

function gx {
    if ($args.Count -eq 0) {
        Write-Host "Missing parameter: directory/directories or file(s)"
    } else {
        git update-index --chmod=+x @args
    }
}
