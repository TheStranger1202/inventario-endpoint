# src/inventario_endpoint.nim

import collector
import gui

proc main() =
  # 1. Invocación al recolector atómico de hardware y red
  let datosEquipo = recolectarDatos()

  # Opcional: Validación preventiva en CLI
  if datosEquipo.hostname.contains("Error"):
    echo "[!] ADVERTENCIA: Fallo en la recolección WMI/CIM. Mostrando GUI con datos vacíos."

  # 2. Despliegue de la interfaz gráfica estilizada
  renderizarGUI(datosEquipo)

when isMainModule:
  main()
