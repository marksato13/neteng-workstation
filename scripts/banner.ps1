# ~/.ninjasec/banner.ps1  ---  Banner de arranque @Mark_NinjaSec
# Uso:  . "$HOME\.ninjasec\banner.ps1"

# La consola debe estar en UTF-8 o los bordes salen como basura
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding            = [System.Text.Encoding]::UTF8
} catch {}

$e = [char]27          # ESC  -> secuencias ANSI de color
$C1 = "$e[38;5;51m"    # cian brillante  (el nombre)
$C2 = "$e[38;5;45m"    # cian medio      (el marco)
$C3 = "$e[38;5;244m"   # gris            (datos)
$R  = "$e[0m"          # reset

$art = @'
     ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗
     ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝
     ██╔████╔██║███████║██████╔╝█████╔╝
     ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗
     ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗
     ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
'@

$box = @'
  ╔══════════════════════════════════════════════╗
  ║   @Mark_NinjaSec · Network Security & Infra   ║
  ╚══════════════════════════════════════════════╝
'@

$ip = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
       Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
       Select-Object -First 1 -ExpandProperty IPAddress)
if (-not $ip) { $ip = 'n/a' }

Write-Host ""
Write-Host "$C1$art$R"
Write-Host "$C2$box$R"
Write-Host ("$C3   {0}@{1}   ·   {2}   ·   {3}$R" -f $env:USERNAME, $env:COMPUTERNAME, $ip, (Get-Date -Format 'dd/MM/yyyy HH:mm'))
Write-Host ""
