# src/collector.nim

import std/[json, strutils]
import config

when defined(windows):
  import std/osproc

  proc ejecutarScriptPowershell(): string =
    let psCommand = """
    $ErrorActionPreference = 'SilentlyContinue'
    
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cs = Get-CimInstance -ClassName Win32_ComputerSystem
    $cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
    $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -First 1

    $net = Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object -First 1
    $ip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $net.ifIndex -ErrorAction SilentlyContinue | Select-Object -First 1

    $av = Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntiVirusProduct -ErrorAction SilentlyContinue | Select-Object -First 1
    $avNombre = if ($av) { $av.displayName } else { "Windows Defender / Desconocido" }

    $diskGB = if ($disk) { [math]::Round($disk.Size / 1GB, 2).ToString() + " GB" } else { "No detectado" }

    [PSCustomObject]@{
      hostname       = $env:COMPUTERNAME
      soNombre       = $os.Caption
      soVersion      = $os.Version
      marcaModelo    = "$($cs.Manufacturer) $($cs.Model)"
      procesador     = $cpu.Name
      ramGB          = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2).ToString() + " GB"
      almacenamiento = $diskGB
      direccionIP    = if ($ip) { $ip.IPAddress } else { "No asignada" }
      direccionMAC   = if ($net) { $net.MacAddress } else { "No disponible" }
      antivirusEstado= $avNombre
    } | ConvertTo-Json -Compress
    """

    try:
      let cmd = "powershell -NoProfile -ExecutionPolicy Bypass -Command \"" & psCommand.replace("\"", "\\\"").replace("\n", " ") & "\""
      let (salida, exitCode) = execCmdEx(cmd)
      if exitCode == 0 and salida.strip().startsWith("{"):
        return salida.strip()
      return ""
    except Exception:
      return ""
else:
  # Mock de seguridad para permitir compilar y testear la GUI en Linux/macOS sin que rompa el build
  proc ejecutarScriptPowershell(): string =
    return "{}"

proc recolectarDatos*(): EquipoInfo =
  var info: EquipoInfo
  let jsonRaw = ejecutarScriptPowershell()

  if jsonRaw.len > 0 and jsonRaw != "{}":
    try:
      let node = parseJson(jsonRaw)
      info.hostname        = node.getOrDefault("hostname").getStr("No detectado")
      info.soNombre        = node.getOrDefault("soNombre").getStr("No detectado")
      info.soVersion       = node.getOrDefault("soVersion").getStr("No detectado")
      info.marcaModelo     = node.getOrDefault("marcaModelo").getStr("No detectado")
      info.procesador      = node.getOrDefault("procesador").getStr("No detectado")
      info.ramGB           = node.getOrDefault("ramGB").getStr("No detectado")
      info.almacenamiento  = node.getOrDefault("almacenamiento").getStr("No detectado")
      info.direccionIP     = node.getOrDefault("direccionIP").getStr("No detectado")
      info.direccionMAC    = node.getOrDefault("direccionMAC").getStr("No detectado")
      info.antivirusEstado = node.getOrDefault("antivirusEstado").getStr("No detectado")
    except JsonParsingError:
      info.hostname = "Error en formato de datos"
  else:
    info.hostname = "Error al consultar sistema / SO no compatible"

  return info
