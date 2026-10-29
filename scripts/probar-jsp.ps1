param([string]$BaseUrl = 'http://localhost:8080/jsp-app')
$ErrorActionPreference = 'Stop'
$salida = Join-Path (Split-Path $PSScriptRoot -Parent) 'docs\assets'
New-Item -ItemType Directory -Force -Path $salida | Out-Null
$resultados = [System.Collections.Generic.List[string]]::new()
function Verificar($nombre, $condicion) {
    if (!$condicion) { throw "FALLO: $nombre" }
    $resultados.Add("OK | $nombre")
}
function Enviar($sesion, $datos) {
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.AllowAutoRedirect = $false
    $handler.CookieContainer = $sesion.Cookies
    $cliente = [System.Net.Http.HttpClient]::new($handler)
    try {
        $campos = [System.Collections.Generic.Dictionary[string,string]]::new()
        foreach ($clave in $datos.Keys) { $campos.Add($clave, $datos[$clave]) }
        $contenido = [System.Net.Http.FormUrlEncodedContent]::new($campos)
        $respuesta = $cliente.PostAsync("$BaseUrl/procesar.jsp", $contenido).GetAwaiter().GetResult()
        [pscustomobject]@{ StatusCode = [int]$respuesta.StatusCode }
    } finally { $cliente.Dispose() }
}
$sesion = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
$inicio = Invoke-WebRequest "$BaseUrl/" -WebSession $sesion -SkipHttpErrorCheck
Verificar 'Formulario GET = 200' ($inicio.StatusCode -eq 200)
foreach ($metodo in @('GET','PUT','DELETE','HEAD')) {
    $r = Invoke-WebRequest "$BaseUrl/procesar.jsp" -Method $metodo -WebSession $sesion -SkipHttpErrorCheck
    Verificar "$metodo en procesar.jsp = 405 y Allow POST" ($r.StatusCode -eq 405 -and $r.Headers.Allow -contains 'POST')
}
$r = Enviar $sesion @{ nombre=' '; correo='incorrecto'; mensaje='' }
Verificar 'Datos invalidos = 400' ($r.StatusCode -eq 400)
$r = Enviar $sesion @{ nombre=('a' * 101); correo='a@ejemplo.com'; mensaje='Hola' }
Verificar 'Longitud invalida = 400' ($r.StatusCode -eq 400)
$r = Enviar $sesion @{ nombre='María Tocas'; correo='maria@ejemplo.com'; mensaje='¡Hola desde Perú!' }
Verificar 'Contacto valido = 303' ($r.StatusCode -eq 303)
$ataque = '<script>alert(1)</script>'
$r = Enviar $sesion @{ nombre=$ataque; correo='qa@ejemplo.com'; mensaje='<img src=x onerror=alert(1)>' }
Verificar 'Carga XSS admitida como texto = 303' ($r.StatusCode -eq 303)
$tabla = Invoke-WebRequest "$BaseUrl/registros.jsp" -WebSession $sesion
Verificar 'XSS escapado al mostrar nombre y mensaje' ($tabla.Content.Contains('&lt;script&gt;alert(1)&lt;/script&gt;') -and $tabla.Content.Contains('&lt;img') -and !$tabla.Content.Contains('<script>'))
Verificar 'UTF-8 conserva acentos' ($tabla.Content.Contains('María Tocas') -and $tabla.Content.Contains('¡Hola desde Perú!'))
Verificar 'Dos registros acumulados; invalidos no almacenados' (([regex]::Matches($tabla.Content, '<tr>')).Count -eq 3)
$tabla2 = Invoke-WebRequest "$BaseUrl/registros.jsp" -WebSession $sesion
Verificar 'Actualizar tabla no duplica registros' (([regex]::Matches($tabla2.Content, '<tr>')).Count -eq 3)
$otra = Invoke-WebRequest "$BaseUrl/registros.jsp" -WebSession ([Microsoft.PowerShell.Commands.WebRequestSession]::new())
Verificar 'Sesiones aisladas' ($otra.Content.Contains('Aún no hay contactos') -and !$otra.Content.Contains('María Tocas'))
$r = Invoke-WebRequest "$BaseUrl/no-existe" -SkipHttpErrorCheck
Verificar 'Ruta inexistente = 404 personalizado sin traza' ($r.StatusCode -eq 404 -and $r.Content.Contains('No se pudo completar') -and !$r.Content.Contains('Exception'))
$resultados.Insert(0, "Pruebas HTTP reales | $(Get-Date -Format o) | $BaseUrl")
$resultados | Set-Content (Join-Path $salida 'pruebas-jsp.txt') -Encoding UTF8
$tabla.Content | Set-Content (Join-Path $salida 'respuesta-tabla.html') -Encoding UTF8
$resultados
