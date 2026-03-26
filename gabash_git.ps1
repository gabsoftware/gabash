$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Get-Command Register-GabashModule -ErrorAction SilentlyContinue)) {
    . (Join-Path $ScriptDir "gabash_internernal.ps1")
}
Register-GabashModule "git"

#### raccourcis pour travailler avec Git

function cb {
    Write-Host "Nettoyage des branches locales supprimées du serveur..."
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

    Write-Host "Nettoyage terminé !"
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

function gc {
    if ($args.Count -eq 0) {
        Write-Host "Paramètre manquant : répertoire(s), fichier(s) ou nom de branche"
    } else {
        $hasExplicitSeparator = $args -contains "--"
        $hasPathArg = $false
        foreach ($arg in $args) {
            if (Test-Path -LiteralPath $arg) {
                $hasPathArg = $true
                break
            }
        }

        if ($hasExplicitSeparator -or $hasPathArg) {
            git restore @args
        } else {
            git switch @args
        }
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
        Write-Host "Paramètre manquant : répertoire(s) ou fichier(s)"
    } else {
        git add @args
    }
}

function gcom {
    if ($args.Count -eq 0) {
        Write-Host "Paramètre manquant : message"
    } else {
        git commit -m ($args -join " ")
    }
}

function gr {
    if ($args.Count -eq 0) {
        Write-Host "Paramètre manquant : répertoire(s) ou fichier(s)"
    } else {
        git reset @args
    }
}

function gclean {
    param(
        [string]$Confirm
    )

    if ($Confirm -ne "--confirm") {
        Write-Host "Refus: gclean requires --confirm"
        return
    }

    git reset --hard HEAD
    git clean -fd
}

function gx {
    if ($args.Count -eq 0) {
        Write-Host "Paramètre manquant : répertoire(s) ou fichier(s)"
    } else {
        git update-index --chmod=+x @args
    }
}
