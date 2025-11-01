# Ensure script is running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run this script as Administrator."
    exit 1
}

#########################
# Trigger Windows Update

$windowsUpdateScript = @'
Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force -Scope AllUsers -AllowClobber
Import-Module PSWindowsUpdate
Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot | Out-Null
'@

function PostInstall-WindowsUpdate {
	Write-Host "Triggering Windows Update" -ForegroundColor Cyan

	# Launch the update process in the background (non-blocking)
	Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$windowsUpdateScript`"" -Verb RunAs

	Write-Host "Done triggering Windows Update" -ForegroundColor Green
}

###############
# Install apps

function PostInstall-Apps {
	Write-Host "Installing apps" -ForegroundColor Cyan

	$wingetargs = @("--exact", "--accept-package-agreements", "--accept-source-agreements", "--silent", "--source", "winget")
	winget install --id Microsoft.VisualStudioCode @wingetargs
	winget install --id Notepad++.Notepad++ @wingetargs
	winget install --id Mozilla.Firefox @wingetargs
	winget install --id Microsoft.PowerShell @wingetargs

	Write-Host "Done installing apps" -ForegroundColor Green
}

##################
# Edge extensions

function PostInstall-EdgeExtensions {
	Write-Host "Installing Edge extensions" -ForegroundColor Cyan

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

	Write-Host "Edge extensions insalled" -ForegroundColor Green
}

#####################
# Firefox extensions

function PostInstall-FirefoxExtensions {
	Write-Host "Installing Firefox extensions" -ForegroundColor Cyan

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

	Write-Host "Firefox extensions installed" -ForegroundColor Green
}

#############
# Nerd Fonts

function PostInstall-NerdFonts {
	Write-Host "Installing Nerd Fonts" -ForegroundColor Cyan

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

	function Ensure-Object([object]$parent, [string]$name) {
	  if (-not $parent.PSObject.Properties[$name]) {
		$parent | Add-Member -NotePropertyName $name -NotePropertyValue ([pscustomobject]@{})
	  } elseif ($parent.$name -isnot [pscustomobject]) {
		$parent.$name = [pscustomobject]$parent.$name
	  }
	  return $parent.$name
	}

	function Ensure-NoteProperty([object]$obj, [string]$name, $value) {
	  if (-not $obj.PSObject.Properties[$name]) {
		$obj | Add-Member -NotePropertyName $name -NotePropertyValue $value
	  } else {
		$obj.$name = $value
	  }
	}

	$defaultsFont = Ensure-Object $json.profiles 'defaults' | ForEach-Object { Ensure-Object $_ 'font' }
	Ensure-NoteProperty $defaultsFont 'face' $chosenFontName

	foreach ($p in @($json.profiles.list)) {
	  $pf = Ensure-Object $p 'font'
	  Ensure-NoteProperty $pf 'face' $chosenFontName
	}

	$json | ConvertTo-Json -Depth 50 | Set-Content $settingsPath -Encoding UTF8

	Write-Host "Nerd Fonts Installed" -ForegroundColor Green
}

########
# WSL 2

function PostInstall-WSL {
	Write-Host "Installing WSL" -ForegroundColor Cyan

	# Enable required Windows features
	Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction SilentlyContinue | Out-Null
	Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction SilentlyContinue | Out-Null

	# Install WSL (includes Ubuntu by default)
	wsl --install -d Ubuntu

	# Wait until WSL is ready
	Write-Host "Waiting for WSL setup to complete..." -ForegroundColor Yellow
	while (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
		Start-Sleep -Seconds 5
	}

	Write-Host "WSL installation complete" -ForegroundColor Green
}

PostInstall-WindowsUpdate
PostInstall-Apps
PostInstall-EdgeExtensions
PostInstall-FirefoxExtensions
PostInstall-NerdFonts
PostInstall-WSL