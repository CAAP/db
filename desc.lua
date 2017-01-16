#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'
local fs = require'carlos.files'

local conn = sql.connect'/db/ferre.db'

local dudosos = {}

local QRY = 'SELECT SUBSTR(desc, 1, 1) prefix, COUNT(clave) count FROM datos GROUP BY SUBSTR(desc, 1, 1)'

local letras = fd.reduce( conn.query(QRY), fd.into, {} )

QRY = "SELECT SUBSTR(desc, 1, 2) prefix FROM datos WHERE desc LIKE '%s%%' GROUP BY SUBSTR(desc, 1, 2) HAVING count(clave) < 5"

local function push(w)
    fd.reduce( conn.query(string.format("SELECT clave, desc FROM datos WHERE desc LIKE '%s%%'", w.prefix)), fd.map(function(q) return string.format('%s\t%q', math.tointeger(q.clave) or q.clave, q.desc) end), fd.into, dudosos )
end

local function contar(w)
    if w.count > 4 then
	fd.reduce( conn.query(string.format(QRY, w.prefix)), push )
    else
	push(w)
    end
end

fd.reduce(letras, contar)

fs.dump('/usr/local/tmp/dudosos.txt', table.concat(dudosos, '\n'))

