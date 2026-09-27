# Decisiones

Por qué cada herramienta y, más importante, **qué descarté y por qué**. Un inventario sin criterio es una lista de la compra.

---

## dig en lugar de nslookup

`nslookup` viene con Windows y sirve para «¿a qué IP resuelve esto?». Se queda corto en todo lo demás: no tiene `+trace` para seguir la delegación desde los root servers, muestra el SOA de forma confusa y no hace transferencias de zona con comodidad.

`dig` viene en el paquete `ISC.Bind` de winget. Ocupa unos pocos MB.

## mtr en WSL en lugar de WinMTR

WinMTR es la opción típica en Windows, pero **su último release es de 2015**. `mtr` en WSL está mantenido y da la misma información —pérdida y latencia por salto, en continuo— que es lo que de verdad identifica dónde se degrada un trayecto.

## tcpdump en WSL además de Wireshark

No es duplicar: `tcpdump` en Linux **no depende de Npcap**, así que esquiva los problemas de driver en Windows. El flujo que mejor funciona es capturar con tcpdump directamente sobre el disco de Windows y abrir el fichero en Wireshark con doble clic.

## Sysinternals sueltas, no el Suite

El paquete `Microsoft.Sysinternals.Suite` falla con `Installer hash does not match` porque Microsoft republica ese ZIP sin tocar el manifiesto de winget.

Existe `--ignore-security-hash` para saltárselo. **No lo uso.** Ese flag desactiva la única verificación de integridad sobre un binario bajado de internet; ahorrarte un minuto no compensa instalar a ciegas. Las herramientas sueltas van versionadas y su hash sí cuadra.

## Nmap desde nmap.org, no desde winget

El manifiesto `Insecure.Nmap` lleva años sin actualizarse: instala la **7.80 de 2019** y, de paso, **degrada Npcap** al 0.9982. Como Wireshark captura a través de Npcap, el daño va más allá de Nmap.

El instalador oficial está firmado por `CN=Nmap Software LLC` y trae el Npcap actual. Verificar la firma antes de ejecutarlo es un comando.

## Oxidized por delante de tftpd64

tftpd64 es lo clásico para backup de configs Cisco, y funciona. Pero deja ficheros sueltos sin histórico ni diferencias entre versiones.

**Oxidized** hace *pull* de las configuraciones y las versiona en Git. Cuando algo se rompe, un `git diff` te dice exactamente qué cambió y cuándo. Pesa ~200 MB en Docker.

Mantengo tftpd64 pendiente porque para **subir firmware** a un switch sigue haciendo falta un TFTP de verdad.

## Ansible en un bastión, no en el portátil

Un portátil se suspende, cambia de red y se apaga. Un playbook a medio ejecutar sobre dispositivos de red deja la infraestructura en un estado indefinido.

Ansible debe correr desde un host con IP estable y acceso permanente a la red de gestión. En WSL se instala en un comando si el objetivo es solo practicar.

## Terraform: todavía no

Terraform tiene sentido cuando provisionas infraestructura en cloud o FortiGates en AWS/Azure. Para equipamiento físico on-premise no aporta nada sobre Ansible. Se instalará el día que haya un caso real.

## FileZilla: descartado

WinSCP ya cubre SFTP y SCP, e integra editor remoto y sincronización de carpetas. Dos clientes para lo mismo es ruido.

---

## Lo que deliberadamente NO está

| Descartado | Motivo |
|---|---|
| **GNS3 / VirtualBox** | Al [homelab](https://github.com/marksato13/homelab). Un emulador de topologías compitiendo por 15.6 GB con el resto del entorno no rinde |
| **Wazuh / Zabbix / LibreNMS en local** | Son servidores 24/7. Un portátil que se suspende no monitoriza nada |
| **Malcolm** | Pide 16 GB dedicados. Imposible aquí |
| **WinMTR** | Abandonado desde 2015 |
| **Herramientas de pentesting ofensivo** | Este es un entorno de trabajo de red e infraestructura. El tooling ofensivo va en una VM aislada y desechable, nunca en la máquina de diario |
