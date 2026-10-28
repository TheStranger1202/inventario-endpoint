# src/config.nim

type
  EquipoInfo* = object
    # Campos detectados automáticamente por el sistema
    hostname*: string
    soNombre*: string
    soVersion*: string
    marcaModelo*: string
    procesador*: string
    ramGB*: string
    almacenamiento*: string
    direccionIP*: string
    direccionMAC*: string
    antivirusEstado*: string
    
    # Campos que ingresa el usuario en la GUI
    usuarioResponsable*: string
    departamento*: string
    ubicacionFisica*: string
    estadoAprobacion*: string
