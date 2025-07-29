-- math

function math.clamp(n, min, max) return (n > max and max or (n < min and min or n)) end
function math.round(n) return (n > 0 and math.floor(n + .5) or math.ceil(n - .5)) end

function math.dcos(o) return math.cos(math.rad(o)) end
function math.dsin(o) return math.sin(math.rad(o)) end

function math.lerp(a, b, t) return (a + (b - a) * t) end


-- random

random = {}
function random.shuffle() math.randomseed(os.clock()) end
function random.number(min, max, precision) return math.lerp(min, max, math.random()) end
function random.int(min, max)
	max = max or (min and 1 or 0)
	min = min or 0
	return math.random(min, max)
end
function random.bool(chance) return (random.number(100) <= chance) end


-- lambda

lambda = {}
function lambda.find(iter, condition)
	for k, v in pairs(iter) do
		if condition(v, k) then
			return v
		end
	end
	return nil
end

function lambda.foreach(iter, fun)
	for k, v in pairs(iter) do
		fun(v, k)
	end
end


-- table

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


-- other

tostr_idx_limit = 2500

function tostr(v, str, sep, eq, track)
	local str = str or '"' -- STRing (default '"')
	if type(v) == 'table' then
		return table.print(v, str, sep, eq, track)
	elseif type(v) == 'function' then
		return '(function)'
	elseif type(v) == 'string' then
		return str .. v .. str
	end
	return tostring(v)
end

function trace(v)
	return print(tostr(v))
end