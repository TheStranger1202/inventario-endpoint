import std/[strutils, json, times]
import nigui
import config

const
  COLOR_BG      = rgb(40, 42, 54)     # Dracula Dark
  COLOR_TEXT    = rgb(248, 248, 242)  # Foreground Text
  COLOR_PURPLE  = rgb(189, 147, 249)  # Cyberpunk Purple
  COLOR_CYAN    = rgb(139, 233, 253)  # Retro Cyan
  COLOR_GREEN   = rgb(80, 250, 123)   # Status Green
  COLOR_PINK    = rgb(255, 121, 198)  # Accent Pink
  COLOR_RED     = rgb(255, 85, 85)    # Dracula Red

proc renderizarGUI*(info: EquipoInfo) =
  app.init()
  app.defaultFontFamily = "Consolas"

  var ventana = newWindow("[ ENDPOINT INVENTORY // CYBER-COLLECTOR ]")
  ventana.width = 760
  ventana.height = 680

  var layoutMain = newLayoutContainer(Layout_Vertical)
  layoutMain.widthMode = WidthMode_Fill
  layoutMain.heightMode = HeightMode_Fill
  layoutMain.spacing = 15
  layoutMain.padding = 20
  layoutMain.backgroundColor = COLOR_BG 
  ventana.add(layoutMain)

  var lblHeader = newLabel(" ─── [ SYSTEM METRICS & ENDPOINT AUDIT ] ─── ")
  lblHeader.widthMode = WidthMode_Fill
  lblHeader.textColor = COLOR_PURPLE
  lblHeader.backgroundColor = COLOR_BG
  layoutMain.add(lblHeader)

  var panelHardware = newLayoutContainer(Layout_Vertical)
  panelHardware.widthMode = WidthMode_Fill
  panelHardware.spacing = 6
  panelHardware.padding = 10
  panelHardware.backgroundColor = COLOR_BG

  var lblHWTitle = newLabel(">> DETECTED HARDWARE [READ-ONLY]")
  lblHWTitle.widthMode = WidthMode_Fill
  lblHWTitle.textColor = COLOR_CYAN
  lblHWTitle.backgroundColor = COLOR_BG
  panelHardware.add(lblHWTitle)

  proc addMetric(parent: LayoutContainer, text: string) =
    var lbl = newLabel(text)
    lbl.widthMode = WidthMode_Fill
    lbl.textColor = COLOR_TEXT
    lbl.backgroundColor = COLOR_BG
    parent.add(lbl)

  addMetric(panelHardware, " [Hostname]   : " & info.hostname)
  addMetric(panelHardware, " [OS Version] : " & info.soNombre & " (" & info.soVersion & ")")
  addMetric(panelHardware, " [Hardware]   : " & info.marcaModelo)
  addMetric(panelHardware, " [Processor]  : " & info.procesador)
  addMetric(panelHardware, " [Memory/DSK] : " & info.ramGB & " RAM | " & info.almacenamiento & " Disk")
  addMetric(panelHardware, " [Network]    : IP " & info.direccionIP & " | MAC " & info.direccionMAC)
  
  var lblSec = newLabel(" [Security]   : " & info.antivirusEstado)
  lblSec.widthMode = WidthMode_Fill
  lblSec.textColor = COLOR_GREEN
  lblSec.backgroundColor = COLOR_BG
  panelHardware.add(lblSec)

  layoutMain.add(panelHardware)

  var panelForm = newLayoutContainer(Layout_Vertical)
  panelForm.widthMode = WidthMode_Fill
  panelForm.spacing = 8
  panelForm.padding = 10
  panelForm.backgroundColor = COLOR_BG

  var lblFormTitle = newLabel(">> MANUAL REGISTRATION [INPUT REQUIRED]")
  lblFormTitle.widthMode = WidthMode_Fill
  lblFormTitle.textColor = COLOR_PINK
  lblFormTitle.backgroundColor = COLOR_BG
  panelForm.add(lblFormTitle)

  proc addInput(parent: LayoutContainer, placeholder: string): TextBox =
    var txt = newTextBox()
    txt.widthMode = WidthMode_Fill
    txt.placeholder = placeholder
    # FIX UX: Forzar fondo blanco y texto negro para garantizar lectura óptima
    txt.backgroundColor = rgb(255, 255, 255)
    txt.textColor = rgb(0, 0, 0)
    parent.add(txt)
    return txt

  var inputResponsable = addInput(panelForm, "Nombre del Responsable / Usuario...")
  var inputDepto = addInput(panelForm, "Departamento / Área...")
  var inputUbicacion = addInput(panelForm, "Ubicación física (Ej. Sede Central - Piso 3)...")

  layoutMain.add(panelForm)

  var lblStatus = newLabel(" STATUS: WAITING FOR INPUT...")
  lblStatus.widthMode = WidthMode_Fill
  lblStatus.textColor = COLOR_CYAN
  lblStatus.backgroundColor = COLOR_BG
  layoutMain.add(lblStatus)

  var btnGuardar = newButton("[ EXECUTE REGISTRATION ]")
  btnGuardar.widthMode = WidthMode_Fill
  # FIX Botón: Dejamos que Windows controle los colores del botón para evitar recuadros rotos

  btnGuardar.onClick = proc(event: ClickEvent) =
    let resp = inputResponsable.text.strip()
    let depto = inputDepto.text.strip()
    let ubi = inputUbicacion.text.strip()

    if resp.len == 0 or depto.len == 0:
      lblStatus.text = " [!] ERROR: Debe completar Responsable y Departamento."
      lblStatus.textColor = COLOR_RED
    else:
      try:
        let payload = %*{
          "timestamp": now().format("yyyy-MM-dd HH:mm:ss"),
          "hardware": {
            "hostname": info.hostname,
            "soNombre": info.soNombre,
            "soVersion": info.soVersion,
            "marcaModelo": info.marcaModelo,
            "procesador": info.procesador,
            "ramGB": info.ramGB,
            "almacenamiento": info.almacenamiento,
            "direccionIP": info.direccionIP,
            "direccionMAC": info.direccionMAC,
            "antivirusEstado": info.antivirusEstado
          },
          "asignacion": {
            "responsable": resp,
            "departamento": depto,
            "ubicacion": ubi
          }
        }
        
        let nombreArchivo = "inventario_" & info.hostname & ".json"
        writeFile(nombreArchivo, payload.pretty())
        
        lblStatus.text = " [OK] DATA SECURED & EXPORTED TO " & nombreArchivo
        lblStatus.textColor = COLOR_GREEN
      except Exception as e:
        lblStatus.text = " [!] FILESYSTEM ERROR: " & e.msg
        lblStatus.textColor = COLOR_RED

  layoutMain.add(btnGuardar)

  # FIX Diseño: Espaciador dinámico para rellenar el hueco blanco inferior con el color de fondo
  var spacer = newLabel("")
  spacer.widthMode = WidthMode_Fill
  spacer.heightMode = HeightMode_Fill
  spacer.backgroundColor = COLOR_BG
  layoutMain.add(spacer)

  ventana.show()
  app.run()
