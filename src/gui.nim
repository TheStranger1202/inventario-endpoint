# src/gui.nim

import std/strutils
import nigui
import config

const
  COLOR_BG      = rgb(40, 42, 54)     # Dracula Dark (#282a36)
  COLOR_PANEL   = rgb(68, 71, 90)     # Panels/Containers (#44475a)
  COLOR_TEXT    = rgb(248, 248, 242)  # Foreground Text (#f8f8f2)
  COLOR_PURPLE  = rgb(189, 147, 249)  # Cyberpunk Purple (#bd93f9)
  COLOR_CYAN    = rgb(139, 233, 253)  # Retro Cyan (#8be9fd)
  COLOR_GREEN   = rgb(80, 250, 123)   # Status Green (#50fa7b)
  COLOR_PINK    = rgb(255, 121, 198)  # Accent Pink (#ff79c6)
  COLOR_RED     = rgb(255, 85, 85)    # Dracula Red (#ff5555)

proc renderizarGUI*(info: EquipoInfo) =
  app.init()
  
  # Asignación global de fuente monoespaciada segura en NiGui
  app.defaultFontFamily = "Consolas"

  # 1. Ventana Principal
  var ventana = newWindow("[ ENDPOINT INVENTORY // CYBER-COLLECTOR ]")
  ventana.width = 760
  ventana.height = 640
  ventana.color = COLOR_BG

  # 2. Contenedor Principal
  var layoutMain = newLayoutContainer(Layout_Vertical)
  layoutMain.spacing = 15
  layoutMain.padding = 20
  layoutMain.backgroundColor = COLOR_BG
  ventana.add(layoutMain)

  # 3. Header
  var lblHeader = newLabel(" ─── [ SYSTEM METRICS & ENDPOINT AUDIT ] ─── ")
  lblHeader.textColor = COLOR_PURPLE
  lblHeader.backgroundColor = COLOR_BG
  layoutMain.add(lblHeader)

  # 4. Sección Hardware (Solo Lectura)
  var panelHardware = newLayoutContainer(Layout_Vertical)
  panelHardware.spacing = 6
  panelHardware.padding = 10
  panelHardware.backgroundColor = COLOR_PANEL

  var lblHWTitle = newLabel(">> DETECTED HARDWARE [READ-ONLY]")
  lblHWTitle.textColor = COLOR_CYAN
  lblHWTitle.backgroundColor = COLOR_PANEL
  panelHardware.add(lblHWTitle)

  # Función auxiliar para filas de lectura nativas (sin fuentes externas)
  proc addMetric(parent: LayoutContainer, text: string, color: Color = COLOR_TEXT) =
    var lbl = newLabel(text)
    lbl.textColor = color
    lbl.backgroundColor = COLOR_PANEL
    parent.add(lbl)

  addMetric(panelHardware, " [Hostname]   : " & info.hostname)
  addMetric(panelHardware, " [OS Version] : " & info.soNombre & " (" & info.soVersion & ")")
  addMetric(panelHardware, " [Hardware]   : " & info.marcaModelo)
  addMetric(panelHardware, " [Processor]  : " & info.procesador)
  addMetric(panelHardware, " [Memory/DSK] : " & info.ramGB & " RAM | " & info.almacenamiento & " Disk")
  addMetric(panelHardware, " [Network]    : IP " & info.direccionIP & " | MAC " & info.direccionMAC)
  addMetric(panelHardware, " [Security]   : " & info.antivirusEstado, COLOR_GREEN)

  layoutMain.add(panelHardware)

  # 5. Sección Formulario Manual
  var panelForm = newLayoutContainer(Layout_Vertical)
  panelForm.spacing = 8
  panelForm.padding = 10
  panelForm.backgroundColor = COLOR_PANEL

  var lblFormTitle = newLabel(">> MANUAL REGISTRATION [INPUT REQUIRED]")
  lblFormTitle.textColor = COLOR_PINK
  lblFormTitle.backgroundColor = COLOR_PANEL
  panelForm.add(lblFormTitle)

  proc addInput(parent: LayoutContainer, placeholder: string): TextBox =
    var txt = newTextBox()
    txt.placeholder = placeholder
    txt.textColor = COLOR_TEXT
    txt.backgroundColor = COLOR_BG
    parent.add(txt)
    return txt

  var inputResponsable = addInput(panelForm, "Nombre del Responsable / Usuario...")
  var inputDepto = addInput(panelForm, "Departamento / Área...")
  var inputUbicacion = addInput(panelForm, "Ubicación física (Ej. Sede Central - Piso 3)...")

  layoutMain.add(panelForm)

  # Indicador de estado para validación
  var lblStatus = newLabel(" STATUS: WAITING FOR INPUT...")
  lblStatus.textColor = COLOR_CYAN
  lblStatus.backgroundColor = COLOR_BG
  layoutMain.add(lblStatus)

  # 6. Botón de Acción
  var btnGuardar = newButton("[ EXECUTE REGISTRATION ]")
  btnGuardar.textColor = COLOR_BG
  btnGuardar.backgroundColor = COLOR_GREEN

  btnGuardar.onClick = proc(event: ClickEvent) =
    if inputResponsable.text.strip().len == 0 or inputDepto.text.strip().len == 0:
      lblStatus.text = " [!] ERROR: Debe completar Responsable y Departamento."
      lblStatus.textColor = COLOR_RED
    else:
      lblStatus.text = " [OK] DATA SECURED. INVENTORY UPDATED."
      lblStatus.textColor = COLOR_GREEN
      # Opcional: Mostrar popup nativo de confirmación
      ventana.msgBox("Registro de " & inputResponsable.text & " guardado correctamente.", "CYBER-COLLECTOR")

  layoutMain.add(btnGuardar)

  ventana.show()
  app.run()
