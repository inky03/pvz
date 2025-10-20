-- math

function math.clamp(n, min, max) return (n > max and max or (n < min and min or n)) end
function math.round(n) return (n > 0 and math.floor(n + .5) or math.ceil(n - .5)) end
function math.wrap(n, min, max) return ((n - min) % (max - min) + min) end
function math.sign(n) return (n > 0 and 1 or (n < 0 and -1 or 0)) end
function math.within(n, min, max) return (n >= min and n < max) end

function math.dcos(o) return math.cos(math.rad(o)) end
function math.dsin(o) return math.sin(math.rad(o)) end

function math.lerp(a, b, t) return (a + (b - a) * t) end
function math.remap(n, minA, maxA, minB, maxB) return (minB + (n - minA) * ((maxB - minB) / (maxA - minA))) end

function math.eucldistance(xA, yA, xB, yB) return math.sqrt((xB - xA) ^ 2 + (yB - yA) ^ 2) end


-- string

function string.split(str, delimiter)
	local strings = {}
	while true do
		local idx = str:find(delimiter)
		if idx then
			table.insert(strings, str:sub(1, idx - 1))
			str = str:sub(idx + #delimiter)
		else
			table.insert(strings, str)
			return strings
		end
	end
end
function string.rtrim(str) local trim = str:gsub('[ \t\r]+$', '') ; return trim end
function string.ltrim(str) local trim = str:gsub('^[ \t\r]+', '') ; return trim end
function string.trim(str) return string.ltrim(string.rtrim(str)) end


-- random

random = {}
function random.shuffle() math.randomseed(os.clock()) end
function random.number(min, max, precision)
	max = max or (min and 0 or 1)
	min = min or 0
	return math.lerp(min, max, math.random())
end
function random.int(min, max)
	max = max or (min and 0 or 1)
	min = min or 0
	return math.random(min, max)
end
function random.object(...)
	local t = {...}
	if #t == 1 and type(t[1]) == 'table' then t = t[1] end -- dont gaf
	return t[random.int(1, #t)]
end
function random.pickWeighted(objects, weights)
	if #objects ~= #weights then error('Length of objects table doesn\'t match weights table') end
	if #weights == 0 then return nil end
	
	local allWeights = 0
	for i = 1, #weights do
		allWeights = (allWeights + weights[i])
	end
	
	local selection = random.number(0, allWeights)
	for i = 1, #weights do
		selection = (selection - weights[i])
		if selection <= 0 then
			return objects[i]
		end
	end
end
function random.bool(chance) return (random.number(100) <= chance) end


-- lambda

lambda = {}
function lambda.find(iter, condition)
	for k, v in pairs(iter) do
		if condition(v, k) then
			return v, k
		end
	end
	return nil, nil
end

function lambda.foreach(iter, fun)
	for k, v in pairs(iter) do
		fun(v, k)
	end
end


-- table

function table.populate(entries, val, fun)
	local tbl = {}
	for i = 1, entries do
		if type(val) == 'function' and fun ~= false then
			table.insert(tbl, val(i))
		elseif type(val) == 'table' then
			table.insert(tbl, table.copy(val))
		else
			table.insert(tbl, val)
		end
	end
	return tbl
end

function table.copy(tbl, track)
	local new = {}
	local track = (track or {})
	
	for k, v in pairs(tbl) do
		if type(v) ~= 'table' or not table.find(track, v) then
			if type(v) == 'table' then table.insert(track, v) end
			new[k] = (type(v) == 'table' and table.copy(v, track) or v)
		end
	end
	setmetatable(new, getmetatable(tbl))
	
	return new
end

function table.find(haystack, needle)
	for k, v in pairs(haystack) do
		if v == needle then
			return k
		end
	end
	return nil
end

function table.print(tbl, str, sep, eq, track)
	local str, eq, sep = (str or '"'), (eq or ' = '), (sep or ', ')
	local track = track or {}
	
	local fin, ssep = '{', ''
	if #tbl > 0 and next(tbl, #tbl) == nil then -- array
		if #tbl > tostr_idx_limit then
			return ('{... (' .. #tbl .. ' items)}')
		end
		for i, v in ipairs(tbl) do
			if table.find(track, v) then
				-- fin = (fin .. ssep .. '...')
			else
				if type(v) == 'table' then table.insert(track, v) end
				fin = (fin .. ssep .. tostr(v, str, sep, eq, track))
				ssep = sep
			end
		end
	else -- dict
		for k, v in pairs(tbl) do
			if table.find(track, v) then
				-- fin = (fin .. ssep .. '...')
			else
				if type(v) == 'table' then table.insert(track, v) end
				fin = (('%s%s[%s]%s%s'):format(fin, ssep, tostr(k, str, sep, eq, track), eq, tostr(v, str, sep, eq, track)))
				ssep = sep
			end
		end
	end
	return (fin .. '}')
end

function table.flatten(v)
	local t = {}
	local function flatten(v)
		if type(v) == 'table' and not class.isInstance(v) and not class.isClass(v) then
			for _, v in ipairs(v) do flatten(v) end
			return
		end
		table.insert(t, v)
	end
	flatten(v)
	return t
end

function table.shuffle(tbl) -- https://gist.github.com/Uradamus/10323382
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end


-- other

tostr_idx_limit = 2500

function tostr(v, str, sep, eq, track)
	local str = str or '"' -- STRing (default '"')
	if type(v) == 'table' then
		local mt = getmetatable(v)
		if mt and mt.__tostring then
			return tostring(v)
		end
		return table.print(v, str, sep, eq, track)
	elseif type(v) == 'function' then
		return '(function)'
	elseif type(v) == 'string' then
		return str .. v .. str
	end
	return tostring(v)
end

function trace(...)
	local v = {...}
	local info = debug.getinfo(2, 'Sl')
	local file = (info.source:match('@(.*)%.lua$') or info.source)
	for i, val in ipairs(v) do v[i] = tostr(val, '') end
	if #v == 0 then v = {'nil'} end
	return print(('%s:%d: %s'):format(file:gsub('[/\\]', '.'), info.currentline, table.concat(v, '\t')))
end