local fd = require'carlos.fold'
local sql = require'carlos.sqlite'
local fs = require'carlos.files'

local path = 'Y2017W03.db'

local conn = sql.connect(path)
--assert( conn.exec'ATTACH DATABASE "ferre.db" AS FR' )

local QRY = 'SELECT clave FROM tickets WHERE uid IN (SELECT uid FROM tickets GROUP BY uid HAVING COUNT(clave) > 1) GROUP BY clave HAVING COUNT(clave) > 3'

local claves = fd.reduce( conn.query(QRY), fd.rejig(function(x) return true, x.clave end), fd.merge, {} )

QRY = 'SELECT uid, clave FROM tickets WHERE uid IN (SELECT uid FROM tickets GROUP BY uid HAVING COUNT(clave) > 1)'

local data = {uid={}}
local uids = data.uid

local function byuid(a)
    local uid = uids[a.uid]
    if uid then
	if claves[a.clave] then
	local b = data[uid]
	b[#b+1] = a.clave
	end
    else
	if claves[a.clave] then
	uid = #data + 1
	uids[a.uid] = uid
	data[uid] = {a.clave}
	end
    end
end

fd.reduce( conn.query(QRY), byuid )

data = fd.reduce( data, fd.filter(function(a) return (#a>1) end), fd.into, {} )

local ret, N = {}, 1
claves = {}

local function getclaves(a)
    fd.reduce(a, function(c) if not claves[c] then claves[c] = N; ret[N] = {}; N = N + 1 end end)
end

fd.reduce( data, getclaves)

local function freqs(a)
    for i=1,#a-1 do
	local ci = claves[a[i]]
	local b = ret[ci]
	for j=i+1,#a do
	    local cj = claves[a[j]]
	    local N = (b[cj] or 0) + 1
	    b[cj] = N
	    ret[cj][ci] = N
	end
    end
end

fd.reduce( data, freqs )

local function maxsum(a)
    local mx = -1
    local sm = 0
    fd.reduce(fd.keys(a), function(x) sm = sm + x; if x > mx then mx = x end end)
    a.sum = sm
    a.max = mx
end

--fd.reduce( ret, maxsum )

local probs = {}

local function logprob(a,i)
    local sum = 0
    fd.reduce(fd.keys(a), function(x) sum = sum + x end)
    fd.reduce(fd.keys(a), function(x,j) probs[#probs+1] = {i, j, math.log(x/sum,10)} end)
end

fd.reduce( ret, logprob )

table.sort(probs, function(x,y) return (x[1] < y[1]) or (x[1] == y[1] and x[2] < y[2]) end)

probs = fd.reduce(probs, fd.map(function(a) return string.format('%d\t%d\t%f', table.unpack(a)) end), fd.into, {})

fs.dump('probs.txt', table.concat(probs, '\n'))

