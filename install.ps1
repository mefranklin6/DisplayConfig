Param(
    [Parameter(Mandatory = $true)]
    [string]$PC,
    [Parameter(Mandatory = $true)]
    [string]$Version,
    [Parameter(Mandatory = $false)]
    [string]$standalone = "true"
)


# Workaround for passing in booleans from other languages, if used.
if ($standalone -eq "true") {
    $standalone = $true
}
else {
    $standalone = $false
}

function ConvertTo-NormalizedVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    $normalized = $Version.Trim()
    if ($normalized.StartsWith('v', [System.StringComparison]::OrdinalIgnoreCase)) {
        $normalized = $normalized.Substring(1)
    }

    if ([string]::IsNullOrWhiteSpace($normalized)) {
        throw "Invalid Version '$Version'. Expected numeric dotted version like '3.2' (optionally prefixed with 'v')."
    }

    # Require at least one dot to avoid accepting just '3'
    if ($normalized -notmatch '^\d+(\.\d+)+$') {
        throw "Invalid Version '$Version'. Expected numeric dotted version like '3.2' (optionally prefixed with 'v')."
    }

    return $normalized
}


function Test-IsLocalComputer {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )

    $name = $ComputerName.Trim()

    return ($name -ieq $env:COMPUTERNAME) -or
    ($name -ieq 'localhost') -or
    ($name -ieq '.') -or
    ($name -ieq '127.0.0.1')
}


function Invoke-LocalOrRemote {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [object[]]$ArgumentList,

        [Parameter(Mandatory = $true)]
        [string]$ComputerName,

        [Parameter(Mandatory = $true)]
        [bool]$IsLocal
    )

    if ($IsLocal) {
        if ($null -ne $ArgumentList -and $ArgumentList.Count -gt 0) {
            return & $ScriptBlock @ArgumentList
        }
        return & $ScriptBlock
    }

    $params = @{
        ComputerName = $ComputerName
        ScriptBlock  = $ScriptBlock
        ErrorAction  = 'Stop'
    }
    if ($null -ne $ArgumentList -and $ArgumentList.Count -gt 0) {
        $params['ArgumentList'] = $ArgumentList
    }
    return Invoke-Command @params
}


function Test-HostReachable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,

        [Parameter(Mandatory = $false)]
        [int]$TimeoutMilliseconds = 1000
    )

    try {
        $ping = [System.Net.NetworkInformation.Ping]::new()
        $reply = $ping.Send($ComputerName, $TimeoutMilliseconds)
        return $reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success
    }
    catch {
        return $false
    }
}

$isLocal = Test-IsLocalComputer -ComputerName $PC

Write-Output "$PC Installing DisplayConfig from (mefranklin6 fork)"

$DisplayConfigModuleName = 'DisplayConfig'
try {

    $Version = ConvertTo-NormalizedVersion -Version $Version
    $DisplayConfigZipUrl = "https://github.com/mefranklin6/$DisplayConfigModuleName/releases/download/v$Version/$DisplayConfigModuleName-$Version.zip"

    if ($standalone -and -not $isLocal) {
        if (-not (Test-HostReachable -ComputerName $PC -TimeoutMilliseconds 1000)) {
            throw "$PC is not reachable"
        }
    }

    # Install DisplayConfig from a pinned GitHub release ZIP
    Invoke-LocalOrRemote -ComputerName $PC -IsLocal $isLocal -ArgumentList @(
        $DisplayConfigZipUrl,
        $DisplayConfigModuleName,
        $Version
    ) -ScriptBlock {
        param(
            [Parameter(Mandatory = $true)]
            [string]$ZipUrl,
            [Parameter(Mandatory = $true)]
            [string]$ModuleName,
            [Parameter(Mandatory = $true)]
            [string]$ModuleVersion
        )

        $ErrorActionPreference = 'Stop'
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        function Get-WritableModuleRoot {
            param(
                [Parameter(Mandatory = $true)]
                [string[]]$Candidates
            )

            foreach ($candidate in $Candidates) {
                if ([string]::IsNullOrWhiteSpace($candidate)) { continue }
                $p = $candidate.Trim()
                try {
                    $null = New-Item -ItemType Directory -Path $p -Force -ErrorAction Stop
                    $probe = Join-Path $p ("_probe_" + [Guid]::NewGuid().ToString('N'))
                    $null = New-Item -ItemType Directory -Path $probe -Force -ErrorAction Stop
                    Remove-Item -LiteralPath $probe -Recurse -Force -ErrorAction SilentlyContinue
                    return $p
                }
                catch {
                    continue
                }
            }

            return $null
        }

        $modulePaths = @()
        if (-not [string]::IsNullOrWhiteSpace($env:PSModulePath)) {
            $modulePaths = $env:PSModulePath -split ';' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique
        }

        $preferred = @()
        $preferred += $modulePaths | Where-Object { $_ -match '\\Documents\\(WindowsPowerShell|PowerShell)\\Modules$' }

        $myDocs = [Environment]::GetFolderPath('MyDocuments')
        if (-not [string]::IsNullOrWhiteSpace($myDocs)) {
            if ($PSVersionTable.PSEdition -eq 'Core') {
                $preferred += (Join-Path $myDocs 'PowerShell\Modules')
            }
            else {
                $preferred += (Join-Path $myDocs 'WindowsPowerShell\Modules')
            }
        }

        $preferred += $modulePaths

        $installRoot = Get-WritableModuleRoot -Candidates ($preferred | Select-Object -Unique)
        if ([string]::IsNullOrWhiteSpace($installRoot)) {
            throw "No writable PowerShell module path found in PSModulePath"
        }

        $destVersionRoot = Join-Path (Join-Path $installRoot $ModuleName) $ModuleVersion
        $destManifestPath = Join-Path $destVersionRoot "${ModuleName}.psd1"

        if (Test-Path -LiteralPath $destManifestPath) {
            try {
                Import-Module -Name $destManifestPath -Force -ErrorAction Stop
                Write-Output "$env:COMPUTERNAME $ModuleName $ModuleVersion already installed at $destVersionRoot, skipping."
                return
            }
            catch {
                # fall through to reinstall
            }
        }

        $tempRoot = Join-Path $env:TEMP ("${ModuleName}_" + [Guid]::NewGuid().ToString('N'))
        $null = New-Item -ItemType Directory -Path $tempRoot -Force
        $zipPath = Join-Path $tempRoot "${ModuleName}-${ModuleVersion}.zip"
        $extractPath = Join-Path $tempRoot 'extracted'

        try {
            Invoke-WebRequest -Uri $ZipUrl -OutFile $zipPath -UseBasicParsing
        }
        catch {
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($ZipUrl, $zipPath)
        }

        if (-not (Test-Path -LiteralPath $zipPath)) {
            throw "Download failed: $zipPath not found"
        }

        try { Unblock-File -LiteralPath $zipPath -ErrorAction SilentlyContinue } catch { }

        Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath -Force

        $manifest = Get-ChildItem -Path $extractPath -Recurse -File -Filter "${ModuleName}.psd1" | Select-Object -First 1
        if ($null -eq $manifest) {
            throw "Module manifest ${ModuleName}.psd1 not found in extracted archive"
        }
        $moduleSourceRoot = Split-Path -Parent $manifest.FullName

        Remove-Item -LiteralPath $destVersionRoot -Recurse -Force -ErrorAction SilentlyContinue
        $null = New-Item -ItemType Directory -Path $destVersionRoot -Force

        Copy-Item -Path (Join-Path $moduleSourceRoot '*') -Destination $destVersionRoot -Recurse -Force

        if (-not (Test-Path -LiteralPath $destManifestPath)) {
            throw "$ModuleName manifest not found at $destManifestPath after copy"
        }

        try {
            Get-ChildItem -LiteralPath $destVersionRoot -Recurse -File -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue
        }
        catch { }

        Import-Module -Name $destManifestPath -Force -ErrorAction Stop
        Write-Output "$env:COMPUTERNAME Installed $ModuleName $ModuleVersion from ZIP to $destVersionRoot"
    }

    Start-Sleep -Seconds 1

    # Verify DisplayConfig is installed/available
    $installed = Invoke-LocalOrRemote -ComputerName $PC -IsLocal $isLocal -ArgumentList @(
        $DisplayConfigModuleName,
        $Version
    ) -ScriptBlock {
        param(
            [string]$ModuleName,
            [string]$ModuleVersion
        )

        $m = Get-Module -ListAvailable -Name $ModuleName | Sort-Object Version -Descending | Select-Object -First 1
        if ($m) { return $m }

        if ([string]::IsNullOrWhiteSpace($env:PSModulePath)) {
            return $null
        }

        foreach ($root in ($env:PSModulePath -split ';' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)) {
            $candidate = Join-Path (Join-Path (Join-Path $root $ModuleName) $ModuleVersion) "${ModuleName}.psd1"
            if (Test-Path -LiteralPath $candidate) {
                try {
                    Import-Module -Name $candidate -Force -ErrorAction Stop
                }
                catch { }
                return (Get-Module -ListAvailable -Name $ModuleName | Sort-Object Version -Descending | Select-Object -First 1)
            }
        }

        return $null
    }

    if ($null -eq $installed) {
        throw "$PC DisplayConfig (mefranklin6 fork) not installed"
    }
    else {
        Write-Output "$PC DisplayConfig (mefranklin6 fork) installed ($($installed.Version))"
    }

} # end try
catch {
    Write-Output "$PC InstallDisplayConfig (mefranklin6 fork) failed: $_"
    Exit 1
}

Exit 0