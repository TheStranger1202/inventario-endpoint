import std/[db_postgres, json, strutils, os, parsecfg]
import config

# Inyección en tiempo de compilación (vía banderas -d:variable)
const
  compiledHost {.strdefine.} = ""
  compiledPort {.strdefine.} = ""
  compiledUser {.strdefine.} = ""
  compiledPass {.strdefine.} = ""
  compiledName {.strdefine.} = ""

proc enviarAPostgresTCP*(payloadJson: JsonNode): tuple[exito: bool, msj: string] =
  var dbHost = compiledHost
  var dbPort = compiledPort
  var dbUser = compiledUser
  var dbPass = compiledPass
  var dbName = compiledName

  # Fallback: Si no se inyectaron en compilación, intentar leer .env local
  if dbHost.len == 0 or dbPass.len == 0:
    if fileExists(".env"):
      try:
        let dict = loadConfig(".env")
        if dbHost.len == 0: dbHost = dict.getSectionValue("", "DB_HOST")
        if dbPort.len == 0: dbPort = dict.getSectionValue("", "DB_PORT")
        if dbUser.len == 0: dbUser = dict.getSectionValue("", "DB_USER")
        if dbPass.len == 0: dbPass = dict.getSectionValue("", "DB_PASSWORD")
        if dbName.len == 0: dbName = dict.getSectionValue("", "DB_NAME")
      except Exception as e:
        return (false, "Error leyendo .env: " & e.msg)

  # Validación de parámetros requeridos
  if dbHost.len == 0 or dbUser.len == 0 or dbPass.len == 0:
    return (false, "Credenciales no encontradas (ni compiladas ni en .env)")

  if dbPort.len == 0: dbPort = "5432"
  if dbName.len == 0: dbName = "postgres"

  let connectionString = "host=" & dbHost & " port=" & dbPort & " dbname=" & dbName & " user=" & dbUser & " password=" & dbPass
  
  try:
    let db = open("", "", "", connectionString)
    defer: db.close()

    let hostname = payloadJson["hardware"]["hostname"].getStr()
    let jsonStr = $payloadJson

    let query = sql"""
      INSERT INTO inventario_endpoints (hostname, datos_json)
      VALUES ($1, $2::jsonb)
      ON CONFLICT (hostname)
      DO UPDATE SET 
        datos_json = EXCLUDED.datos_json,
        actualizado_el = NOW();
    """

    db.exec(query, hostname, jsonStr)
    return (true, "PostgreSQL TCP OK")

  except Exception as e:
    return (false, e.msg)
