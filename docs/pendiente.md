# Pendiente

Lo que falta, con el motivo por el que todavía no está. Sin fechas inventadas.

---

## Corto plazo

### tftpd64

No está en winget. Descarga manual desde <https://pjo2.github.io/tftpd64/>.

Binario portable que hace **TFTP + DHCP + syslog** en uno. Lo necesito el día que toque subir firmware a un switch Cisco: para eso sigue haciendo falta un TFTP de verdad, Oxidized no lo cubre.

### Oxidized en Docker

Backup automático de configs con histórico en Git. Es la mejora más rentable del inventario actual: ~200 MB y resuelve un problema que hoy hago a mano.

```bash
docker run --rm -v "$PWD/oxidized:/root/.config/oxidized" -p 8888:8888 oxidized/oxidized:latest
```

Pendiente: definir el inventario de dispositivos y las credenciales (nunca en este repo — variables de entorno o un gestor de secretos).

### Batfish

Validar configuraciones antes de aplicarlas. Cambia la forma de trabajar: pasas de «aplico y veo qué pasa» a «simulo y confirmo».

```bash
docker run --rm -p 9997:9997 -p 9996:9996 batfish/allinone
```

---

## Medio plazo

### NetBox como fuente de verdad

Cuando el inventario pasa de veinte dispositivos, la hoja de cálculo deja de reflejar la realidad. NetBox (IPAM + DCIM) es el estándar del sector.

En el portátil solo para aprender la herramienta. La instancia real va al homelab: es un servicio que debe estar disponible siempre.

### Práctica con netmiko y nornir

Las librerías están identificadas pero sin uso real todavía. Primer objetivo concreto: un script que recorra el inventario y saque `show version` + `show inventory` a un CSV.

---

## Descartado por ahora

| | |
|---|---|
| **Terraform** | Sin caso de uso real. Para on-premise no aporta sobre Ansible |
| **Ansible local** | Debe vivir en un bastión con IP estable, no en un portátil que se suspende |
| **GNS3 / VirtualBox** | Al [homelab](https://github.com/marksato13/homelab) |

---

## Mantenimiento periódico

Cosas que conviene revisar cada pocos meses:

- **Npcap** — comprobar que sigue en 1.x. Cualquier instalación de Nmap por winget lo degradaría otra vez
- **`winget upgrade --all`** — ojo con los paquetes con manifiesto desactualizado
- **Espacio en disco** — la caché de apt en WSL y las imágenes de Docker crecen sin avisar
- **Los proyectos de [proyectos-github.md](proyectos-github.md)** — los marcados con ⚠️ ya llevaban tiempo sin push
