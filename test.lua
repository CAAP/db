#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
---[[
local conn = sql.connect'/db/inventario.db'

assert(conn.exec'ATTACH DATABASE "/db/ferre.db" AS FR')

assert(conn.exec(string.format(sql.newTable, 'faltantes', 'clave PRIMARY KEY, faltante INTEGER DEFAULT 0, obs DEFAULT ""')))
assert(conn.exec'INSERT INTO faltantes SELECT clave, faltante, obs FROM FR.faltantes')
assert(conn.exec'CREATE VIEW IF NOT EXISTS compras AS SELECT faltantes.clave, obs, proveedor FROM proveedores, faltantes WHERE faltante = 1 AND proveedores.clave = faltantes.clave')

conn = sql.connect'/db/ferre.db'
assert(conn.exec'DROP TABLE faltantes')
assert(conn.exec'DROP TABLE categorias')
assert(conn.exec'DROP TABLE cambios')
assert(conn.exec'DROP TABLE ubicacion')
--]]
--[[
conn = sql.connect'/db/updates.db'
assert(conn.exec(string.format(sql.newTable,'cambios', 'clave, campo, version INTEGER, PRIMARY KEY(clave, campo)')))

assert(conn.exec'ATTACH DATABASE "/db/ferre.db" AS FR')

assert(conn.exec'CREATE TABLE claves AS SELECT clave FROM datos')

for _,v in ipairs({'fecha', 'desc', 'u1', 'u2', 'u3', 'costol', 'faltante', 'obs', 'proveedor'}) do
assert(conn.exec(string.format('INSERT INTO cambios SELECT clave, %q, 1 FROM claves', v)))
assert(conn.exec(string.format("INSERT INTO cambios VALUES ('VERS', %q, 1)", v)))
end

assert(conn.exec'DROP TABLE claves')
--]]

