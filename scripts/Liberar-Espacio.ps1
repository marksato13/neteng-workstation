<#
    Liberar-Espacio.ps1
    Limpia archivos temporales y muestra cuanto espacio se recupera.

    SEGUROS:
      - Siempre ensena primero que va a borrar y pide confirmacion (salvo -Si).
      - Solo borra en carpetas de temporales/cache conocidas. Nunca toca
        Documentos, Escritorio, Descargas ni nada personal.
      - Ignora archivos modificados en la ultima hora (pueden estar en uso).
      - Si un archivo esta bloqueado, lo salta sin romper nada.

    Uso:
      .\Liberar-Espacio.ps1                 solo lo seguro, pregunta antes
      .\Liberar-Espacio.ps1 -Navegadores    incluye cache de Chrome/Edge/Firefox
      .\Liberar-Espacio.ps1 -Dev            incluye cache de npm/pip/nuget
      .\Liberar-Espacio.ps1 -SoloVer        no borra nada, solo informa
      .\Liberar-Espacio.ps1 -Si             no pregunta (para tareas programadas)
#>

[CmdletBinding()]
param(
    [switch]$Navegadores,
    [switch]$Dev,
    [switch]$SoloVer,
    [switch]$Si
)

$ErrorActionPreference = 'SilentlyContinue'
$MinEdadHoras = 1     # no tocar lo recien creado

# Rutas que NUNCA se tocan aunque caigan dentro de un objetivo
$Excluir = @(
    (Join-Path $env:TEMP 'claude')        # sesiones de Claude Code en curso
)

function Es-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $id).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Fmt-Tam($bytes) {
    if ($bytes -ge 1GB) { '{0,7:N2} GB' -f ($bytes / 1GB) }
    elseif ($bytes -ge 1MB) { '{0,7:N1} MB' -f ($bytes / 1MB) }
    elseif ($bytes -ge 1KB) { '{0,7:N0} KB' -f ($bytes / 1KB) }
    else { '{0,7} B ' -f $bytes }
}

function Libre-En-C {
    (Get-PSDrive C).Free
}

# --------------------------------------------------------------- objetivos

$admin = Es-Admin

$objetivos = [System.Collections.Generic.List[object]]::new()

function Add-Objetivo($nombre, $ruta, $necesitaAdmin = $false) {
    if (-not (Test-Path $ruta)) { return }
    if ($necesitaAdmin -and -not $admin) {
        $objetivos.Add([pscustomobject]@{
            Nombre = $nombre; Ruta = $ruta; Bytes = 0; Archivos = 0; Saltado = 'requiere admin'
        })
        return
    }
    $objetivos.Add([pscustomobject]@{
        Nombre = $nombre; Ruta = $ruta; Bytes = 0; Archivos = 0; Saltado = $null
    })
}

Add-Objetivo 'Temporales de usuario'   $env:TEMP
Add-Objetivo 'Temporales de Windows'   "$env:SystemRoot\Temp" $true
Add-Objetivo 'Informes de errores'     "$env:LOCALAPPDATA\CrashDumps"
Add-Objetivo 'Windows Error Reporting' "$env:LOCALAPPDATA\Microsoft\Windows\WER"
Add-Objetivo 'Cache de miniaturas'     "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
Add-Objetivo 'Entrega optimizada'      "$env:SystemRoot\SoftwareDistribution\DeliveryOptimization" $true

if ($Navegadores) {
    Add-Objetivo 'Cache Edge'    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
    Add-Objetivo 'Cache Chrome'  "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
    Add-Objetivo 'Cache Firefox' "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"
}

if ($Dev) {
    Add-Objetivo 'Cache npm'    "$env:LOCALAPPDATA\npm-cache"
    Add-Objetivo 'Cache pip'    "$env:LOCALAPPDATA\pip\Cache"
    Add-Objetivo 'Cache NuGet'  "$env:USERPROFILE\.nuget\packages"
    Add-Objetivo 'Cache Yarn'   "$env:LOCALAPPDATA\Yarn\Cache"
}

# ----------------------------------------------------------------- analisis

Write-Host ''
Write-Host '  LIBERAR ESPACIO' -ForegroundColor Cyan
Write-Host '  ---------------' -ForegroundColor Cyan
if (-not $admin) {
    Write-Host '  (sin permisos de admin: algunas carpetas se saltan)' -ForegroundColor DarkYellow
}
Write-Host ''
Write-Host '  Analizando...' -ForegroundColor DarkGray

$limite = (Get-Date).AddHours(-$MinEdadHoras)
$aBorrar = @{}

foreach ($o in $objetivos) {
    if ($o.Saltado) { continue }

    $files = Get-ChildItem -LiteralPath $o.Ruta -Recurse -File -Force |
             Where-Object {
                 # OJO: dentro del Where-Object anidado, $_ es la ruta excluida,
                 # no el archivo. Hay que capturarlo antes.
                 $f = $_
                 $f.LastWriteTime -lt $limite -and
                 -not ($Excluir | Where-Object { $f.FullName.StartsWith($_, 'OrdinalIgnoreCase') })
             }

    $aBorrar[$o.Nombre] = $files
    $o.Archivos = @($files).Count
    $o.Bytes = ($files | Measure-Object Length -Sum).Sum
    if (-not $o.Bytes) { $o.Bytes = 0 }
}

# Papelera aparte: se mide con su propio API
$papelera = 0
try {
    $shell = New-Object -ComObject Shell.Application
    $papelera = ($shell.NameSpace(0xA).Items() | Measure-Object Size -Sum).Sum
    if (-not $papelera) { $papelera = 0 }
} catch {}

# ------------------------------------------------------------------ informe

Write-Host ''
$objetivos | Sort-Object Bytes -Descending | ForEach-Object {
    if ($_.Saltado) {
        Write-Host ('    {0,-26} {1,10}   {2}' -f $_.Nombre, '-', $_.Saltado) -ForegroundColor DarkGray
    } else {
        $color = if ($_.Bytes -gt 100MB) { 'Yellow' } elseif ($_.Bytes -gt 0) { 'Gray' } else { 'DarkGray' }
        Write-Host ('    {0,-26} {1}   {2,6} archivos' -f $_.Nombre, (Fmt-Tam $_.Bytes), $_.Archivos) -ForegroundColor $color
    }
}
if ($papelera -gt 0) {
    Write-Host ('    {0,-26} {1}' -f 'Papelera de reciclaje', (Fmt-Tam $papelera)) -ForegroundColor Gray
}

$total = ($objetivos | Measure-Object Bytes -Sum).Sum + $papelera
Write-Host ''
Write-Host ('    {0,-26} {1}' -f 'TOTAL RECUPERABLE', (Fmt-Tam $total)) -ForegroundColor Green
Write-Host ('    {0,-26} {1}' -f 'Libre ahora en C:', (Fmt-Tam (Libre-En-C))) -ForegroundColor DarkGray
Write-Host ''

if ($SoloVer) {
    Write-Host '  Modo -SoloVer: no se ha borrado nada.' -ForegroundColor Cyan
    Write-Host ''
    if (-not $Si) { Read-Host '  Pulsa Enter para cerrar' | Out-Null }
    return
}

if ($total -eq 0) {
    Write-Host '  No hay nada que limpiar.' -ForegroundColor Green
    Write-Host ''
    if (-not $Si) { Read-Host '  Pulsa Enter para cerrar' | Out-Null }
    return
}

# --------------------------------------------------------------- confirmar

if (-not $Si) {
    Write-Host '  Se borraran los archivos listados arriba.' -ForegroundColor Yellow
    Write-Host '  No se toca Documentos, Escritorio ni Descargas.' -ForegroundColor DarkGray
    Write-Host ''
    $r = Read-Host '  Continuar? (s/N)'
    if ($r -notmatch '^[sSyY]') {
        Write-Host ''
        Write-Host '  Cancelado. No se ha borrado nada.' -ForegroundColor Cyan
        Write-Host ''
        Read-Host '  Pulsa Enter para cerrar' | Out-Null
        return
    }
}

# ----------------------------------------------------------------- borrado

$antes = Libre-En-C
$borrados = 0
$bloqueados = 0

Write-Host ''
foreach ($o in $objetivos) {
    if ($o.Saltado -or $o.Archivos -eq 0) { continue }
    Write-Host ('    limpiando {0}...' -f $o.Nombre) -ForegroundColor DarkGray
    foreach ($f in $aBorrar[$o.Nombre]) {
        try {
            [System.IO.File]::Delete($f.FullName)
            $borrados++
        } catch {
            $bloqueados++
        }
    }
    # carpetas que quedaron vacias
    Get-ChildItem -LiteralPath $o.Ruta -Recurse -Directory -Force |
        Sort-Object { $_.FullName.Length } -Descending |
        Where-Object { -not (Get-ChildItem -LiteralPath $_.FullName -Force) } |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }
}

if ($papelera -gt 0) {
    Write-Host '    vaciando papelera...' -ForegroundColor DarkGray
    Clear-RecycleBin -Force -Confirm:$false
}

$liberado = (Libre-En-C) - $antes

Write-Host ''
Write-Host ('    Archivos borrados : {0:N0}' -f $borrados) -ForegroundColor Green
if ($bloqueados -gt 0) {
    Write-Host ('    En uso, saltados  : {0:N0}' -f $bloqueados) -ForegroundColor DarkYellow
}
Write-Host ('    Espacio liberado  : {0}' -f (Fmt-Tam ([math]::Max($liberado, 0)))) -ForegroundColor Green
Write-Host ('    Libre en C: ahora : {0}' -f (Fmt-Tam (Libre-En-C))) -ForegroundColor Green
Write-Host ''

if (-not $Si) { Read-Host '  Pulsa Enter para cerrar' | Out-Null }
