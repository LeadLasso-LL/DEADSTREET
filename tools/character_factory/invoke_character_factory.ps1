# Dead Street Character Factory launcher.
# Discovers DAZ Studio, runs unattended handshake/smoke/proof, validates PNGs with Godot.
# Generated art is NOT bound into the game.

[CmdletBinding()]
param(
    [ValidateSet("handshake", "smoke", "proof", "calibrate", "silhouette")]
    [string]$Mode = "smoke",
    [string]$RecipePath = "",
    [int]$TimeoutSeconds = 0,
    [string]$RepoRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RepoRoot {
    param([string]$Hint)
    if ($Hint -and (Test-Path (Join-Path $Hint "project.godot"))) {
        return (Resolve-Path $Hint).Path
    }
    if ($PSScriptRoot) {
        $fromScript = Resolve-Path (Join-Path $PSScriptRoot "..\..")
        if (Test-Path (Join-Path $fromScript "project.godot")) {
            return $fromScript.Path
        }
    }
    throw "Could not locate Dead Street repo root (project.godot)."
}

function Find-DazStudioExe {
    $found = New-Object System.Collections.Generic.List[string]

    $uninstall = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($root in $uninstall) {
        Get-ItemProperty $root -ErrorAction SilentlyContinue |
            Where-Object { $_.PSObject.Properties['DisplayName'] -and $_.DisplayName -match "DAZ Studio|Daz Studio" } |
            ForEach-Object {
                $install = $null
                if ($_.PSObject.Properties['InstallLocation']) { $install = $_.InstallLocation }
                if ($install -and (Test-Path $install)) {
                    Get-ChildItem $install -Recurse -Filter "DAZStudio.exe" -ErrorAction SilentlyContinue |
                        ForEach-Object { $found.Add($_.FullName) }
                }
                $icon = $null
                if ($_.PSObject.Properties['DisplayIcon']) { $icon = $_.DisplayIcon }
                if ($icon) {
                    $icon = ([string]$icon).Trim('"')
                    if ($icon -match "DAZStudio\.exe" -and (Test-Path $icon)) { $found.Add($icon) }
                }
            }
    }

    $searchRoots = @(
        ${env:ProgramFiles},
        ${env:ProgramFiles(x86)},
        ${env:LOCALAPPDATA}
    ) | Where-Object { $_ }
    foreach ($root in $searchRoots) {
        $dazRoot = Join-Path $root "DAZ 3D"
        if (Test-Path $dazRoot) {
            Get-ChildItem $dazRoot -Recurse -Filter "DAZStudio.exe" -ErrorAction SilentlyContinue |
                ForEach-Object { $found.Add($_.FullName) }
        }
    }

    $unique = $found | Where-Object { $_ -and (Test-Path $_) } | Sort-Object -Unique
    if (-not $unique) {
        return $null
    }
    # Prefer newer StudioN folders without hardcoding a single machine path.
    return $unique | Sort-Object {
        if ($_ -match "DAZStudio(\d+)") { [int]$Matches[1] } else { 0 }
    } | Select-Object -Last 1
}

function Find-GodotExe {
    $candidates = New-Object System.Collections.Generic.List[string]
    $cmd = Get-Command godot -ErrorAction SilentlyContinue
    if ($cmd) { $candidates.Add($cmd.Source) }

    $searchRoots = @(
        (Join-Path $env:LOCALAPPDATA "Temp"),
        (Join-Path $env:LOCALAPPDATA "Programs"),
        ${env:ProgramFiles},
        ${env:ProgramFiles(x86)}
    ) | Where-Object { $_ -and (Test-Path $_) }

    foreach ($root in $searchRoots) {
        Get-ChildItem $root -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match "godot" } |
            ForEach-Object {
                Get-ChildItem $_.FullName -Filter "Godot*.exe" -ErrorAction SilentlyContinue |
                    ForEach-Object { $candidates.Add($_.FullName) }
            }
        Get-ChildItem $root -Filter "godot.exe" -ErrorAction SilentlyContinue |
            ForEach-Object { $candidates.Add($_.FullName) }
    }

    $unique = $candidates | Where-Object { $_ -and (Test-Path $_) } | Sort-Object -Unique
    if (-not $unique) { return $null }
    $console = $unique | Where-Object { $_ -match "console" -and $_ -match "4\.7" } | Select-Object -First 1
    if ($console) { return $console }
    $v47 = $unique | Where-Object { $_ -match "4\.7" } | Select-Object -First 1
    if ($v47) { return $v47 }
    return $unique | Select-Object -Last 1
}

function Write-Utf8NoBom {
    param([string]$Path, [string]$Text)
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

function Write-FactoryResult {
    param(
        [string]$Path,
        [object]$Result
    )
    Write-Utf8NoBom -Path $Path -Text ($Result | ConvertTo-Json -Depth 16)
}

function Read-JsonFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    return (Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json)
}

$repo = Get-RepoRoot -Hint $RepoRoot
$factoryRoot = Join-Path $repo "tools\character_factory"
$dsaPath = Join-Path $factoryRoot "daz\dead_street_factory.dsa"
if (-not $RecipePath) {
    if ($Mode -eq "proof") {
        $RecipePath = Join-Path $factoryRoot "recipes\local_street_gang_rifleman_proof_01.json"
    } elseif ($Mode -eq "calibrate") {
        $RecipePath = Join-Path $factoryRoot "recipes\local_street_gang_rifleman_calib_v11.json"
    } elseif ($Mode -eq "silhouette") {
        $RecipePath = Join-Path $factoryRoot "recipes\local_street_gang_rifleman_silhouette_v12.json"
    } else {
        $RecipePath = Join-Path $factoryRoot "recipes\smoke_genesis9.json"
    }
}
if (-not (Test-Path -LiteralPath $dsaPath)) {
    throw "Missing factory script: $dsaPath"
}
if (-not (Test-Path -LiteralPath $RecipePath)) {
    throw "Missing recipe: $RecipePath"
}

if ($TimeoutSeconds -le 0) {
    $TimeoutSeconds = if ($Mode -eq "handshake") { 180 } else { 2400 }
}

$outputRoot = Join-Path $env:LOCALAPPDATA "DeadStreetCharacterFactory"
$runId = "{0}_{1}" -f (Get-Date -Format "yyyyMMdd_HHmmss"), $Mode
$runDir = Join-Path $outputRoot "runs\$runId"
$sourceDir = Join-Path $runDir "source"
New-Item -ItemType Directory -Force -Path $runDir, $sourceDir | Out-Null

$resultPath = Join-Path $runDir "factory_result.json"
$dazResultPath = Join-Path $runDir "daz_result.json"
$envReportPath = Join-Path $runDir "environment.json"
$logPath = Join-Path $runDir "factory.log"
$configPath = Join-Path $runDir "factory_config.json"
$latestPath = Join-Path $outputRoot "latest_run.txt"

$recipe = Read-JsonFile -Path $RecipePath
$dazExe = Find-DazStudioExe
$godotExe = Find-GodotExe

$baseResult = [ordered]@{
    status            = "FAIL"
    stage             = "launcher"
    error_code        = "FAIL"
    reason            = "launcher did not complete"
    factory_version   = "0.2.0"
    mode              = $Mode
    run_dir           = $runDir
    repo_root         = $repo
    daz_executable    = $dazExe
    godot_executable  = $godotExe
    daz_version       = $null
    release_cycle     = $null
    content_roots     = @()
    resolved_assets   = @{}
    render_files      = @()
    preview_board     = $null
    preview_boards    = @{}
    log_path          = $logPath
    durations_sec     = [ordered]@{ launcher = 0; daz = 0; godot = 0 }
    started_at        = (Get-Date).ToString("o")
    finished_at       = $null
}

function Complete-Run {
    param([string]$Status, [string]$Stage, [string]$Code, [string]$Reason)
    $baseResult.status = $Status
    $baseResult.stage = $Stage
    $baseResult.error_code = $Code
    $baseResult.reason = $Reason
    $baseResult.finished_at = (Get-Date).ToString("o")
    $baseResult.durations_sec.launcher = [math]::Round(((Get-Date) - [datetime]$baseResult.started_at).TotalSeconds, 2)
    Write-FactoryResult -Path $resultPath -Result $baseResult
    Set-Content -LiteralPath $latestPath -Value $runDir -Encoding UTF8
    Write-Host ("CHARACTER FACTORY {0}: {1} ({2})" -f $Status, $Reason, $Code)
}

$swAll = [System.Diagnostics.Stopwatch]::StartNew()
"Character Factory $Mode start $(Get-Date -Format o)" | Set-Content -LiteralPath $logPath -Encoding UTF8
Add-Content -LiteralPath $logPath -Value "run_dir=$runDir"

if (-not $dazExe) {
    Complete-Run "BLOCKED" "discover" "DAZ_NOT_FOUND" "DAZ Studio executable was not found via registry or Program Files search."
    exit 2
}
Add-Content -LiteralPath $logPath -Value "daz_exe=$dazExe"

$config = [ordered]@{
    factory_version   = "0.2.0"
    mode              = $Mode
    run_dir           = $runDir
    result_path       = $dazResultPath
    daz_result_path   = $dazResultPath
    env_report_path   = $envReportPath
    log_path          = (Join-Path $runDir "daz_script.log")
    source_dir        = $sourceDir
    recipe            = $recipe
}
Write-Utf8NoBom -Path $configPath -Text ($config | ConvertTo-Json -Depth 16)

$argString = '"{0}" -noDefaultScene -noPrompt -scriptArg "{1}"' -f $dsaPath, $configPath
Add-Content -LiteralPath $logPath -Value ("daz args: " + $argString)

$swDaz = [System.Diagnostics.Stopwatch]::StartNew()
$workDir = Split-Path -Parent $dazExe
$proc = Start-Process -FilePath $dazExe -ArgumentList $argString -WorkingDirectory $workDir -PassThru
if (-not $proc) {
    Complete-Run "FAIL" "launch" "DAZ_NOT_FOUND" "Start-Process returned no DAZ process."
    exit 2
}

$exited = $proc.WaitForExit($TimeoutSeconds * 1000)
$swDaz.Stop()
$baseResult.durations_sec.daz = [math]::Round($swDaz.Elapsed.TotalSeconds, 2)

if (-not $exited) {
    Add-Content -LiteralPath $logPath -Value "TIMEOUT - killing DAZ process tree $($proc.Id)"
    & taskkill.exe /PID $proc.Id /T /F | Out-Null
    Start-Sleep -Seconds 2
    Complete-Run "FAIL" "daz_wait" "TIMEOUT" "DAZ did not finish within $TimeoutSeconds seconds."
    exit 3
}

$dazExit = $proc.ExitCode
Add-Content -LiteralPath $logPath -Value "DAZ process exit=$dazExit elapsed=$($baseResult.durations_sec.daz)s"

$dazResult = Read-JsonFile -Path $dazResultPath
$envReport = Read-JsonFile -Path $envReportPath
if ($envReport) {
    $baseResult.daz_version = $envReport.long_version
    $baseResult.release_cycle = $envReport.release_cycle
    $baseResult.content_roots = @($envReport.content_roots)
}
if ($dazResult) {
    $baseResult.daz_version = $dazResult.daz_version
    $baseResult.release_cycle = $dazResult.release_cycle
    $baseResult.content_roots = @($dazResult.content_roots)
    $baseResult.resolved_assets = $dazResult.resolved_assets
    $baseResult.render_files = @($dazResult.render_files)
    if ($dazResult.PSObject.Properties['calibration_cells'] -and $dazResult.calibration_cells) {
        $baseResult.calibration_cells = $dazResult.calibration_cells
    }
}

if (-not $dazResult) {
    Complete-Run "FAIL" "daz_script" "FAIL" "DAZ process exited ($dazExit) without writing daz_result.json. Treat as DAZ process/script launch failure."
    exit 4
}

if ($dazResult.status -ne "PASS") {
    Complete-Run $dazResult.status $dazResult.stage $dazResult.error_code $dazResult.reason
    exit 5
}

if ($Mode -eq "handshake") {
    Complete-Run "PASS" "handshake" "" "Unattended DAZ handshake completed."
    exit 0
}

if (-not $godotExe) {
    Complete-Run "FAIL" "godot" "GODOT_IMAGE_TOOL_FAILED" "Godot executable was not found for image validation."
    exit 6
}

$swGodot = [System.Diagnostics.Stopwatch]::StartNew()
$godotArgs = @(
    "--headless",
    "--path", $repo,
    "-s", "res://tools/character_factory/godot/character_factory_image_tool.gd",
    "--",
    "--run-dir", $runDir
)
Add-Content -LiteralPath $logPath -Value ("godot: " + $godotExe + " " + ($godotArgs -join " "))
$godotProc = Start-Process -FilePath $godotExe -ArgumentList $godotArgs -Wait -PassThru -NoNewWindow
$swGodot.Stop()
$baseResult.durations_sec.godot = [math]::Round($swGodot.Elapsed.TotalSeconds, 2)
Add-Content -LiteralPath $logPath -Value "godot exit=$($godotProc.ExitCode) elapsed=$($baseResult.durations_sec.godot)s"

$imageResult = Read-JsonFile -Path (Join-Path $runDir "image_validation.json")
if ($godotProc.ExitCode -ne 0 -or -not $imageResult -or -not $imageResult.ok) {
    $reason = if ($imageResult) { [string]$imageResult.reason } else { "Godot image tool failed (exit $($godotProc.ExitCode))" }
    $code = if ($imageResult -and $imageResult.error_code) { [string]$imageResult.error_code } else { "GODOT_IMAGE_TOOL_FAILED" }
    Complete-Run "FAIL" "image_validation" $code $reason
    exit 7
}

$baseResult.preview_board = $imageResult.preview_board
if ($imageResult.PSObject.Properties['preview_boards'] -and $imageResult.preview_boards) {
    $baseResult.preview_boards = $imageResult.preview_boards
}
$swAll.Stop()
$baseResult.durations_sec.launcher = [math]::Round($swAll.Elapsed.TotalSeconds, 2)
$doneReason = if ($Mode -eq "proof") {
    "Unattended DAZ rifleman proof and Godot style boards complete. Art is not product-accepted and is not bound."
} elseif ($Mode -eq "calibrate") {
    "Unattended DAZ camera/pose calibration complete. No camera or pose is accepted. Art is not bound."
} elseif ($Mode -eq "silhouette") {
    "Unattended DAZ hybrid rifle silhouette complete. Camera 56 is provisional, not canon. No pose is accepted. Art is not bound."
} else {
    "Unattended DAZ smoke and Godot PNG validation complete. Art is not product-accepted."
}
Complete-Run "PASS" "image_validation" "" $doneReason
exit 0
