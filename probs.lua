#!/usr/local/bin/lua

local sql = require'carlos.sqlite'
local fd = require'carlos.fold'

local conn = sql.connect'/db/ferre.db'

local QRY = 'SELECT desc FROM datos WHERE desc NOT LIKE "VV%"'

local uqs = {}

local function match(x)
    for w in x.desc:gmatch'(%u+)' do
	if not uqs[w] then uqs[w] = true; uqs[#uqs+1] = w end
    end
end

fd.reduce(conn.query(QRY), match)

table.sort(uqs)

print(table.concat(uqs, '\n'))
