if (-not $script:GabashEnabledModules) {
    $script:GabashEnabledModules = New-Object System.Collections.Generic.HashSet[string] ([System.StringComparer]::OrdinalIgnoreCase)
}
if (-not $script:GabashVersion) {
    $script:GabashVersion = if ($env:GABASH_VERSION) { $env:GABASH_VERSION } else { "dev" }
}

function Register-GabashModule {
    param([string]$ModuleName)

    if ([string]::IsNullOrWhiteSpace($ModuleName)) {
        return
    }

    [void]$script:GabashEnabledModules.Add($ModuleName)
}

function Test-GabashModuleEnabled {
    param([string]$ModuleName)

    if ([string]::IsNullOrWhiteSpace($ModuleName)) {
        return $false
    }

    return $script:GabashEnabledModules.Contains($ModuleName)
}

function Get-GabashModuleCommands {
    param([string]$ModuleName)

    switch ($ModuleName.ToLowerInvariant()) {
        "nginx" {
            return @(
                [pscustomobject]@{ Command = "ngr"; Description = "Redemarre le service nginx" },
                [pscustomobject]@{ Command = "ngt"; Description = "Verifie la configuration du service nginx (nginx -t)" }
            )
        }
        "git" {
            return @(
                [pscustomobject]@{ Command = "cb"; Description = "Nettoyage des branches locales supprimees du serveur" },
                [pscustomobject]@{ Command = "ga"; Description = "git add" },
                [pscustomobject]@{ Command = "gb"; Description = "git branch" },
                [pscustomobject]@{ Command = "gc"; Description = "git switch (branches) ou git restore (fichiers/chemins)" },
                [pscustomobject]@{ Command = "gd"; Description = "git diff" },
                [pscustomobject]@{ Command = "gf"; Description = "git fetch --all" },
                [pscustomobject]@{ Command = "gr"; Description = "git reset" },
                [pscustomobject]@{ Command = "gs"; Description = "git status" },
                [pscustomobject]@{ Command = "gcom"; Description = "git commit" },
                [pscustomobject]@{ Command = "glog [number]"; Description = "git log -n [number] (optionnel ; par defaut 1)" },
                [pscustomobject]@{ Command = "gpull"; Description = "git pull" },
                [pscustomobject]@{ Command = "gpush"; Description = "git push" },
                [pscustomobject]@{ Command = "gmerge"; Description = "git merge" },
                [pscustomobject]@{ Command = "gclean --confirm"; Description = "git reset --hard HEAD && git clean -fd" },
                [pscustomobject]@{ Command = "gx"; Description = "git update-index --chmod=+x" }
            )
        }
        "docker" {
            return @(
                [pscustomobject]@{ Command = "de <image_name> <tag>"; Description = "verifie si l'image existe dans le votre registry perso" },
                [pscustomobject]@{ Command = "dt <image_name> <tag>"; Description = "docker tag (avec verification si le tag existe deja)" },
                [pscustomobject]@{ Command = "dtl <image_name> <tag>"; Description = "tag l'image avec le tag donne puis avec latest" },
                [pscustomobject]@{ Command = "dp <image_name> <tag>"; Description = "docker push (avec verification si le tag existe deja dans le registry)" },
                [pscustomobject]@{ Command = "dpl <image_name> <tag>"; Description = "push le tag donne puis latest" },
                [pscustomobject]@{ Command = "dpush <image_name> <tag>"; Description = "alias de dp" },
                [pscustomobject]@{ Command = "dpull <image_name> [tag]"; Description = "docker pull (tag par defaut: latest)" },
                [pscustomobject]@{ Command = "dl"; Description = "liste les images du votre registry perso" },
                [pscustomobject]@{ Command = "dl <image_name>"; Description = "liste les tags de l'image" },
                [pscustomobject]@{ Command = "dcb <service_name> [service_name2 ...]"; Description = "docker compose build" },
                [pscustomobject]@{ Command = "dcbnc <service_name> [service_name2 ...]"; Description = "docker compose build avec --no-cache" },
                [pscustomobject]@{ Command = "dcu <service_name> [service_name2 ...]"; Description = "docker compose up -d" },
                [pscustomobject]@{ Command = "dcund <service_name> [service_name2 ...]"; Description = "docker compose up -d --no-deps" },
                [pscustomobject]@{ Command = "dstop <service_name> [service_name2 ...]"; Description = "docker compose stop (docker stop si en dehors d'un projet avec compose)" },
                [pscustomobject]@{ Command = "ddown <service_name> [service_name2 ...]"; Description = "docker compose down" },
                [pscustomobject]@{ Command = "dkill <service_name> [service_name2 ...]"; Description = "docker compose kill (docker kill si en dehors d'un projet avec compose)" },
                [pscustomobject]@{ Command = "dps [args ...]"; Description = "docker compose ps (docker ps si en dehors d'un projet avec compose)" },
                [pscustomobject]@{ Command = "dlogs <container_name_or_id>"; Description = "docker logs --follow" },
                [pscustomobject]@{ Command = "dexec <container_name_or_id> [args ...]"; Description = "docker exec" },
                [pscustomobject]@{ Command = "dx <container_name_or_id> [args ...]"; Description = "alias de dexec" }
            )
        }
        "unx" {
            return @(
                [pscustomobject]@{ Command = "which [-as] <command> [command ...]"; Description = "affiche le chemin d'une commande comme l'equivalent unix" },
                [pscustomobject]@{ Command = "grep [-ivnrlcwxFEs] <pattern> [file ...]"; Description = "recherche un motif avec des options grep courantes" },
                [pscustomobject]@{ Command = "head [-n N] [file ...]"; Description = "affiche les premieres lignes (10 par defaut)" },
                [pscustomobject]@{ Command = "tail [-n N] [-f] [file ...]"; Description = "affiche les dernieres lignes et peut suivre avec -f" }
            )
        }
        default {
            return @()
        }
    }
}

function Show-GabashHelp {
    Write-Output "gabash: fonctions pratiques pour bash et powershell."
    Write-Output ""
    Write-Output "Usage: gabash --help [command] | gabash --version"
    Write-Output ""

    if ($script:GabashEnabledModules.Count -eq 0) {
        Write-Output "No module loaded yet. Source a gabash module (git, docker, unx, all)."
        return
    }

    $loaded = @("nginx", "git", "docker", "unx") | Where-Object { Test-GabashModuleEnabled $_ }
    Write-Output ("Loaded modules: " + ($loaded -join " "))
    Write-Output ""

    foreach ($module in $loaded) {
        Write-Output (("### " + (Get-Culture).TextInfo.ToTitleCase($module)))
        foreach ($item in Get-GabashModuleCommands $module) {
            Write-Output ("- " + $item.Command + " : " + $item.Description)
        }
        Write-Output ""
    }
}

function Show-GabashVersion {
    $version = if ($env:GABASH_VERSION) { $env:GABASH_VERSION } else { $script:GabashVersion }
    Write-Output ("gabash version " + $version)
}

function Show-GabashCommandHelp {
    param([string]$CommandName)

    if ([string]::IsNullOrWhiteSpace($CommandName)) {
        Show-GabashHelp
        return
    }

    $normalized = $CommandName.ToLowerInvariant()
    if ($normalized -eq "gabash") {
        Write-Output "Command: gabash"
        Write-Output "Module: internal"
        Write-Output "Usage: gabash --help [command] | gabash --version"
        Write-Output "Description: commande interne gabash"
        return
    }

    $allModules = @("nginx", "git", "docker", "unx")
    foreach ($module in $allModules) {
        foreach ($item in (Get-GabashModuleCommands $module)) {
            $token = ($item.Command -split '\s+')[0]
            if ($token -ieq $CommandName) {
                if (-not (Test-GabashModuleEnabled $module)) {
                    Write-Output "Command '$CommandName' is not available because module '$module' is not loaded."
                    Write-Output "Load the module, then retry."
                    return
                }

                Write-Output ("Command: " + $token)
                Write-Output ("Module: " + $module)
                Write-Output ("Usage: " + $item.Command)
                Write-Output ("Description: " + $item.Description)
                return
            }
        }
    }

    Write-Host "Unknown command: $CommandName"
    Write-Host "Try: gabash --help"
}

function Get-GabashLoadedCommandNames {
    $loaded = @("nginx", "git", "docker", "unx") | Where-Object { Test-GabashModuleEnabled $_ }
    foreach ($module in $loaded) {
        foreach ($item in (Get-GabashModuleCommands $module)) {
            ($item.Command -split '\s+')[0]
        }
    }
}

function gabash {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)

    $action = if ($Arguments.Count -eq 0) { "--help" } else { $Arguments[0] }

    switch ($action) {
        "--help" {
            if ($Arguments.Count -ge 2) { Show-GabashCommandHelp $Arguments[1] } else { Show-GabashHelp }
        }
        "-h" {
            if ($Arguments.Count -ge 2) { Show-GabashCommandHelp $Arguments[1] } else { Show-GabashHelp }
        }
        "help" {
            if ($Arguments.Count -ge 2) { Show-GabashCommandHelp $Arguments[1] } else { Show-GabashHelp }
        }
        "--version" { Show-GabashVersion }
        "-v" { Show-GabashVersion }
        "version" { Show-GabashVersion }
        default {
            Write-Host "Unknown argument: $action"
            Write-Host "Try: gabash --help"
        }
    }
}

if (-not $script:GabashCompleterRegistered) {
    $gabashCompleter = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

        $elements = @($commandAst.CommandElements | ForEach-Object { $_.Extent.Text })
        $lineText = $commandAst.Extent.Text
        $endsWithSpace = $lineText -match '\s$'
        $helpTokens = @("--help", "-h", "help")

        $topLevel = @("--help", "-h", "help", "--version", "-v", "version")
        $targetCommands = @()

        if ($elements.Count -le 1) {
            $targetCommands = $topLevel
        } elseif ($elements.Count -eq 2) {
            $firstArg = $elements[1]
            if (($firstArg -in $helpTokens) -and $endsWithSpace) {
                # `gabash --help <TAB>`: complete command names
                $targetCommands = @(Get-GabashLoadedCommandNames)
            } else {
                # `gabash --<TAB>` or `gabash h<TAB>`: complete top-level options
                $targetCommands = $topLevel
            }
        } elseif ($elements.Count -ge 3) {
            $firstArg = $elements[1]
            if ($firstArg -in $helpTokens) {
                $targetCommands = @(Get-GabashLoadedCommandNames)
            }
        }

        foreach ($candidate in $targetCommands) {
            if ($candidate -like "$wordToComplete*") {
                [System.Management.Automation.CompletionResult]::new($candidate, $candidate, 'ParameterValue', $candidate)
            }
        }
    }

    Register-ArgumentCompleter -CommandName gabash -ScriptBlock $gabashCompleter
    Register-ArgumentCompleter -CommandName gabash -ParameterName Arguments -ScriptBlock $gabashCompleter
    $script:GabashCompleterRegistered = $true
}
