# Auditoria de herramientas para ingeniero de redes / infra
$ErrorActionPreference = 'SilentlyContinue'

# --- inventario de programas instalados (registro) ---
$keys = @(
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$installed = Get-ItemProperty $keys | Where-Object DisplayName | Select-Object -Expand DisplayName

# tool = @(Nombre, TipoDeteccion, Patron, WingetId, ParaQue)
#   cmd = buscar ejecutable en PATH ; app = buscar en programas instalados
$cat = [ordered]@{}

$cat['ACCESO A EQUIPOS'] = @(
  @('OpenSSH client','cmd','ssh','','SSH a routers, switches, firewalls'),
  @('PuTTY','app','PuTTY','PuTTY.PuTTY','Consola serie (cable consola Cisco/Fortinet)'),
  @('WinSCP','app','WinSCP','WinSCP.WinSCP','Copiar configs y firmware por SCP/SFTP'),
  @('Tabby','app','Tabby','Eugeny.Tabby','Terminal con arbol de hosts')
)
$cat['ANALISIS DE TRAFICO'] = @(
  @('Wireshark','app','Wireshark','WiresharkFoundation.Wireshark','Capturar y analizar paquetes'),
  @('tshark','cmd','tshark','','Wireshark por linea de comandos'),
  @('Nmap','app','Nmap','Insecure.Nmap','Descubrimiento de hosts y puertos'),
  @('Npcap','app','Npcap','','Driver de captura (lo instala Wireshark)')
)
$cat['DIAGNOSTICO DE RED'] = @(
  @('ping','cmd','ping','',''),
  @('tracert','cmd','tracert','',''),
  @('pathping','cmd','pathping','',''),
  @('nslookup','cmd','nslookup','',''),
  @('netstat','cmd','netstat','',''),
  @('arp','cmd','arp','',''),
  @('route','cmd','route','',''),
  @('dig','cmd','dig','BIND.Tools','Consultas DNS serias (SOA, AXFR, +trace)'),
  @('iperf3','cmd','iperf3','ar51an.iperf3','Medir ancho de banda real entre puntos'),
  @('WinMTR','app','WinMTR','','traceroute continuo, ver donde se pierde'),
  @('netcat','cmd','ncat','','Probar puertos, banners, tuneles')
)
$cat['SNMP Y MONITOREO'] = @(
  @('snmpwalk','cmd','snmpwalk','','Consultar OIDs de switches/APs'),
  @('Zabbix agent','app','Zabbix','','Agente para monitorizar este equipo')
)
$cat['TRANSFERENCIA / BACKUP DE CONFIGS'] = @(
  @('TFTP server','app','tftpd','','Backup de configs y upgrade de IOS'),
  @('FileZilla','app','FileZilla','TimKosse.FileZilla.Client','FTP/SFTP'),
  @('curl','cmd','curl','',''),
  @('7-Zip','app','7-Zip','7zip.7zip','Abrir firmware y bundles')
)
$cat['AUTOMATIZACION'] = @(
  @('Python','cmd','py','','Netmiko, Napalm, scripts'),
  @('Git','cmd','git','Git.Git','Versionar configuraciones'),
  @('jq','cmd','jq','jqlang.jq','Parsear JSON de APIs (FortiGate, Meraki)'),
  @('Ansible (WSL)','wsl','ansible','','Automatizar cambios en lote'),
  @('Terraform','cmd','terraform','Hashicorp.Terraform','Infra como codigo')
)
$cat['LABORATORIO'] = @(
  @('VirtualBox','app','VirtualBox','Oracle.VirtualBox','VMs de laboratorio'),
  @('VMware Workstation','app','VMware Workstation','','Alternativa a VirtualBox'),
  @('GNS3','app','GNS3','GNS3.GNS3','Emular topologias reales'),
  @('Packet Tracer','app','Packet Tracer','','Labs de Cisco (CCNA)'),
  @('WSL','cmd','wsl','','Linux para herramientas nativas')
)
$cat['UTILIDADES'] = @(
  @('VS Code','app','Visual Studio Code','Microsoft.VisualStudioCode','Editar configs y scripts'),
  @('Notepad++','app','Notepad++','Notepad++.Notepad++','Comparar configs'),
  @('Sysinternals','cmd','tcpview','Microsoft.Sysinternals.Suite','TCPView, Process Explorer, PsPing'),
  @('OpenSSL','cmd','openssl','FireDaemon.OpenSSL','Certificados para VPN y HTTPS')
)

# --- WSL: una sola llamada ---
$wslTools = @()
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    $out = wsl -d Ubuntu -- bash -lc "for t in ansible nmap tcpdump dig snmpwalk iperf3 mtr; do command -v \$t >/dev/null 2>&1 && echo \$t; done" 2>$null
    $wslTools = @($out | ForEach-Object { "$_".Trim() } | Where-Object { $_ })
}

$faltan = [System.Collections.Generic.List[object]]::new()

foreach ($c in $cat.Keys) {
    Write-Host ''
    Write-Host "  $c" -ForegroundColor Cyan
    Write-Host ('  ' + ('-' * $c.Length)) -ForegroundColor DarkCyan
    foreach ($t in $cat[$c]) {
        $nombre, $tipo, $patron, $wid, $para = $t
        $ok = $false
        $detalle = ''
        switch ($tipo) {
            'cmd' { $g = Get-Command $patron -ErrorAction SilentlyContinue
                    if ($g) { $ok = $true; $detalle = $g.Source } }
            'app' { $m = $installed | Where-Object { $_ -like "*$patron*" } | Select-Object -First 1
                    if ($m) { $ok = $true; $detalle = $m } }
            'wsl' { if ($wslTools -contains $patron) { $ok = $true; $detalle = 'en WSL Ubuntu' } }
        }
        if ($ok) {
            Write-Host ('    [OK]    {0,-20} {1}' -f $nombre, $detalle) -ForegroundColor Green
        } else {
            Write-Host ('    [FALTA] {0,-20} {1}' -f $nombre, $para) -ForegroundColor Yellow
            $faltan.Add([pscustomobject]@{ Nombre=$nombre; Cat=$c; Winget=$wid; Para=$para })
        }
    }
}

Write-Host ''
Write-Host '  ================================================' -ForegroundColor White
Write-Host ("  FALTAN {0} herramientas" -f $faltan.Count) -ForegroundColor White
Write-Host '  ================================================' -ForegroundColor White
Write-Host ''
Write-Host '  Instalables con winget:' -ForegroundColor Cyan
$faltan | Where-Object Winget | ForEach-Object {
    Write-Host ('    winget install --id {0,-38} # {1}' -f $_.Winget, $_.Nombre) -ForegroundColor Gray
}
Write-Host ''
Write-Host '  Sin winget (descarga manual o apt en WSL):' -ForegroundColor Cyan
$faltan | Where-Object { -not $_.Winget } | ForEach-Object {
    Write-Host ('    {0,-22} {1}' -f $_.Nombre, $_.Para) -ForegroundColor Gray
}
Write-Host ''
