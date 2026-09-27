# Herramientas: cómo funcionan y cómo se usan

Una guía por herramienta: **qué hace por dentro**, cuándo sacarla y comandos reales. No es una lista de flags — para eso está `--help`.

| Documento | Herramientas |
|---|---|
| [01 · Acceso a equipos](01-acceso.md) | SSH · PuTTY · WinSCP · Tabby |
| [02 · Diagnóstico de red](02-diagnostico.md) | ping · tracert · pathping · mtr · dig · netstat · arp · route · iperf3 |
| [03 · Captura y análisis](03-captura.md) | Npcap · Wireshark · tshark · tcpdump |
| [04 · Descubrimiento](04-descubrimiento.md) | nmap · ncat · psping |
| [05 · SNMP](05-snmp.md) | snmpwalk · snmpget · MIBs |
| [06 · Sistema](06-sistema.md) | TCPView · Process Explorer · PsTools |
| [07 · Datos y criptografía](07-datos-cripto.md) | jq · OpenSSL · curl |
| [08 · Automatización](08-automatizacion.md) | Python · netmiko · napalm · nornir · Ansible |
| [09 · Lo que NO está instalado](09-no-instalado.md) | Y por qué, y cómo se usaría |

---

## Dónde actúa cada herramienta

Las herramientas no se eligen por gusto: cada una mira una capa distinta. Si no sabes en qué capa está el problema, no sabes qué abrir.

```mermaid
graph TD
    L1["L1 · Física<br/>cable, señal, SFP"]
    L2["L2 · Enlace<br/>MAC, VLAN, STP"]
    L3["L3 · Red<br/>IP, rutas, ICMP"]
    L4["L4 · Transporte<br/>TCP, UDP, puertos"]
    L7["L7 · Aplicación<br/>HTTP, DNS, TLS"]

    L1 --> T1["consola serie<br/>PuTTY"]
    L2 --> T2["arp · Wireshark<br/>tcpdump"]
    L3 --> T3["ping · tracert<br/>route · mtr"]
    L4 --> T4["nmap · ncat<br/>netstat · TCPView"]
    L7 --> T5["dig · curl<br/>OpenSSL · jq"]

    style L1 fill:#2c5364,color:#fff
    style L2 fill:#2c5364,color:#fff
    style L3 fill:#203a43,color:#fff
    style L4 fill:#203a43,color:#fff
    style L7 fill:#0f2027,color:#fff
```

---

## Árbol de decisión: «no funciona»

El orden importa. Subir capa por capa evita perder media hora mirando el sitio equivocado.

```mermaid
flowchart TD
    A["Algo no funciona"] --> B{"¿Hay IP?"}
    B -->|No| C["ipconfig<br/>Get-NetIPAddress<br/>¿DHCP responde?"]
    B -->|Sí| D{"¿Pinga la<br/>puerta de enlace?"}

    D -->|No| E["arp -a<br/>¿VLAN correcta?<br/>¿cable, puerto?"]
    D -->|Sí| F{"¿Pinga una IP<br/>externa: 1.1.1.1?"}

    F -->|No| G["route print · tracert<br/>¿ruta por defecto?<br/>¿NAT, firewall?"]
    F -->|Sí| H{"¿Resuelve<br/>un dominio?"}

    H -->|No| I["dig @1.1.1.1 dominio<br/>problema de DNS"]
    H -->|Sí| J{"¿Abre el puerto?"}

    J -->|No| K["nmap -p PUERTO destino<br/>ncat -zv destino PUERTO<br/>firewall o servicio caído"]
    J -->|Sí| L{"¿Va lento o<br/>intermitente?"}

    L -->|Sí| M["mtr destino · iperf3<br/>pérdida por salto"]
    L -->|No| N["Wireshark / tcpdump<br/>mirar el paquete"]

    style A fill:#c62828,color:#fff
    style N fill:#2e7d32,color:#fff
    style M fill:#2e7d32,color:#fff
```

**La regla de oro:** captura el tráfico (paso N) **al final**, no al principio. Wireshark te dará 40 000 paquetes y ninguna pista si no sabes qué buscas.

---

## Qué herramienta para qué pregunta

| La pregunta | La herramienta |
|---|---|
| ¿Llega el paquete? | `ping` |
| ¿Por dónde va y dónde se pierde? | `tracert`, `mtr` |
| ¿Cuánto ancho de banda hay de verdad? | `iperf3` |
| ¿A qué IP resuelve esto y quién lo dice? | `dig` |
| ¿Está el puerto abierto? | `nmap`, `ncat` |
| ¿Qué hay en esta red? | `nmap -sn` |
| ¿Qué proceso tiene ese puerto abierto? | `TCPView`, `netstat` |
| ¿Qué se están diciendo exactamente? | `Wireshark`, `tcpdump` |
| ¿Cuánto tráfico pasa por esa interfaz? | `snmpwalk` |
| ¿Es válido este certificado? | `openssl s_client` |
| ¿Qué devuelve la API del firewall? | `curl` + `jq` |
| ¿Cómo aplico esto a 50 switches? | `netmiko`, `nornir` |
