# Instalación en WSL2 — Ubuntu

WSL no sustituye a las herramientas de Windows: las complementa. Hay cosas que en Linux funcionan mejor o directamente no existen en Windows.

| Herramienta | Por qué en WSL |
|---|---|
| **tcpdump** | Captura nativa, sin depender de Npcap |
| **mtr** | El `mtr` de verdad. WinMTR está abandonado desde 2015 |
| **nmap** | Los scripts NSE se comportan mejor en Linux |
| **snmpwalk** | Con las MIBs instaladas resuelve los OIDs por nombre |
| **ansible** | No corre nativo en Windows. Solo desde WSL o un bastión Linux |

## Instalación

```bash
sudo apt update
sudo apt install -y nmap tcpdump dnsutils snmp snmp-mibs-downloader \
                    iperf3 mtr-tiny jq
```

## Si no recuerdas la contraseña de sudo

No hay que recuperarla. **WSL permite entrar como root sin autenticar**: la distro es tuya y Windows ya te validó al iniciar sesión.

```powershell
# instalar sin necesitar contraseña
wsl -d Ubuntu -u root -- apt-get update
wsl -d Ubuntu -u root -- apt-get install -y nmap tcpdump dnsutils snmp iperf3 mtr-tiny jq
```

Para ponerte una contraseña nueva (`passwd` es interactivo, necesita ventana propia):

```powershell
Start-Process wsl.exe -ArgumentList @('-d','Ubuntu','-u','root','--','bash','-c','passwd TU_USUARIO; read')
```

Comprobar el estado — `P` significa contraseña definida:

```powershell
wsl -d Ubuntu -u root -- passwd -S TU_USUARIO
```

## Cuidado con ejecutar apt sin terminal interactiva

Lanzar `sudo apt install` desde un contexto sin stdin real termina en:

```
sudo: timed out
```

No es un fallo de permisos: el prompt de contraseña apareció y no había dónde escribirla. O usas la vía root de arriba, o abres una ventana de verdad.

## Las MIBs de SNMP

`snmp-mibs-downloader` es la diferencia entre esto:

```
iso.3.6.1.2.1.2.2.1.2.1 = STRING: "eth0"
```

y esto:

```
IF-MIB::ifDescr.1 = STRING: "eth0"
```

Si sigue mostrando números, descoméntalo en `/etc/snmp/snmp.conf`:

```bash
sudo sed -i 's/^mibs :/# mibs :/' /etc/snmp/snmp.conf
```

## Capturar con tcpdump y abrir en Wireshark

La combinación más práctica del conjunto: `tcpdump` escribe directo al disco de Windows y abres el fichero con doble clic.

```bash
sudo tcpdump -i eth0 -w /mnt/c/Users/TU_USUARIO/Documents/captura.pcap
```

Ventaja añadida: no depende de Npcap, así que te saltas los problemas de driver en Windows.

## Verificación

```bash
for t in nmap tcpdump dig snmpwalk iperf3 mtr jq; do
    command -v "$t" >/dev/null 2>&1 && echo "  OK     $t" || echo "  FALTA  $t"
done
```

## Nota sobre Ansible

No lo instalo aquí **a propósito**. Automatizar dispositivos de red desde un portátil que se suspende y cambia de red es frágil. Ansible debe vivir en un bastión Linux con IP estable y acceso permanente a la gestión.

Si solo quieres practicar, `sudo apt install -y ansible` y listo.
