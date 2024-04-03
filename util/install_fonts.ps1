$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)

$here = $MyInvocation.PSScriptRoot

$font_files = Get-ChildItem -Path $here -Recurse | Where-Object {
  $_.Extension -ilike "*.otf" -or $_.Extension -ilike "*.ttf"
}

foreach($f in $font_files) {
  $fname = $f.Name
  Write-Host -ForegroundColor Green "installing $fname..."
  $fonts.CopyHere($f.FullName)
}
