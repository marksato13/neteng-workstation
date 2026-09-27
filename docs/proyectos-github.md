# Proyectos open source del sector

Clasificados por **dónde pueden ejecutarse**, no por lo buenos que son. La frontera la marca la RAM: 15.6 GB en total, con Docker reservando 8.1.

Datos de estrellas y último *push* verificados en **septiembre de 2026**. Se quedan obsoletos: si vas a apostar por uno, comprueba que sigue vivo.

---

## A. Nativo en el portátil — librerías, pesan MB

Se instalan con `pip` en un entorno virtual. Consumo irrelevante.

| Proyecto | ⭐ | Últ. push | Para qué |
|---|---:|---|---|
| [ktbyers/netmiko](https://github.com/ktbyers/netmiko) | 4 295 | 2026-09 | SSH multi-vendor. El estándar de facto |
| [napalm-automation/napalm](https://github.com/napalm-automation/napalm) | 2 507 | 2026-08 | Abstrae vendors: el mismo código sirve para Cisco, Fortinet y MikroTik |
| [nornir-automation/nornir](https://github.com/nornir-automation/nornir) | 1 628 | 2026-09 | Framework multihilo con inventario. Ansible pero en Python puro |
| [mpenning/ciscoconfparse](https://github.com/mpenning/ciscoconfparse) | 843 | 2024-11 ⚠️ | Auditar configs Cisco por lotes. Sin actividad reciente |
| [CiscoTestAutomation/genieparser](https://github.com/CiscoTestAutomation/genieparser) | 282 | 2026-09 | Convierte salida de IOS en JSON estructurado |

```bash
python -m venv .venv && .venv/Scripts/activate
pip install netmiko napalm nornir genieparser
```

**Requieren WSL** (Ansible no corre nativo en Windows):

| Proyecto | ⭐ | Últ. push |
|---|---:|---|
| [fortinet-ansible-dev/ansible-galaxy-fortios-collection](https://github.com/fortinet-ansible-dev/ansible-galaxy-fortios-collection) | 106 | 2026-08 |
| [fortinet/fortigate-terraform-deploy](https://github.com/fortinet/fortigate-terraform-deploy) | 152 | 2026-09 |

---

## B. Docker en el portátil — caben de sobra

| Proyecto | ⭐ | RAM aprox | Para qué |
|---|---:|---|---|
| [ytti/oxidized](https://github.com/ytti/oxidized) | 3 592 | ~200 MB | **Backup de configs con histórico en Git.** Sustituye a tftpd64 con ventaja |
| [prometheus/snmp_exporter](https://github.com/prometheus/snmp_exporter) | 2 177 | ~50 MB | Métricas SNMP hacia Prometheus |
| [akpw/mktxp](https://github.com/akpw/mktxp) | 1 085 | ~100 MB | Exporter Prometheus para MikroTik |
| [batfish/batfish](https://github.com/batfish/batfish) | 1 487 | ~2 GB | **Valida configs antes de aplicarlas.** Te avisa si una ACL rompe algo |
| [netbox-community/netbox](https://github.com/netbox-community/netbox) | 21 606 | ~2 GB | IPAM + DCIM. En el portátil solo para aprender |
| [ntop/ntopng](https://github.com/ntop/ntopng) | 8 209 | ~500 MB | Análisis de tráfico vía web |
| [zeek/zeek](https://github.com/zeek/zeek) | 8 008 | ~500 MB* | Convierte tráfico en logs estructurados |
| [OISF/suricata](https://github.com/OISF/suricata) | 6 673 | ~500 MB* | IDS/IPS por firmas |

**\* Solo en modo offline.** Analizar un PCAP ya capturado va perfecto en el portátil. **Captura en vivo** necesita un Linux con NIC real en modo promiscuo — eso es homelab.

```bash
# Zeek sobre un PCAP existente
docker run --rm -v "$PWD:/data" -w /data zeek/zeek:latest zeek -r captura.pcap
```

---

## C. Exigen entorno virtualizado — aquí NO caben

| Proyecto | ⭐ | Por qué no |
|---|---:|---|
| [cisagov/Malcolm](https://github.com/cisagov/Malcolm) | 2 532 | Lleva OpenSearch dentro. El proyecto pide **16 GB dedicados**; hay 15.6 en total |
| [arkime/arkime](https://github.com/arkime/arkime) | 7 498 | OpenSearch + full packet capture. Consume RAM y disco sin límite |
| [wazuh/wazuh](https://github.com/wazuh/wazuh) | 17 007 | indexer + manager + dashboard ≈ 8 GB mínimo |
| [zabbix/zabbix](https://github.com/zabbix/zabbix) | 6 416 | Servidor 24/7 con base de datos |
| [librenms/librenms](https://github.com/librenms/librenms) | 4 908 | Servidor 24/7 con base de datos |
| [khuedoan/homelab](https://github.com/khuedoan/homelab) | 9 637 | Es un cluster Kubernetes sobre bare metal |

**Malcolm merece un párrafo.** Es de la CISA y junta Zeek + Suricata + Arkime + OpenSearch en un `docker-compose`, con los dashboards ya hechos. Le das un PCAP y te devuelve el análisis. Para trabajo sobre detección de anomalías en tráfico es la pieza central — y es justo la que no entra en el portátil. Va al [homelab](https://github.com/marksato13/homelab).

---

## D. Corren en el equipo de red, no en un PC

| Proyecto | ⭐ | Dónde vive |
|---|---:|---|
| [eworm-de/routeros-scripts](https://github.com/eworm-de/routeros-scripts) | 1 866 | Dentro del MikroTik |
| [beeyev/Mikrotik-RouterOS-automatic-backup-and-update](https://github.com/beeyev/Mikrotik-RouterOS-automatic-backup-and-update) | 617 | Dentro del MikroTik |
| [theinvisible/openfortigui](https://github.com/theinvisible/openfortigui) | 530 | Cliente SSL-VPN **para Linux**. En Windows se usa FortiClient |

---

## Listas de referencia

| Proyecto | ⭐ | Últ. push |
|---|---:|---|
| [awesome-selfhosted/awesome-selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) | 322 092 | 2026-09 |
| [trimstray/the-practical-linux-hardening-guide](https://github.com/trimstray/the-practical-linux-hardening-guide) | 10 846 | 2024-11 ⚠️ |
| [networktocode/awesome-network-automation](https://github.com/networktocode/awesome-network-automation) | 2 855 | 2026-08 |
| [hegdepavankumar/Cisco-Images-for-GNS3-and-EVE-NG](https://github.com/hegdepavankumar/Cisco-Images-for-GNS3-and-EVE-NG) | 2 848 | 2025-03 |

---

## Por dónde empezar

Si tuviera que elegir tres para los próximos meses:

1. **Oxidized** — resuelve un problema real hoy (backup de configs) y es trivial de montar
2. **Batfish** — validar antes de aplicar cambia tu forma de trabajar
3. **NetBox** — cuando la red pasa de veinte dispositivos, la hoja de cálculo deja de servir
