$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Get-Command Register-GabashModule -ErrorAction SilentlyContinue)) {
    . (Join-Path $ScriptDir "gabash_internernal.ps1")
}
Register-GabashModule "unx"

$existingWhich = Get-Command -Name which -ErrorAction SilentlyContinue | Select-Object -First 1
if ($existingWhich) {
    Write-Warning ("gabash_unx: loading 'which' skipped because '" + $existingWhich.Name + "' already exists as " + $existingWhich.CommandType + ".")
} else {
function which {
    $Arguments = @($args)

    $showAll = $false
    $silent = $false
    $names = @()
    $parseOptions = $true

    foreach ($arg in $Arguments) {
        if ($parseOptions -and $arg -eq "--") {
            $parseOptions = $false
            continue
        }

        if ($parseOptions -and $arg -eq "--all") {
            $showAll = $true
            continue
        }

        if ($parseOptions -and $arg.StartsWith("--")) {
            if (-not $silent) {
                Write-Host ("which: invalid option -- " + $arg)
            }
            $global:LASTEXITCODE = 2
            return
        }

        if ($parseOptions -and $arg.StartsWith("-") -and $arg -ne "-") {
            $options = $arg.Substring(1).ToCharArray()
            foreach ($opt in $options) {
                switch ($opt) {
                    "a" { $showAll = $true }
                    "s" { $silent = $true }
                    default {
                        if (-not $silent) {
                            Write-Host ("which: invalid option -- " + $opt)
                        }
                        $global:LASTEXITCODE = 2
                        return
                    }
                }
            }
            continue
        }

        $names += $arg
    }

    if ($names.Count -eq 0) {
        if (-not $silent) {
            Write-Host "Usage: which [-as] filename ..."
        }
        $global:LASTEXITCODE = 1
        return
    }

    $exitCode = 0

    foreach ($name in $names) {
        $matches = Get-Command -Name $name -CommandType Application,ExternalScript -All -ErrorAction SilentlyContinue
        if (-not $matches) {
            $exitCode = 1
            continue
        }

        $paths = $matches | ForEach-Object { $_.Source } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
        if (-not $silent) {
            if ($showAll) {
                $paths
            } else {
                $paths | Select-Object -First 1
            }
        }
    }

    $global:LASTEXITCODE = $exitCode
}
}

$existingHead = Get-Command -Name head -ErrorAction SilentlyContinue | Select-Object -First 1
if ($existingHead) {
    Write-Warning ("gabash_unx: loading 'head' skipped because '" + $existingHead.Name + "' already exists as " + $existingHead.CommandType + ".")
} else {
function head {
    $Arguments = @($args)

    $lineCount = 10
    $paths = @()
    $parseOptions = $true
    $i = 0

    while ($i -lt $Arguments.Count) {
        $arg = $Arguments[$i]

        if ($parseOptions -and $arg -eq "--") {
            $parseOptions = $false
            $i++
            continue
        }

        if ($parseOptions -and $arg -eq "-n") {
            if (($i + 1) -ge $Arguments.Count) {
                Write-Host "head: option requires an argument -- n"
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            $n = $Arguments[$i]
            if (-not [int]::TryParse($n, [ref]$lineCount) -or $lineCount -lt 0) {
                Write-Host ("head: invalid number of lines: " + $n)
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            continue
        }

        if ($parseOptions -and $arg -match '^--lines=(.+)$') {
            $n = $Matches[1]
            if (-not [int]::TryParse($n, [ref]$lineCount) -or $lineCount -lt 0) {
                Write-Host ("head: invalid number of lines: " + $n)
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            continue
        }

        if ($parseOptions -and $arg -eq "--lines") {
            if (($i + 1) -ge $Arguments.Count) {
                Write-Host "head: option requires an argument -- lines"
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            $n = $Arguments[$i]
            if (-not [int]::TryParse($n, [ref]$lineCount) -or $lineCount -lt 0) {
                Write-Host ("head: invalid number of lines: " + $n)
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            continue
        }

        if ($parseOptions -and $arg -match '^-n(\d+)$') {
            $n = $Matches[1]
            if (-not [int]::TryParse($n, [ref]$lineCount) -or $lineCount -lt 0) {
                Write-Host ("head: invalid number of lines: " + $n)
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            continue
        }

        if ($parseOptions -and $arg.StartsWith("-") -and $arg -ne "-") {
            Write-Host ("head: invalid option -- " + $arg)
            $global:LASTEXITCODE = 2
            return
        }

        $paths += $arg
        $i++
    }

    $hadError = $false
    if ($paths.Count -eq 0) {
        $lines = @($input | Out-String -Stream -Width 4096)
        $lines | Select-Object -First $lineCount
        $global:LASTEXITCODE = 0
        return
    }

    $showHeaders = $paths.Count -gt 1
    $firstOutput = $true

    foreach ($path in $paths) {
        $resolved = Resolve-Path -Path $path -ErrorAction SilentlyContinue
        if (-not $resolved) {
            Write-Host ("head: cannot open '" + $path + "' for reading: No such file or directory")
            $hadError = $true
            continue
        }

        foreach ($item in $resolved) {
            $full = $item.Path
            if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
                Write-Host ("head: error reading '" + $path + "': Is a directory")
                $hadError = $true
                continue
            }

            if ($showHeaders) {
                if (-not $firstOutput) {
                    Write-Output ""
                }
                Write-Output ("==> " + $full + " <==")
                $firstOutput = $false
            }

            try {
                $fileLines = Get-Content -LiteralPath $full -ErrorAction Stop
                $fileLines | Select-Object -First $lineCount
            } catch {
                Write-Host ("head: cannot read '" + $path + "'")
                $hadError = $true
            }
        }
    }

    $global:LASTEXITCODE = if ($hadError) { 1 } else { 0 }
}
}

$existingTail = Get-Command -Name tail -ErrorAction SilentlyContinue | Select-Object -First 1
if ($existingTail) {
    Write-Warning ("gabash_unx: loading 'tail' skipped because '" + $existingTail.Name + "' already exists as " + $existingTail.CommandType + ".")
} else {
function tail {
    $Arguments = @($args)

    $lineCount = 10
    $follow = $false
    $paths = @()
    $parseOptions = $true
    $i = 0

    while ($i -lt $Arguments.Count) {
        $arg = $Arguments[$i]

        if ($parseOptions -and $arg -eq "--") {
            $parseOptions = $false
            $i++
            continue
        }

        if ($parseOptions -and $arg -eq "-f") {
            $follow = $true
            $i++
            continue
        }

        if ($parseOptions -and $arg -eq "-n") {
            if (($i + 1) -ge $Arguments.Count) {
                Write-Host "tail: option requires an argument -- n"
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            $n = $Arguments[$i]
            if (-not [int]::TryParse($n, [ref]$lineCount) -or $lineCount -lt 0) {
                Write-Host ("tail: invalid number of lines: " + $n)
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            continue
        }

        if ($parseOptions -and $arg -eq "--follow") {
            $follow = $true
            $i++
            continue
        }

        if ($parseOptions -and $arg -match '^--lines=(.+)$') {
            $n = $Matches[1]
            if (-not [int]::TryParse($n, [ref]$lineCount) -or $lineCount -lt 0) {
                Write-Host ("tail: invalid number of lines: " + $n)
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            continue
        }

        if ($parseOptions -and $arg -eq "--lines") {
            if (($i + 1) -ge $Arguments.Count) {
                Write-Host "tail: option requires an argument -- lines"
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            $n = $Arguments[$i]
            if (-not [int]::TryParse($n, [ref]$lineCount) -or $lineCount -lt 0) {
                Write-Host ("tail: invalid number of lines: " + $n)
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            continue
        }

        if ($parseOptions -and $arg -match '^-n(\d+)$') {
            $n = $Matches[1]
            if (-not [int]::TryParse($n, [ref]$lineCount) -or $lineCount -lt 0) {
                Write-Host ("tail: invalid number of lines: " + $n)
                $global:LASTEXITCODE = 2
                return
            }
            $i++
            continue
        }

        if ($parseOptions -and $arg.StartsWith("-") -and $arg -ne "-") {
            Write-Host ("tail: invalid option -- " + $arg)
            $global:LASTEXITCODE = 2
            return
        }

        $paths += $arg
        $i++
    }

    $hadError = $false
    if ($paths.Count -eq 0) {
        if ($follow) {
            Write-Host "tail: -f without file is not supported in this implementation"
            $global:LASTEXITCODE = 1
            return
        }

        $lines = @($input | Out-String -Stream -Width 4096)
        $lines | Select-Object -Last $lineCount
        $global:LASTEXITCODE = 0
        return
    }

    $targets = @()
    foreach ($path in $paths) {
        $resolved = Resolve-Path -Path $path -ErrorAction SilentlyContinue
        if (-not $resolved) {
            Write-Host ("tail: cannot open '" + $path + "' for reading: No such file or directory")
            $hadError = $true
            continue
        }

        foreach ($item in $resolved) {
            $full = $item.Path
            if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
                Write-Host ("tail: error reading '" + $path + "': Is a directory")
                $hadError = $true
                continue
            }
            $targets += $full
        }
    }

    if ($targets.Count -eq 0) {
        $global:LASTEXITCODE = 1
        return
    }

    $showHeaders = $targets.Count -gt 1
    $states = @()
    $firstOutput = $true

    foreach ($target in $targets) {
        if ($showHeaders) {
            if (-not $firstOutput) {
                Write-Output ""
            }
            Write-Output ("==> " + $target + " <==")
            $firstOutput = $false
        }

        try {
            $lines = Get-Content -LiteralPath $target -ErrorAction Stop
            $lines | Select-Object -Last $lineCount
            $states += [pscustomobject]@{
                Path = $target
                LastCount = @($lines).Count
            }
        } catch {
            Write-Host ("tail: cannot read '" + $target + "'")
            $hadError = $true
        }
    }

    if (-not $follow) {
        $global:LASTEXITCODE = if ($hadError) { 1 } else { 0 }
        return
    }

    while ($true) {
        Start-Sleep -Milliseconds 500

        foreach ($state in $states) {
            if (-not (Test-Path -LiteralPath $state.Path -PathType Leaf)) {
                continue
            }

            try {
                $currentLines = @(Get-Content -LiteralPath $state.Path -ErrorAction Stop)
            } catch {
                continue
            }

            $currentCount = $currentLines.Count
            if ($currentCount -lt $state.LastCount) {
                $state.LastCount = 0
            }

            if ($currentCount -gt $state.LastCount) {
                if ($showHeaders) {
                    Write-Output ("==> " + $state.Path + " <==")
                }
                $start = [int]$state.LastCount
                for ($idx = $start; $idx -lt $currentCount; $idx++) {
                    Write-Output $currentLines[$idx]
                }
                $state.LastCount = $currentCount
            }
        }
    }
}
}

$existingGrep = Get-Command -Name grep -ErrorAction SilentlyContinue | Select-Object -First 1
if ($existingGrep) {
    Write-Warning ("gabash_unx: loading 'grep' skipped because '" + $existingGrep.Name + "' already exists as " + $existingGrep.CommandType + ".")
} else {
function grep {
    $Arguments = @($args)

    $ignoreCase = $false
    $invertMatch = $false
    $showLineNumber = $false
    $recursive = $false
    $filesWithMatches = $false
    $countOnly = $false
    $wordRegexp = $false
    $lineRegexp = $false
    $fixedStrings = $false
    $suppressErrors = $false
    $pattern = $null
    $paths = @()
    $parseOptions = $true

    foreach ($arg in $Arguments) {
        if ($parseOptions -and $arg -eq "--") {
            $parseOptions = $false
            continue
        }

        if ($parseOptions -and $arg.StartsWith("--")) {
            switch -Exact ($arg) {
                "--ignore-case" { $ignoreCase = $true }
                "--invert-match" { $invertMatch = $true }
                "--line-number" { $showLineNumber = $true }
                "--recursive" { $recursive = $true }
                "--files-with-matches" { $filesWithMatches = $true }
                "--count" { $countOnly = $true }
                "--word-regexp" { $wordRegexp = $true }
                "--line-regexp" { $lineRegexp = $true }
                "--fixed-strings" { $fixedStrings = $true }
                "--extended-regexp" { }
                "--no-messages" { $suppressErrors = $true }
                default {
                    if (-not $suppressErrors) {
                        Write-Host ("grep: invalid option -- " + $arg)
                    }
                    $global:LASTEXITCODE = 2
                    return
                }
            }
            continue
        }

        if ($parseOptions -and $arg.StartsWith("-") -and $arg -ne "-") {
            $options = $arg.Substring(1).ToCharArray()
            foreach ($opt in $options) {
                switch ($opt) {
                    "i" { $ignoreCase = $true }
                    "v" { $invertMatch = $true }
                    "n" { $showLineNumber = $true }
                    "r" { $recursive = $true }
                    "R" { $recursive = $true }
                    "l" { $filesWithMatches = $true }
                    "c" { $countOnly = $true }
                    "w" { $wordRegexp = $true }
                    "x" { $lineRegexp = $true }
                    "F" { $fixedStrings = $true }
                    "E" { }
                    "s" { $suppressErrors = $true }
                    default {
                        if (-not $suppressErrors) {
                            Write-Host ("grep: invalid option -- " + $opt)
                        }
                        $global:LASTEXITCODE = 2
                        return
                    }
                }
            }
            continue
        }

        if ($null -eq $pattern) {
            $pattern = $arg
        } else {
            $paths += $arg
        }
    }

    if ([string]::IsNullOrEmpty($pattern)) {
        if (-not $suppressErrors) {
            Write-Host "Usage: grep [-ivnrlcwxFEs] pattern [file ...]"
        }
        $global:LASTEXITCODE = 2
        return
    }

    if ($fixedStrings) {
        $pattern = [regex]::Escape($pattern)
    }
    if ($wordRegexp) {
        $pattern = "\b(?:$pattern)\b"
    }
    if ($lineRegexp) {
        $pattern = "^(?:$pattern)$"
    }

    $regexOptions = [System.Text.RegularExpressions.RegexOptions]::None
    if ($ignoreCase) {
        $regexOptions = $regexOptions -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    }

    try {
        $matcher = [regex]::new($pattern, $regexOptions)
    } catch {
        if (-not $suppressErrors) {
            Write-Host ("grep: invalid regular expression: " + $pattern)
        }
        $global:LASTEXITCODE = 2
        return
    }

    $targets = New-Object System.Collections.Generic.List[object]
    $hadError = $false
    $foundAny = $false
    $hasFileTargets = $paths.Count -gt 0

    if ($hasFileTargets) {
        foreach ($path in $paths) {
            $resolved = Resolve-Path -Path $path -ErrorAction SilentlyContinue
            if (-not $resolved) {
                if (-not $suppressErrors) {
                    Write-Host ("grep: " + $path + ": No such file or directory")
                }
                $hadError = $true
                continue
            }

            foreach ($item in $resolved) {
                $full = $item.Path
                if (Test-Path -LiteralPath $full -PathType Leaf) {
                    [void]$targets.Add([pscustomobject]@{ Kind = "file"; Path = $full; Display = $full })
                    continue
                }

                if (Test-Path -LiteralPath $full -PathType Container) {
                    if (-not $recursive) {
                        if (-not $suppressErrors) {
                            Write-Host ("grep: " + $path + ": Is a directory")
                        }
                        $hadError = $true
                        continue
                    }

                    $files = Get-ChildItem -LiteralPath $full -File -Recurse -ErrorAction SilentlyContinue
                    foreach ($file in $files) {
                        [void]$targets.Add([pscustomobject]@{ Kind = "file"; Path = $file.FullName; Display = $file.FullName })
                    }
                }
            }
        }
    } else {
        # Render piped objects using PowerShell's formatting engine to mimic displayed text.
        $stdinLines = @($input | Out-String -Stream -Width 4096)
        [void]$targets.Add([pscustomobject]@{ Kind = "stdin"; Lines = $stdinLines; Display = "" })
    }

    $showFilename = $targets.Count -gt 1
    foreach ($target in $targets) {
        $matchCount = 0
        $lineNumber = 0

        if ($target.Kind -eq "file") {
            try {
                $lines = Get-Content -LiteralPath $target.Path -ErrorAction Stop
            } catch {
                if (-not $suppressErrors) {
                    Write-Host ("grep: " + $target.Display + ": Cannot read file")
                }
                $hadError = $true
                continue
            }
        } else {
            $lines = $target.Lines
        }

        foreach ($line in $lines) {
            $lineNumber++
            $isMatch = $matcher.IsMatch([string]$line)
            if ($invertMatch) {
                $isMatch = -not $isMatch
            }
            if (-not $isMatch) {
                continue
            }

            $foundAny = $true
            $matchCount++

            if ($filesWithMatches -or $countOnly) {
                continue
            }

            $prefix = ""
            if ($showFilename -and $target.Kind -eq "file") {
                $prefix += ($target.Display + ":")
            }
            if ($showLineNumber) {
                $prefix += ($lineNumber.ToString() + ":")
            }
            Write-Output ($prefix + [string]$line)
        }

        if ($filesWithMatches -and $matchCount -gt 0 -and $target.Kind -eq "file") {
            Write-Output $target.Display
        }

        if ($countOnly) {
            if ($showFilename -and $target.Kind -eq "file") {
                Write-Output ($target.Display + ":" + $matchCount)
            } else {
                Write-Output $matchCount
            }
        }
    }

    if ($hadError) {
        $global:LASTEXITCODE = 2
        return
    }

    $global:LASTEXITCODE = if ($foundAny) { 0 } else { 1 }
}
}
