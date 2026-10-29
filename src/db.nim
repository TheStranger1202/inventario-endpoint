# src/db.nim

import std/[db_postgres, json, strutils, os, parsecfg]
import config

proc enviarAPostgresTCP*(payloadJson: JsonNode): tuple[exito: bool, msj: string] =
  var dbHost = ""
  var dbPort = ""
  var dbUser = ""
  var dbPass = ""
  var dbName = ""

  # Cargar todo dinámicamente desde el archivo .env
  if fileExists(".env"):
    try:
      let dict = loadConfig(".env")
      dbHost = dict.getSectionValue("", "DB_HOST")
      dbPort = dict.getSectionValue("", "DB_PORT")
      dbUser = dict.getSectionValue("", "DB_USER")
      dbPass = dict.getSectionValue("", "DB_PASSWORD")
      dbName = dict.getSectionValue("", "DB_NAME")
    except Exception as e:
      return (false, "Error leyendo .env: " & e.msg)
  else:
    return (false, "Archivo .env no encontrado")

  # Validación de parámetros requeridos
  if dbHost.len == 0 or dbUser.len == 0 or dbPass.len == 0:
    return (false, "Credenciales incompletas en .env")

  # Fallback seguro para puerto y nombre de BD en caso de venir vacíos en .env
  if dbPort.len == 0: dbPort = "5432"
  if dbName.len == 0: dbName = "postgres"

  let connectionString = "host=" & dbHost & " port=" & dbPort & " dbname=" & dbName & " user=" & dbUser & " password=" & dbPass
  
  try:
    # 1. Conexión por socket TCP directo
    let db = open("", "", "", connectionString)
    defer: db.close()

    let hostname = payloadJson["hardware"]["hostname"].getStr()
    let jsonStr = $payloadJson

    # 2. Sentencia SQL con Upsert atómico
    let query = sql"""
      INSERT INTO inventario_endpoints (hostname, datos_json)
      VALUES ($1, $2::jsonb)
      ON CONFLICT (hostname)
      DO UPDATE SET 
        datos_json = EXCLUDED.datos_json,
        actualizado_el = NOW();
    """

    # 3. Inserción
    db.exec(query, hostname, jsonStr)
    return (true, "PostgreSQL TCP OK")

  except Exception as e:
    return (false, e.msg)
