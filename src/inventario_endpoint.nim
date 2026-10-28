# src/inventario_endpoint.nim

import collector
import gui

proc main() =
  # 1. Invocación al recolector atómico de hardware y red
  let datosEquipo = recolectarDatos()

  # 2. Despliegue de la interfaz gráfica estilizada
  # (Se elimina el bloque `echo` para garantizar estabilidad con --passL:-mwindows)
  renderizarGUI(datosEquipo)

when isMainModule:
  main()
