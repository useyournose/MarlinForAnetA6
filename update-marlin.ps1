$marlinfolder = Join-path $PsscriptRoot '\Marlin\'
$configfolder = Join-path $PsscriptRoot '\Configurations\'

if (!(Test-path $marlinfolder)) {
    git submodule add https://github.com/MarlinFirmware/Marlin.git
}
if (Test-path $marlinfolder) {
    Set-Location $marlinfolder
    git checkout 2.0.x
    git pull
    git reset --hard
    $latest = git describe --tags --abbrev=0
    git checkout $latest
}

if (!(Test-path $configfolder)) {
    git submodule add https://github.com/MarlinFirmware/Configurations.git
}

if (Test-path $configfolder) {
    Set-Location $configfolder
    git checkout import-2.0.x
    git reset --hard
    git pull
    git checkout $latest
}

Copy-Item -path (join-path $configfolder 'config' 'examples' 'Anet' 'A6' '*') -destination (Join-path $marlinfolder 'Marlin' )
Set-Location $marlinfolder
git add *
git commit -m "copied config files"

## update default envs
## update platformio.ini default_envs = sanguino1284p https://stackoverflow.com/questions/22802043/powershell-ini-editing
$pfile = (join-path $marlinfolder 'platformio.ini')
$pfind = 'default_envs.*'
$preplace = 'default_envs = sanguino1284p'
$pdata = Get-Content -path $pfile | foreach-object {$_ -replace $pfind, $preplace}
if ($pdata | Select-String -pattern $preplace) {Write-Output "success"} else {Write-Output "fail"}
$pdata | Set-Content $pfile

##set language correctlyupdate language
$cfile = (join-path $marlinfolder 'Marlin' 'Configuration.h')
$cfind1 = '#define LCD_LANGUAGE.*'
$creplace1 = '#define LCD_LANGUAGE de'
$cfind2 = '//#define NOZZLE_PARK_FEATURE'
$creplace2 = '#define NOZZLE_PARK_FEATURE'
$cdata = Get-Content $cfile | Foreach-Object {$_ -replace $cfind1, $creplace1 -replace $cfind2, $creplace2}
if ($cdata | Select-String -pattern $creplace1) {Write-Output "success"} else {Write-Output "fail"}
if ($cdata | Select-String -pattern $creplace2) {Write-Output "success"} else {Write-Output "fail"}
$cdata | Set-Content $cfile

## enable Filament load unload
$acfile = (join-path $marlinfolder 'Marlin' 'Configuration_adv.h')
$acfind = '//#define ADVANCED_PAUSE_FEATURE'
$acreplace = '#define ADVANCED_PAUSE_FEATURE'
$acdata = Get-Content $acfile | ForEach-Object {$_ -replace $acfind, $acreplace}
if ($acdata | Select-String -pattern $acreplace) {Write-Output "success"} else {Write-Output "fail"}
$acdata | Set-Content $acfile


<#
dann vscode öffnen
Über die Auto Build Marlin Erweiterung das richtiger Verzeichnis öffnen und dann den Build starten und bei Erfolg Uploaden
Der Drucker mus am Strom sein!
#>