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

proc agregarFilaKV(parent: LayoutContainer, key: string, val: string, valColor: Color, fontKey, fontVal: Font) =
  ## Auxiliar de maquetación para filas Clave-Valor alineadas
  var layoutFila = newLayoutH()
  layoutFila.spacing = 10

  var lblKey = newLabel(key)
  lblKey.textColor = COLOR_CYAN
  lblKey.font = fontKey

  var lblVal = newLabel(val)
  lblVal.textColor = valColor
  lblVal.font = fontVal

  layoutFila.add(lblKey)
  layoutFila.add(lblVal)
  parent.add(layoutFila)

proc renderizarGUI*(info: EquipoInfo) =
  app.init()

  # Reuso eficiente de objetos Font (Evita fugas de recursos GDI en Windows)
  let fontHeader  = newFont("Consolas", 13, true)
  let fontSection = newFont("Consolas", 11, true)
  let fontKey     = newFont("Consolas", 10, true)
  let fontVal     = newFont("Consolas", 10, false)

  # 1. Ventana Principal
  var ventana = newWindow("[ ENDPOINT INVENTORY // CYBER-COLLECTOR ]")
  ventana.width = 760
  ventana.height = 580
  ventana.color = COLOR_BG

  # 2. Contenedor Principal (Vertical)
  var layoutMain = newLayoutV()
  layoutMain.spacing = 14
  layoutMain.padding = 16
  ventana.add(layoutMain)

  # 3. Banner / Header Retro
  var lblHeader = newLabel(" ─── [ SYSTEM METRICS & ENDPOINT AUDIT ] ─── ")
  lblHeader.textColor = COLOR_PURPLE
  lblHeader.font = fontHeader
  layoutMain.add(lblHeader)

  # 4. Sección Hardware (Solo Lectura)
  var panelHardware = newLayoutV()
  panelHardware.spacing = 4

  var lblHWTitle = newLabel(">> DETECTED HARDWARE [READ-ONLY]")
  lblHWTitle.textColor = COLOR_CYAN
  lblHWTitle.font = fontSection
  panelHardware.add(lblHWTitle)

  panelHardware.agregarFilaKV(" [Hostname]   :", info.hostname, COLOR_TEXT, fontKey, fontVal)
  panelHardware.agregarFilaKV(" [OS Version] :", info.soNombre & " (" & info.soVersion & ")", COLOR_TEXT, fontKey, fontVal)
  panelHardware.agregarFilaKV(" [Hardware]   :", info.marcaModelo, COLOR_TEXT, fontKey, fontVal)
  panelHardware.agregarFilaKV(" [Processor]  :", info.procesador, COLOR_TEXT, fontKey, fontVal)
  panelHardware.agregarFilaKV(" [Memory/DSK] :", info.ramGB & " RAM | " & info.almacenamiento & " Disk", COLOR_TEXT, fontKey, fontVal)
  panelHardware.agregarFilaKV(" [Network]    :", "IP: " & info.direccionIP & " | MAC: " & info.direccionMAC, COLOR_TEXT, fontKey, fontVal)
  panelHardware.agregarFilaKV(" [Security]   :", info.antivirusEstado, COLOR_GREEN, fontKey, fontVal)

  layoutMain.add(panelHardware)

  # 5. Sección Formulario Manual (Inputs)
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

  # 6. Botón de Acción con Validación Defensiva
  var btnGuardar = newButton("[ EXECUTE REGISTRATION ]")
  btnGuardar.font = fontSection
  btnGuardar.textColor = COLOR_BG
  btnGuardar.backgroundColor = COLOR_GREEN

  btnGuardar.onClick = proc(event: ClickEvent) =
    if inputResponsable.text.strip().len == 0 or inputDepto.text.strip().len == 0:
      var dlgError = newWindow("Error de Validación")
      dlgError.alert("Por favor complete los campos obligatorios: Responsable y Departamento.")
    else:
      # Lógica para procesar o guardar el inventario
      echo "Registrando inventario de: ", inputResponsable.text

  layoutMain.add(btnGuardar)

  ventana.show()
  app.run()
