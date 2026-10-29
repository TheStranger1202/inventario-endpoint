# Package
version       = "1.1.0"
author        = "Cyber-Collector"
description   = "Agente GUI para auto-registro de inventario de endpoints en PostgreSQL"
license       = "MIT"
srcDir        = "src"
bin           = @["inventario_endpoint"]

# Dependencies
requires "nim >= 2.0.0"
requires "nigui >= 0.2.8"
requires "db_connector"
