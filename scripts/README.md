# Scripts

Scripts propios de mantenimiento del equipo. Todos en ASCII puro, para que funcionen igual en PowerShell 7 y en Windows PowerShell 5.1.

---

## Auditar-Herramientas.ps1

Recorre el catálogo de herramientas de un ingeniero de redes y dice cuáles tienes y cuáles faltan. Detecta por tres vías: comando en el PATH, programa en el registro de desinstalación, y paquete dentro de WSL.

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\Auditar-Herramientas.ps1
```

Al final lista los `winget install` de lo que falta, listos para copiar.

> **Falsos negativos al ejecutarlo tras instalar algo.** Un proceso hereda el entorno de su padre, no relee el registro. Si acabas de tocar el PATH, abre una terminal nueva antes de auditar.

---

## Liberar-Espacio.ps1

Analiza carpetas de temporales y caché, enseña cuánto ocuparían y **pide confirmación antes de borrar**.

```powershell
.\Liberar-Espacio.ps1              # analiza, pregunta, borra
.\Liberar-Espacio.ps1 -SoloVer     # solo informa
.\Liberar-Espacio.ps1 -Navegadores # + caché de Edge/Chrome/Firefox
.\Liberar-Espacio.ps1 -Dev         # + caché de npm/pip/NuGet/Yarn
.\Liberar-Espacio.ps1 -Si          # sin preguntar (tareas programadas)
```

Seguros que lleva dentro:

- **Lista blanca de rutas.** Solo carpetas de temporales conocidas. Nunca toca Documentos, Escritorio ni Descargas
- **Filtro de antigüedad.** Ignora lo modificado en la última hora, que puede estar en uso
- **Archivos bloqueados.** Los salta y sigue; informa de cuántos
- **Confirmación por defecto en «no».** Hay que escribir `s` a propósito
- **Rutas excluidas** configurables en `$Excluir`

Ejemplo de salida:

```
    Temporales de usuario         1.50 GB     7897 archivos
    Informes de errores          132.2 MB        9 archivos
    Cache de miniaturas          116.9 MB       33 archivos
    Temporales de Windows               -   requiere admin
    Papelera de reciclaje          6.4 MB

    TOTAL RECUPERABLE             1.75 GB
```

Para que limpie también `C:\Windows\Temp`, el acceso directo necesita **Ejecutar como administrador**.

### Un detalle de PowerShell que cuesta encontrar

Dentro de un `Where-Object` anidado, `$_` se refiere al elemento del pipeline **interno**, no al externo. Este filtro no excluye nada:

```powershell
# MAL: $PSItem apunta a la ruta excluida, no al archivo
Get-ChildItem $ruta -Recurse -File | Where-Object {
    -not ($Excluir | Where-Object { $PSItem.FullName.StartsWith($_) })
}
```

Hay que capturar el elemento externo antes:

```powershell
# BIEN
Get-ChildItem $ruta -Recurse -File | Where-Object {
    $f = $_
    -not ($Excluir | Where-Object { $f.FullName.StartsWith($_, 'OrdinalIgnoreCase') })
}
```

Falla en silencio: el script parece funcionar y borra lo que creías proteger.

---

## banner.ps1 + banner.txt

Banner ASCII al arrancar la terminal, con usuario, host, IP y fecha.

```powershell
# en $PROFILE
. "$HOME\.ninjasec\banner.ps1"
```

Dos cosas importantes:

**Guarda el `.ps1` como UTF-8 con BOM** si lo usas en Windows PowerShell 5.1. Sin BOM lo lee como ANSI y los caracteres de bloque salen como `â–ˆ`. PowerShell 7 lo lee bien sin BOM.

**Evita `Get-NetIPAddress`** para sacar la IP: tarda ~900 ms en 5.1 y se nota en cada arranque. La consulta equivalente por .NET tarda ~2 ms.

El arte se genera en <https://patorjk.com/software/taag> (fuente `ANSI Shadow`) o con `figlet` en Linux.

---

## wsl-install-root.sh

Instala el conjunto de herramientas de red en WSL Ubuntu **sin necesitar la contraseña de sudo**, aprovechando que WSL permite entrar como root.

```powershell
$w = wsl -d Ubuntu -- wslpath -a "$(($PWD.Path) -replace '\\','/')/wsl-install-root.sh"
wsl -d Ubuntu -u root -- bash $w
```
