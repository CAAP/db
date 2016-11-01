#!/usr/local/bin/lua

local sql = require'carlos.sqlite'

local conn = sql.connect'/db/inventario.db'

assert(conn.exec'DROP VIEW IF EXISTS compras')
assert(conn.exec'CREATE VIEW IF NOT EXISTS stock AS SELECT faltantes.clave, faltante, obs, proveedor FROM proveedores, faltantes WHERE proveedores.clave = faltantes.clave')

assert(conn.exec'UPDATE proveedores SET proveedor = UPPER(proveedor)')
assert(conn.exec'UPDATE proveedores SET proveedor = "X" WHERE proveedor LIKE " "')

conn = sql.connect'/db/ferre.db'

assert(conn.exec'DROP VIEW IF EXISTS precios')
assert(conn.exec'CREATE VIEW IF NOT EXISTS precios AS SELECT clave, desc, fecha, u1, ROUND(prc1*costol/1e4,2) precio1, u2, ROUND(prc2*costol/1e4,2) precio2, u3, ROUND(prc3*costol/1e4,2) precio3, costol FROM datos')

--[[
local conn = sql.connect'/db/inventario.db'

assert(conn.exec'ATTACH DATABASE "/db/ferre.db" AS FR')

assert(conn.exec(string.format(sql.newTable, 'faltantes', 'clave PRIMARY KEY, faltante INTEGER DEFAULT 0, obs DEFAULT ""')))
assert(conn.exec'INSERT INTO faltantes SELECT clave, faltante, obs FROM FR.faltantes')
conn = sql.connect'/db/ferre.db'
assert(conn.exec'DROP TABLE faltantes')
assert(conn.exec'DROP TABLE categorias')
assert(conn.exec'DROP TABLE cambios')
assert(conn.exec'DROP TABLE ubicacion')
--]]

