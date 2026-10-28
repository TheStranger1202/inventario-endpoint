# 🛡️ Endpoint Inventory // Cyber-Collector

[![Build and Publish Release](https://github.com/TheStranger1202/inventario-endpoint/actions/workflows/release.yml/badge.svg)](https://github.com/TheStranger1202/inventario-endpoint/actions/workflows/release.yml)
[![Nim Version](https://img.shields.io/badge/Nim-2.0.0%2B-yellow.svg)](https://nim-lang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://github.com/TheStranger1202/inventario-endpoint/releases/latest)

Herramienta ligera y portable de auto-registro e inventario de endpoints diseñada para auditorías de infraestructura y cumplimiento de controles de seguridad de la información (**CIS Control 1**).

Construida en **Nim** con el framework nativo **NiGui**, la aplicación realiza consultas atómicas al sistema mediante clases CIM/WMI en Windows y despliega una interfaz gráfica autónoma inspirada en una estética Cyberpunk/Dracula, exportando informes estructurados en JSON sin depender de runtimes externos ni librerías DLL adicionales.

---

## ✨ Características Principales

* **Extracción Atómica $O(1)$:** Realiza consultas consolidadas vía PowerShell/CIM en un único subproceso, minimizando la latencia de análisis.
* **Interfaz Retro-Cyberpunk:** GUI basada en NiGui con tipografía monoespaciada *Consolas*, paleta Dracula y validación defensiva de entradas.
* **Persistencia JSON Directa:** Exporta automáticamente los datos recolectados e ingresados en el archivo `inventario_<HOSTNAME>.json` con marca de tiempo.
* **Standalone / Zero Dependencies:** Produce un único archivo binario `.exe` portable ideal para entornos corporativos o de alta restricción.
* **Manejo Defensivo de Errores:** Resiliente ante variaciones de permisos de usuario o adaptadores de red inactivos gracias al parseo seguro de estructuras JSON.

---

## 📦 Descarga y Ejecución (Windows)

No requiere instalación ni privilegios especiales de administrador:

1. Dirígete a la sección de [Releases Oficiales](https://github.com/TheStranger1202/inventario-endpoint/releases/latest).
2. Descarga el ejecutable binario `inventario_endpoint.exe`.
3. Ejecuta el programa, valida las métricas recolectadas, completa los datos requeridos (`Responsable` y `Departamento`) y haz clic en **`[ EXECUTE REGISTRATION ]`**.

---

## 🛠️ Compilación Local y Desarrollo (Linux Debian / Windows)

Para auditorías de código o compilación cruzada desde Linux Debian / Ubuntu:

### Prerrequisitos
* Nim 2.0+ (`choosenim`)
* GCC / Toolchain C

### Pasos de Compilación
```bash
# 1. Clonar el repositorio
git clone https://github.com/TheStranger1202/inventario-endpoint.git
cd inventario-endpoint

# 2. Instalar dependencias manifestadas
nimble install -y nigui

# 3. Compilar ejecutable optimizado para Windows
nim c -d:danger --opt:speed --passL:-mwindows -o:inventario_endpoint.exe src/inventario_endpoint.nim
```

---

## 📐 Arquitectura del Código Fuente

```text
inventario-endpoint/
├── .github/
│   └── workflows/
│       └── release.yml          # CI/CD automatizado para compilación nativa en Windows
├── src/
│   ├── config.nim               # Tipos de datos estáticos (EquipoInfo)
│   ├── collector.nim            # Recolección atómica vía CIM/WMI y parseo JSON
│   ├── gui.nim                  # Renderizado NiGui (Dracula Theme & Persistencia JSON)
│   └── inventario_endpoint.nim  # Punto de entrada y orquestador principal
├── inventario_endpoint.nimble   # Manifiesto de metadatos y dependencias
├── LICENSE                      # Licencia Abierta MIT
└── README.md                    # Documentación técnica oficial
```

---

## 📄 Licencia

Este proyecto está liberado bajo la Licencia **MIT**. Para más detalles, consulta el archivo [LICENSE](LICENSE).