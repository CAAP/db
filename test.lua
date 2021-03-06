#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'
local popen = io.popen

local conn = sql.connect'personas.db'

local personas = fd.reduce(conn.query'SELECT * FROM empleados', fd.map(function(o) return o.nombre end), fd.into, {})


local function people(f)
    local conn = sql.connect(f)
    print(f, '\n')
    conn.exec'ALTER TABLE tickets ADD COLUMN nombre DEFAULT "NaP"'

end


local files = popen('ls Y20*.db', 'r')

for f in files:lines() do people(f) end

files:close()

--local conn = sql.connect'/db/inventario.db'

--[[
assert(conn.exec'DROP VIEW IF EXISTS compras')
assert(conn.exec'CREATE VIEW IF NOT EXISTS stock AS SELECT faltantes.clave, faltante, obs, proveedor FROM proveedores, faltantes WHERE proveedores.clave = faltantes.clave')

assert(conn.exec'UPDATE proveedores SET proveedor = UPPER(proveedor)')
assert(conn.exec'UPDATE proveedores SET proveedor = "X" WHERE proveedor LIKE " "')
--]]

--[[
conn = sql.connect'/db/ferre.db'

assert(conn.exec'CREATE TABLE IF NOT EXISTS tags ( id PRIMARY KEY, nombre )')
assert(conn.exec"INSERT INTO tags VALUES ('a', 'presupuesto')")
assert(conn.exec"INSERT INTO tags VALUES ('b', 'ticket')")
assert(conn.exec"INSERT INTO tags VALUES ('c', 'facturar')")
assert(conn.exec"INSERT INTO tags VALUES ('g', 'guardar')")

--[[
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

