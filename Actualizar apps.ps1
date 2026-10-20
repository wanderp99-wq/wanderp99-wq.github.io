# Vuelve a armar dashboard\index.html y cuadre\index.html desde los archivos de Descargas.
# Uso: clic derecho > "Ejecutar con PowerShell". Después suba a GitHub las carpetas dashboard y cuadre.
$descargas = Join-Path $env:USERPROFILE 'Downloads'
$aqui = Split-Path -Parent $MyInvocation.MyCommand.Path
$utf = New-Object Text.UTF8Encoding $false
$apps = @(
  @{ carpeta = 'dashboard'; archivo = 'Dashboard Administracion V1.0.html'; color = '#FF4000' },
  @{ carpeta = 'cuadre';    archivo = 'CCPV3.2.6.html';                     color = '#1e293b' }
)
foreach ($a in $apps) {
  $origen = Join-Path $descargas $a.archivo
  if (-not (Test-Path $origen)) { Write-Host "No encontré $origen" -ForegroundColor Red; continue }
  $h = [IO.File]::ReadAllText($origen)
  $v = '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
  $i = $h.IndexOf($v)
  $j = $h.LastIndexOf('</body>')
  if ($i -lt 0 -or $j -lt 0) { Write-Host "$($a.archivo): no tiene el formato esperado" -ForegroundColor Red; continue }
  # Primero el final (para no mover la posición del principio)
  $h = $h.Insert($j, "<script>if ('serviceWorker' in navigator) navigator.serviceWorker.register('sw.js').catch(() => {});</script>`n")
  $h = $h.Insert($i + $v.Length, "`n    <link rel=`"manifest`" href=`"manifest.webmanifest`">`n    <meta name=`"theme-color`" content=`"$($a.color)`">`n    <link rel=`"apple-touch-icon`" href=`"iconos/icon-192.png`">")
  [IO.File]::WriteAllText((Join-Path $aqui "$($a.carpeta)\index.html"), $h, $utf)
  # Nueva versión del caché, para que los teléfonos tomen la página nueva
  $sw = Join-Path $aqui "$($a.carpeta)\sw.js"
  $t = [IO.File]::ReadAllText($sw)
  $t = [regex]::Replace($t, "const CACHE = '[^']+';", "const CACHE = '$($a.carpeta)-" + (Get-Date -Format 'yyyyMMddHHmm') + "';")
  [IO.File]::WriteAllText($sw, $t, $utf)
  Write-Host "$($a.carpeta): actualizado desde $($a.archivo)" -ForegroundColor Green
}
Read-Host 'Listo. Presione Enter para cerrar'
