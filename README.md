# neteng-workstation

> Entorno de trabajo documentado y reproducible para ingeniería de redes e infraestructura, sobre Windows 11 + WSL2.

Este repositorio documenta **qué herramientas tengo instaladas, por qué cada una, y cómo reinstalarlas desde cero**. No es una lista de deseos: todo lo que aparece como instalado está verificado en la máquina, con versión.

Para lo que **no cabe en un portátil** —Malcolm, Wazuh, Arkime, Zabbix server— existe un repositorio aparte: **[homelab](https://github.com/marksato13/homelab)**.

---

## Por qué existe este repo

Un ingeniero de redes reconstruye su entorno más veces de las que le gustaría: portátil nuevo, formateo, un compañero que empieza. Tener el inventario en Markdown y los comandos de instalación a mano convierte un día de trabajo en veinte minutos.

Y sirve de segunda cosa: deja constancia de **con qué trabajo y por qué lo elegí**.

---

## Máquina de referencia

| | |
|---|---|
| Equipo | HP Victus 16-d0xxx |
| CPU | Intel Core i7-11800H — 8 núcleos / 16 hilos |
| RAM | 15.6 GB |
| SO | Windows 11 Home Single Language 64-bit |
| Subsistema Linux | WSL2 — Ubuntu 26.04 LTS |
| Contenedores | Docker 29.0.1 (backend WSL2, 8.1 GB asignados) |

**La RAM es el límite real, no la CPU.** Con 15.6 GB totales y Docker reservando 8.1, cualquier stack que pida 8 GB o más se va al homelab. Esa frontera es la que organiza todo este repo.

> Windows 11 **Home** no incluye Hyper-V Manager. WSL2 y Docker funcionan (usan el hipervisor por debajo), pero para VMs completas haría falta VirtualBox o VMware.

---

## Inventario

### Windows

| Herramienta | Versión | Para qué |
|---|---|---|
| **Wireshark** | 4.6.8 | Análisis de tráfico con GUI |
| **tshark** | 4.6.8 | Lo mismo desde terminal, scriptable |
| **Npcap** | 1.88 | Driver de captura. Wireshark depende de él |
| **nmap** | 7.991 | Descubrimiento de hosts, puertos y servicios |
| **ncat** | (con nmap) | Probar puertos, banners, túneles |
| **dig** (BIND) | 9.17.12 | DNS de verdad: `+trace`, SOA, AXFR |
| **iperf3** | 3.21 | Medir ancho de banda real punto a punto |
| **jq** | 1.8.2 | Parsear el JSON de las APIs REST de FortiGate y similares |
| **OpenSSL** | 4.0.2 | CSRs, certificados de SSL-VPN, inspeccionar cadenas |
| **TCPView** | 4.19 | Qué proceso tiene abierto qué puerto |
| **Process Explorer** | 17.14 | Task Manager con esteroides |
| **PsTools** | — | `psping`, `pslist`, `psexec` |
| **OpenSSH** | (Windows) | Acceso a routers, switches y firewalls |
| **PuTTY** | 0.81 | Consola serie (cable de consola Cisco/Fortinet) |
| **WinSCP** | 6.3.6 | Configs y firmware por SCP/SFTP |
| **Tabby** | 1.0.237 | Terminal con árbol de hosts y grupos |
| **Cisco Packet Tracer** | 8.2.1 | Laboratorios de CCNA |
| **VS Code** · **Notepad++** | — | Editar configs, comparar versiones |
| **Git** · **Python 3.14** · **7-Zip** · **curl** | — | Base |

### WSL2 — Ubuntu 26.04

| Herramienta | Versión | Por qué aquí y no en Windows |
|---|---|---|
| **tcpdump** | 4.99.6 | Captura nativa, sin depender de Npcap |
| **nmap** | 7.98 | Los scripts NSE van mejor en Linux |
| **mtr** | 0.95 | El `mtr` real. En Windows no hay equivalente decente |
| **dig** | 9.20.24 | Más reciente que el de Windows |
| **snmpwalk** | 5.9.4 | Con `snmp-mibs-downloader`: resuelve OIDs por nombre |
| **iperf3** | 3.20 | Extremo Linux para pruebas |
| **jq** | 1.8.1 | Dentro de pipelines bash |

---

## Instalación desde cero

Dos ficheros, en este orden:

1. **[windows/README.md](windows/README.md)** — winget, PATH y las trampas que me encontré
2. **[wsl/README.md](wsl/README.md)** — apt en Ubuntu, incluido cómo hacerlo sin contraseña de sudo

---

## Documentación

| | |
|---|---|
| **[docs/proyectos-github.md](docs/proyectos-github.md)** | Proyectos open source del sector, clasificados por si corren aquí o exigen servidor |
| **[docs/decisiones.md](docs/decisiones.md)** | Por qué elegí cada herramienta y qué descarté |
| **[docs/pendiente.md](docs/pendiente.md)** | Lo que falta y por qué todavía no está |
| **[scripts/](scripts/)** | Scripts propios de mantenimiento del equipo |

---

## Trampas encontradas

Documentadas en detalle en `windows/README.md`. Las dos que más tiempo cuestan:

**El paquete `Insecure.Nmap` de winget está congelado en la 7.80 (2019)** y al instalarlo **degrada Npcap de 1.88 a 0.9982**. Wireshark 4.6 sobre ese driver falla en WiFi y loopback. Hay que instalar Nmap desde `nmap.org`.

**El instalador de Wireshark no añade su carpeta al PATH.** `tshark` no responde hasta que lo añades a mano.

---

## Licencia

MIT — ver [LICENSE](LICENSE).
