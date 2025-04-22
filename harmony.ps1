param ( [string]$option )

$AppDir = Join-Path $env:APPDATA "harmony"
$PluginDir = Join-Path $AppDir "plugins"

function Show-Usage
{
	if (Test-Path $PluginDir) {
		$pluginList = Get-ChildItem -Name $PluginDir | ForEach-Object { "`t$_" }
	} else {
		$pluginList = "`t<no plugins found>"
	}

	$usageText = @"
Usage: $(Split-Path -Leaf $PSCommandPath)
iptables wrapper for restrictive setups
    Usage: $(Split-Path -Leaf $PSCommandPath)  file...
    Usage: $(Split-Path -Leaf $PSCommandPath)  OPTION

OPTION
    -h      print this help message

PLUGINS
$pluginList
"@

	Write-Host $usageText
	exit 1
}

function Load-Plugin
{
	param ( [string]$pluginName )
	$pluginPath = Join-Path $PluginDir $pluginName

	if (Test-Path $pluginPath) {
		. $pluginPath
	} else {
		Write-Error "Plugin '$pluginName' not found in $PluginDir"
		exit 1
	}
}

switch -Regex ($option)
{
	'.*\.ps1$' {
		. $option
	}

	'-' {
		$tmpFile = [System.IO.Path]::GetTempFileName()
		$input | Out-File -Encoding utf8 $tmpFile
		. $tmpFile
		Remove-Item $tmpFile -Force
	}

	'-h' | '--help' | default {
		Show-Usage
	}
}
