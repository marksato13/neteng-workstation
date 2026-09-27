# Instalación en Windows

Todo lo de aquí se instala **en el ámbito del usuario** salvo donde se indique. No hace falta ser administrador excepto para Wireshark y Nmap, que instalan un driver de captura.

## 1. Lo que va con winget

```powershell
winget install --id jqlang.jq
winget install --id ISC.Bind                              # trae dig
winget install --id ar51an.iperf3
winget install --id FireDaemon.OpenSSL
winget install --id WiresharkFoundation.Wireshark         # pide UAC
winget install --id Microsoft.Sysinternals.ProcessExplorer
winget install --id Microsoft.Sysinternals.TCPView
winget install --id Microsoft.Sysinternals.PsTools
```

### Por qué las Sysinternals sueltas y no el Suite

`Microsoft.Sysinternals.Suite` falla con `Installer hash does not match`. Microsoft republica ese ZIP sin actualizar el manifiesto de winget, así que el hash nunca cuadra.

**No uses `--ignore-security-hash` para saltártelo.** Ese flag desactiva la única comprobación de integridad que tienes sobre un binario descargado de internet. Instala las piezas sueltas: van versionadas y su hash sí es correcto.

## 2. Nmap — NO lo instales con winget

```powershell
# MAL: instala la 7.80 de 2019 y degrada Npcap
winget install --id Insecure.Nmap
```

El manifiesto de `Insecure.Nmap` lleva años sin actualizar. Al instalarlo:

- Pone **Nmap 7.80** (release de 2019; la actual es 7.991)
- **Degrada Npcap de 1.88 a 0.9982**, arrastrando el driver que usa Wireshark

Npcap 0.99 con Wireshark 4.6 da problemas en captura WiFi y loopback.

**Hazlo así:**

```powershell
$dst = "$HOME\Downloads\nmap-setup.exe"
curl.exe -L -o $dst "https://nmap.org/dist/nmap-7.991-setup.exe"

# verifica la firma ANTES de ejecutarlo
Get-AuthenticodeSignature $dst | Select-Object Status, @{n='Firmante';e={$_.SignerCertificate.Subject}}
# Status debe ser "Valid" y el firmante "CN=Nmap Software LLC"
```

Doble clic y aceptar el UAC. El instalador oficial trae el Npcap actual y actualiza los dos de golpe.

> Comprueba la última versión disponible en <https://nmap.org/dist/>.

## 3. Wireshark no se añade al PATH

El instalador deja `tshark.exe` en `C:\Program Files\Wireshark` pero no toca el PATH, así que el comando no responde.

```powershell
$ws = Join-Path $env:ProgramFiles 'Wireshark'
$cur = [Environment]::GetEnvironmentVariable('Path','User')
if (($cur -split ';') -notcontains $ws) {
    [Environment]::SetEnvironmentVariable('Path', ($cur.TrimEnd(';') + ';' + $ws), 'User')
}
```

**Abre una terminal nueva** después. Las que ya estaban abiertas conservan el PATH viejo: los procesos heredan el entorno de su padre, no releen el registro.

## 4. Verificación

```powershell
$env:Path = [Environment]::GetEnvironmentVariable('Path','User') + ';' +
            [Environment]::GetEnvironmentVariable('Path','Machine')

foreach ($t in 'jq','dig','iperf3','tshark','openssl','nmap','ncat','tcpview','procexp','psping') {
    $c = Get-Command $t -ErrorAction SilentlyContinue
    if ($c) { "  OK     $t" } else { "  FALTA  $t" }
}
```

Comprobación específica de que Npcap quedó en 1.x:

```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' |
    Where-Object DisplayName -like '*Npcap*' |
    Select-Object DisplayName, DisplayVersion
```

## 5. Pendiente: tftpd64

No está en winget. Se descarga de <https://pjo2.github.io/tftpd64/>. Binario portable que hace **TFTP + DHCP + syslog** a la vez: útil para backup de configs y upgrades de IOS en switches Cisco.

Alternativa mejor a medio plazo: **Oxidized** en Docker, que versiona las configs en Git automáticamente. Ver [docs/proyectos-github.md](../docs/proyectos-github.md).
