# src/gui.nim

import std/strutils
import nigui
import config

# Paleta Dracula / Cyberpunk / Retro
const
  COLOR_BG      = rgb(40, 42, 54)     # Dracula Dark (#282a36)
  COLOR_TEXT    = rgb(248, 248, 242)  # Foreground Text (#f8f8f2)
  COLOR_PURPLE  = rgb(189, 147, 249)  # Cyberpunk Purple (#bd93f9)
  COLOR_CYAN    = rgb(139, 233, 253)  # Retro Cyan (#8be9fd)
  COLOR_GREEN   = rgb(80, 250, 123)   # Status Green (#50fa7b)
  COLOR_PINK    = rgb(255, 121, 198)  # Accent Pink (#ff79c6)
  COLOR_RED     = rgb(255, 85, 85)    # Dracula Red (#ff5555)

proc agregarFilaKV(parent: LayoutContainer, key: string, val: string, valColor: Color) =
  var layoutFila = newLayoutH()
  layoutFila.spacing = 10

  var lblKey = newLabel(key)
  lblKey.textColor = COLOR_CYAN
  lblKey.font = newFont("Consolas", 10, true)

  var lblVal = newLabel(val)
  lblVal.textColor = valColor
  lblVal.font = newFont("Consolas", 10, false)

  layoutFila.add(lblKey)
  layoutFila.add(lblVal)
  parent.add(layoutFila)

proc renderizarGUI*(info: EquipoInfo) =
  app.init()

  let fontHeader  = newFont("Consolas", 13, true)
  let fontSection = newFont("Consolas", 11, true)
  let fontVal     = newFont("Consolas", 10, false)

  # 1. Ventana Principal
  var ventana = newWindow("[ ENDPOINT INVENTORY // CYBER-COLLECTOR ]")
  ventana.width = 760
  ventana.height = 600
  ventana.color = COLOR_BG

  # 2. Contenedor Principal
  var layoutMain = newLayoutV()
  layoutMain.spacing = 14
  layoutMain.padding = 16
  ventana.add(layoutMain)

  # 3. Header
  var lblHeader = newLabel(" ─── [ SYSTEM METRICS & ENDPOINT AUDIT ] ─── ")
  lblHeader.textColor = COLOR_PURPLE
  lblHeader.font = fontHeader
  layoutMain.add(lblHeader)

  # 4. Sección Hardware
  var panelHardware = newLayoutV()
  panelHardware.spacing = 4

  var lblHWTitle = newLabel(">> DETECTED HARDWARE [READ-ONLY]")
  lblHWTitle.textColor = COLOR_CYAN
  lblHWTitle.font = fontSection
  panelHardware.add(lblHWTitle)

  panelHardware.agregarFilaKV(" [Hostname]   :", info.hostname, COLOR_TEXT)
  panelHardware.agregarFilaKV(" [OS Version] :", info.soNombre & " (" & info.soVersion & ")", COLOR_TEXT)
  panelHardware.agregarFilaKV(" [Hardware]   :", info.marcaModelo, COLOR_TEXT)
  panelHardware.agregarFilaKV(" [Processor]  :", info.procesador, COLOR_TEXT)
  panelHardware.agregarFilaKV(" [Memory/DSK] :", info.ramGB & " RAM | " & info.almacenamiento & " Disk", COLOR_TEXT)
  panelHardware.agregarFilaKV(" [Network]    :", "IP: " & info.direccionIP & " | MAC: " & info.direccionMAC, COLOR_TEXT)
  panelHardware.agregarFilaKV(" [Security]   :", info.antivirusEstado, COLOR_GREEN)

  layoutMain.add(panelHardware)

  # 5. Sección Formulario
  var panelForm = newLayoutV()
  panelForm.spacing = 6

  var lblFormTitle = newLabel(">> MANUAL REGISTRATION [INPUT REQUIRED]")
  lblFormTitle.textColor = COLOR_PINK
  lblFormTitle.font = fontSection
  panelForm.add(lblFormTitle)

  var inputResponsable = newTextBox()
  inputResponsable.placeholder = "Nombre del Responsable / Usuario..."
  inputResponsable.font = fontVal
  panelForm.add(inputResponsable)

  var inputDepto = newTextBox()
  inputDepto.placeholder = "Departamento / Área..."
  inputDepto.font = fontVal
  panelForm.add(inputDepto)

  var inputUbicacion = newTextBox()
  inputUbicacion.placeholder = "Ubicación física (Ej. Sede Central - Piso 3)..."
  inputUbicacion.font = fontVal
  panelForm.add(inputUbicacion)

  layoutMain.add(panelForm)

  # Indicador visual de estado
  var lblStatus = newLabel(" ")
  lblStatus.font = fontVal
  layoutMain.add(lblStatus)

  # 6. Botón de Acción
  var btnGuardar = newButton("[ EXECUTE REGISTRATION ]")
  btnGuardar.font = fontSection
  btnGuardar.textColor = COLOR_BG
  btnGuardar.backgroundColor = COLOR_GREEN

  btnGuardar.onClick = proc(event: ClickEvent) =
    if inputResponsable.text.strip().len == 0 or inputDepto.text.strip().len == 0:
      lblStatus.text = " [!] ERROR: Debe completar Responsable y Departamento."
      lblStatus.textColor = COLOR_RED
    else:
      lblStatus.text = " [OK] Registro procesado exitosamente."
      lblStatus.textColor = COLOR_GREEN
      echo "Registrando inventario de: ", inputResponsable.text

  layoutMain.add(btnGuardar)

  ventana.show()
  app.run()
