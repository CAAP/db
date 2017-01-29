#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local conn = sql.connect'Y2017W03.db'

assert(conn.exec("ATTACH DATABASE 'ferre.db' AS TK"))

local QRY = 'SELECT desc FROM datos WHERE clave IN (SELECT DISTINCT(clave) FROM tickets) AND desc NOT LIKE "VV%"'

local uqs = {}

local ret = {}

local gn = utf8.char(209)

local patt = string.format('([%%u%s%s]+)', gn, '@')

local repl = string.format('[^%%u%s]([%%u%s]/)', gn, gn)

local function words(q)
    for w in q.desc:gsub(repl, ' @ '):gmatch(patt) do -- gsub(repl, at):
	if not uqs[w] then
	    uqs[w] = true
	    ret[#ret+1] = w
	end
    end
end

fd.reduce(conn.query(QRY), words)

table.sort(ret)

print(table.concat(ret, '\n'))
