<#
  Creates a Windows 11 ISO that boots immediately (without the "Press any key to boot from CD or DVD..." prompt).
  Uses Windows ADK (with the Windows PE add-on).
#>

##############
# Config area

$SourceIso = 'C:\ISO\Win11_25H2_English_x64.iso'
$OutputIso = 'C:\ISO\Win11_25H2_NoPrompt.iso'

##############
# Main script

$ErrorActionPreference = 'Stop'

function Find-AdkDeploymentToolsPath {
    $candidates = @(
        'C:\Program Files (x86)\Windows Kits\11\Assessment and Deployment Kit\Deployment Tools',
        'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools'
    )

    foreach ($cand in $candidates) {
        if (Test-Path -LiteralPath $cand) { return $cand }
    }
    throw "Windows ADK Deployment Tools not found in default locations"
}

function Ensure-Exists {
    param([string]$Path, [string]$What)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$What not found: $Path"
    }
}

# Create temp workspace
$WorkDir = Join-Path $env:TEMP ("Win11ISO_{0}" -f ([guid]::NewGuid().ToString('N')))
$StageDir = Join-Path $WorkDir 'ISO'
New-Item -ItemType Directory -Force -Path $StageDir | Out-Null

Write-Host "Working directory: $WorkDir" -ForegroundColor DarkCyan

try {
    Write-Host "Preparing..." -ForegroundColor Cyan

    $adkRoot = Find-AdkDeploymentToolsPath
    $oscdimgExe      = Join-Path $adkRoot 'amd64\Oscdimg\oscdimg.exe'
    $etfsBootCom     = Join-Path $adkRoot 'amd64\Oscdimg\etfsboot.com'
    $efiNoPromptBin  = Join-Path $adkRoot 'amd64\Oscdimg\efisys_noprompt.bin'

    Ensure-Exists $oscdimgExe     'oscdimg.exe'
    Ensure-Exists $etfsBootCom    'etfsboot.com'
    Ensure-Exists $efiNoPromptBin 'efisys_noprompt.bin'
    Ensure-Exists $SourceIso      'Source ISO'

    # Mount the source ISO and copy its contents
    Write-Host "Mounting source ISO..." -ForegroundColor Cyan
    $disk = Mount-DiskImage -ImagePath $SourceIso -PassThru
    Start-Sleep -Milliseconds 300

    $vol = ($disk | Get-Volume)
    if (-not $vol) { throw "Failed to resolve mounted ISO volume." }

    $srcDrive = "{0}:\" -f $vol.DriveLetter
    Write-Host "Mounted at $srcDrive (Label: $($vol.FileSystemLabel))"

	$IsoLabel = $vol.FileSystemLabel
    if ([string]::IsNullOrWhiteSpace($IsoLabel)) { $IsoLabel = 'WIN11' }

    Write-Host "Copying ISO contents to temp folder..." -ForegroundColor Cyan
    $rc = robocopy $srcDrive $StageDir /E /NFL /NDL /NJH /NJS /NP
    if ($LASTEXITCODE -gt 3) { throw "Robocopy failed with exit code $LASTEXITCODE" }

    # Prepare oscdimg arguments
    $bootdata = ('-bootdata:2#p0,e,b"{0}"#pEF,e,b"{1}"' -f $etfsBootCom, $efiNoPromptBin)

    $args = @(
        '-m',
        '-o',
        '-u2',
        '-udfver102',
        "-l$IsoLabel",
        $bootdata,
        "`"$StageDir`"",
        "`"$OutputIso`""
    )

    Write-Host "Building output ISO..." -ForegroundColor Cyan
    & "$oscdimgExe" $args
    if ($LASTEXITCODE -ne 0) {
        throw "oscdimg failed with exit code $LASTEXITCODE"
    }

    Write-Host "`nISO created successfully:" -ForegroundColor Green
    Write-Host "$OutputIso" -ForegroundColor Green
}
finally {
    Write-Host "Cleaning up..." -ForegroundColor Cyan
    try {
        Dismount-DiskImage -ImagePath $SourceIso -ErrorAction SilentlyContinue
    } catch {}
    try {
        Remove-Item -Recurse -Force -LiteralPath $WorkDir -ErrorAction SilentlyContinue
    } catch {}
}

