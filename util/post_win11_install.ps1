# Ensure script is running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "Please run this script as Administrator."
  exit 1
}

###############
# Install apps

function Install-MyApps {
  $wingetargs = @("--exact", "--accept-package-agreements", "--accept-source-agreements", "--silent", "--source", "winget")
  winget install --id Microsoft.VisualStudioCode @wingetargs
  winget install --id Notepad++.Notepad++ @wingetargs
  winget install --id Mozilla.Firefox @wingetargs
  winget install --id Microsoft.PowerShell @wingetargs
  winget install --id Neovim.Neovim @wingetargs
  winget install --id GitHub.cli @wingetargs
  winget install --id Docker.DockerDesktop @wingetargs
}

##################
# Edge extensions

function Install-MyEdgeExtensions {
  $extensions = @(
    "cimighlppcgcoapaliogpjjdehbnofhn;https://edge.microsoft.com/extensionwebstorebase/v1/crx",
    "mbmgnelfcpoecdepckhlhegpcehmpmji;https://edge.microsoft.com/extensionwebstorebase/v1/crx"
  )

  $regPath = "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist"

  if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
  }

  $count = 1
  foreach ($ext in $extensions) {
    Set-ItemProperty -Path $regPath -Name $count -Value $ext
    $count++
  }
}

#####################
# Firefox extensions

function Install-MyFirefoxExtensions {
  $registryPath = "HKLM:\SOFTWARE\Policies\Mozilla\Firefox"
  $extensionSettingsPath = "$registryPath\ExtensionSettings"

  if (-not (Test-Path $registryPath)) {
    Write-Host "Creating Firefox policy registry key..." -ForegroundColor Yellow
    New-Item -Path "HKLM:\SOFTWARE\Policies\Mozilla" -Name "Firefox" -Force | Out-Null
  }

  if (-not (Test-Path $extensionSettingsPath)) {
    Write-Host "Creating ExtensionSettings registry key..." -ForegroundColor Yellow
    New-Item -Path $registryPath -Name "ExtensionSettings" -Force | Out-Null
  }

  $uBlockPath = "$extensionSettingsPath\uBlock0@raymondhill.net"
  if (-not (Test-Path $uBlockPath)) {
    New-Item -Path $extensionSettingsPath -Name "uBlock0@raymondhill.net" -Force | Out-Null
  }
  New-ItemProperty -Path $uBlockPath -Name "installation_mode" -Value "force_installed" -PropertyType String -Force | Out-Null
  New-ItemProperty -Path $uBlockPath -Name "install_url" -Value "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi" -PropertyType String -Force | Out-Null

  $sponsorBlockPath = "$extensionSettingsPath\sponsorBlocker@ajay.app"
  if (-not (Test-Path $sponsorBlockPath)) {
    New-Item -Path $extensionSettingsPath -Name "sponsorBlocker@ajay.app" -Force | Out-Null
  }
  New-ItemProperty -Path $sponsorBlockPath -Name "installation_mode" -Value "force_installed" -PropertyType String -Force | Out-Null
  New-ItemProperty -Path $sponsorBlockPath -Name "install_url" -Value "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi" -PropertyType String -Force | Out-Null
}

#############
# Nerd Fonts

function Install-MyNerdFonts {
  & "C:\Program Files\PowerShell\7\pwsh.exe" -c "Set-PSResourceRepository -Name PSGallery -Trusted"
  & "C:\Program Files\PowerShell\7\pwsh.exe" -c "Install-PSResource -Name NerdFonts"

  & "C:\Program Files\PowerShell\7\pwsh.exe" -c "Import-Module -Name NerdFonts; Install-NerdFont -Name 'FiraCode' -Scope AllUsers"
  & "C:\Program Files\PowerShell\7\pwsh.exe" -c "Import-Module -Name NerdFonts; Install-NerdFont -Name 'CascadiaCode' -Scope AllUsers"
  & "C:\Program Files\PowerShell\7\pwsh.exe" -c "Import-Module -Name NerdFonts; Install-NerdFont -Name 'CascadiaMono' -Scope AllUsers"
  & "C:\Program Files\PowerShell\7\pwsh.exe" -c "Import-Module -Name NerdFonts; Install-NerdFont -Name 'JetBrainsMono' -Scope AllUsers"
  & "C:\Program Files\PowerShell\7\pwsh.exe" -c "Import-Module -Name NerdFonts; Install-NerdFont -Name 'UbuntuSans' -Scope AllUsers"

  $chosenFontName = "CaskaydiaCove Nerd Font"

  $settingsPath = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
  ) | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $settingsPath) { throw "Windows Terminal settings.json not found." }

  $json = Get-Content $settingsPath -Raw | ConvertFrom-Json

  function Get-OrCreateObject([object]$parent, [string]$name) {
    if (-not $parent.PSObject.Properties[$name]) {
      $parent | Add-Member -NotePropertyName $name -NotePropertyValue ([pscustomobject]@{})
    }
    elseif ($parent.$name -isnot [pscustomobject]) {
      $parent.$name = [pscustomobject]$parent.$name
    }
    return $parent.$name
  }

  function Set-NoteProperty([object]$obj, [string]$name, $value) {
    if (-not $obj.PSObject.Properties[$name]) {
      $obj | Add-Member -NotePropertyName $name -NotePropertyValue $value
    }
    else {
      $obj.$name = $value
    }
  }

  $defaultsFont = Get-OrCreateObject $json.profiles 'defaults' | ForEach-Object { Get-OrCreateObject $_ 'font' }
  Set-NoteProperty $defaultsFont 'face' $chosenFontName

  foreach ($p in @($json.profiles.list)) {
    $pf = Get-OrCreateObject $p 'font'
    Set-NoteProperty $pf 'face' $chosenFontName
  }

  $json | ConvertTo-Json -Depth 50 | Set-Content $settingsPath -Encoding UTF8

  # start condrv automatically to prevent powershell init errors after reboot
  Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\condrv' -Name 'Start' -Type DWord -Value 2
}

########
# WSL 2

function Install-MyWSL {
  try {
    wsl --update
    wsl --install --no-launch -d Ubuntu
    wsl -d Ubuntu -u root -- bash -c "useradd -m -s /bin/bash mihai && echo 'mihai:changeme' | chpasswd && usermod -aG sudo mihai && echo '[user]' > /etc/wsl.conf && echo 'default=mihai' >> /etc/wsl.conf"
    wsl -d Ubuntu -u root -- bash -c "apt update"
  }
  catch {
    Write-Host "Error during WSL installation: $_" -ForegroundColor Red
    return
  }
}

###########
# AI tools

function Install-MyAI {
  wsl -d Ubuntu -u root -- bash -c "apt install -y nodejs npm"
  wsl -d Ubuntu -u root -- bash -c "npm install -g @openai/codex"
  wsl -d Ubuntu -u root -- bash -c "npm install -g @anthropic-ai/claude-code"
}

##############
# Build Tools
function Install-MyBuildTools {
  $InstallPath = "C:\BuildTools"
  $Url = "https://aka.ms/vs/17/release/vs_buildtools.exe"
  $Exe = Join-Path $env:TEMP "vs_buildtools.exe"

  try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

  Invoke-WebRequest -Uri $Url -OutFile $Exe

  $commonArgs = @(
    "--quiet", "--wait", "--norestart", "--nocache",
    "--installPath", "`"$InstallPath`"",
    "--add", "Microsoft.VisualStudio.Workload.VCTools", "--includeRecommended"
  )

  if (Test-Path $InstallPath) {
    $installerArgs = (@("modify") + $commonArgs) -join ' '
  }
  else {
    $installerArgs = $commonArgs -join ' '
  }

  Start-Process -FilePath $Exe -ArgumentList $installerArgs -Wait

  Remove-Item $Exe -Force
}

####################
# Execute functions

function Invoke-FunctionWithTiming {
  param(
    [string]$Name,
    [scriptblock]$Script
  )
  $start = Get-Date
  Write-Host "[$($start.ToString('HH:mm:ss'))] Starting $Name..." -ForegroundColor Cyan
  & $Script
  $elapsed = (Get-Date) - $start
  Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Name completed in $($elapsed.TotalSeconds) seconds" -ForegroundColor Green
}

Invoke-FunctionWithTiming -Name "App installation" -Script { Install-MyApps }
Invoke-FunctionWithTiming -Name "Edge extensions installation" -Script { Install-MyEdgeExtensions }
Invoke-FunctionWithTiming -Name "Firefox extensions installation" -Script { Install-MyFirefoxExtensions }
Invoke-FunctionWithTiming -Name "Nerd Fonts installation" -Script { Install-MyNerdFonts }
Invoke-FunctionWithTiming -Name "WSL installation" -Script { Install-MyWSL }
Invoke-FunctionWithTiming -Name "AI tools installation" -Script { Install-MyAI }
