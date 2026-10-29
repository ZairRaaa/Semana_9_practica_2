$ErrorActionPreference = 'Stop'
$base = Join-Path (Split-Path $PSScriptRoot -Parent) '.runtime\tomcat'
$archivo = Join-Path $base 'tomcat.pid'
if (!(Test-Path -LiteralPath $archivo)) { throw 'No se encontro el PID de esta instancia.' }
$tomcatPid = [int](Get-Content -LiteralPath $archivo)
$proceso = Get-CimInstance Win32_Process -Filter "ProcessId=$tomcatPid"
if (!$proceso) { Write-Host 'La instancia ya esta detenida.'; return }
if ($proceso.Name -ne 'java.exe' -or !$proceso.CommandLine.Contains("-Dcatalina.base=$base")) { throw 'El PID no corresponde a esta instancia. No se detuvo ningun proceso.' }
Stop-Process -Id $tomcatPid
Write-Host 'Instancia de la practica detenida.'
