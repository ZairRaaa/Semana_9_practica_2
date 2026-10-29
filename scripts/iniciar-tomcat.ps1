param(
    [string]$TomcatHome = 'C:\Program Files\Apache Software Foundation\Tomcat 10.1',
    [int]$Puerto = 8080
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$base = Join-Path $repo '.runtime\tomcat'
if (!(Test-Path -LiteralPath (Join-Path $TomcatHome 'bin\bootstrap.jar'))) { throw 'Indica -TomcatHome con la carpeta de Tomcat 10.1.' }
$java = (Get-Command java.exe -ErrorAction Stop).Source
if (Get-NetTCPConnection -State Listen -LocalPort $Puerto -ErrorAction SilentlyContinue) { throw "El puerto $Puerto esta ocupado. Usa -Puerto 8081 o detén tu instancia anterior." }
$lib = Join-Path $repo 'jsp-app\WEB-INF\lib'
New-Item -ItemType Directory -Force -Path $lib | Out-Null
$dependencias = @{
    'jakarta.servlet.jsp.jstl-api-3.0.2.jar' = 'https://repo.maven.apache.org/maven2/jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/3.0.2/jakarta.servlet.jsp.jstl-api-3.0.2.jar'
    'jakarta.servlet.jsp.jstl-3.0.1.jar' = 'https://repo.maven.apache.org/maven2/org/glassfish/web/jakarta.servlet.jsp.jstl/3.0.1/jakarta.servlet.jsp.jstl-3.0.1.jar'
}
foreach ($archivo in $dependencias.Keys) {
    $destino = Join-Path $lib $archivo
    if (!(Test-Path -LiteralPath $destino)) { Invoke-WebRequest $dependencias[$archivo] -OutFile $destino }
}
foreach ($dir in @('conf','logs','temp','work','webapps')) { New-Item -ItemType Directory -Force -Path (Join-Path $base $dir) | Out-Null }
Copy-Item -Path (Join-Path $TomcatHome 'conf\*') -Destination (Join-Path $base 'conf') -Recurse -Force
$server = @"
<?xml version="1.0" encoding="UTF-8"?>
<Server port="-1"><Service name="Catalina">
<Connector address="127.0.0.1" port="$Puerto" protocol="HTTP/1.1" connectionTimeout="20000" maxPostSize="16384" server="Semana09" />
<Engine name="Catalina" defaultHost="localhost"><Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs" prefix="localhost_access_log" suffix=".txt" pattern="%h %t &amp;quot;%r&amp;quot; %s %b" />
</Host></Engine></Service></Server>
"@
# XML needs a literal &quot; in the access log pattern.
$server.Replace('&amp;quot;', '&quot;') | Set-Content -LiteralPath (Join-Path $base 'conf\server.xml') -Encoding UTF8
Copy-Item -LiteralPath (Join-Path $repo 'jsp-app') -Destination (Join-Path $base 'webapps') -Recurse -Force
$argumentos = @(
    "`"-Dcatalina.home=$TomcatHome`"", "`"-Dcatalina.base=$base`"",
    '"-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager"',
    "`"-Djava.util.logging.config.file=$base\conf\logging.properties`"",
    '-cp', "`"$TomcatHome\bin\bootstrap.jar;$TomcatHome\bin\tomcat-juli.jar`"",
    'org.apache.catalina.startup.Bootstrap', 'start'
)
$proceso = Start-Process -FilePath $java -ArgumentList $argumentos -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $base 'logs\console.out') -RedirectStandardError (Join-Path $base 'logs\console.err')
$proceso.Id | Set-Content (Join-Path $base 'tomcat.pid')
Write-Host "Tomcat PID: $($proceso.Id)"
Write-Host "Aplicacion: http://localhost:$Puerto/jsp-app/"
Write-Host "Logs: $base\logs"
