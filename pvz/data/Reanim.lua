local Reanim = class('Reanim')

ReanimFrame = require 'pvz.reanim.ReanimFrame'

function Reanim:init(name, fps)
	self.fps = (fps or 12)
	self.name = name
	self.guides = {}
	self.layers = {}
	self.images = {}
	self.length = 1
	
	self.images['IMAGE_REANIM_GROUND'] = Cache.image('Ground', 'reanim')
end

function Reanim:getLayers()
	local list = {}
	lambda.foreach(self.layers, function(layer) table.insert(list, layer) end)
	return list
end
function Reanim:getImageIds()
	local list = {}
	lambda.foreach(self.images, function(_, id) table.insert(list, id) end)
	return list
end
function Reanim:getLayerNames()
	local list = {}
	lambda.foreach(self.layers, function(layer) table.insert(list, layer.name) end)
	return list
end
function Reanim:getImage(image)
	if type(image) == 'string' then
		image = image:lower():gsub('image_reanim_', '')
	end
	
	return lambda.find(self.images, function(res, name) return (res == image or name:lower():gsub('image_reanim_', '') == image) end)
end
function Reanim:getLayer(find)
	if type(find) ~= 'string' then return nil end
	
	find = find:gsub('anim_', '')
	
	return lambda.find(self.layers, function(layer) return (layer.name:gsub('anim_', '') == find) end)
end
function Reanim:getTrack(track)
	track = track:gsub('anim_', '')
	
	return (track and lambda.find(self.guides, function(anim) return (anim.name:gsub('anim_', '') == track) end) or nil)
end

function Reanim.loadXML(path, kind)
	local content = xml.twist(xml.parse(love.filesystem.read(path)))
	local reanim = Reanim:new(kind)
	reanim.fps = content.fps
	
	for _, track in ipairs(content.track) do
		reanim.length = math.max(#track.t, reanim.length)
		
		local frames = {}
		local anim = {
			name = track.name;
			first = 1;
			last = -1;
		}
		local previousFrame = ReanimFrame:new()
		previousFrame.layerName = anim.name
		
		if (anim.name == '_ground') then
			previousFrame.image = 'IMAGE_REANIM_GROUND'
		end
		for i, frame in ipairs(track.t) do
			if frame.i then
				reanim.images[frame.i] = Reanim.getResource(frame.i)
			end
			
			local active
			if frame.f then
				active = (frame.f == 0 and true or false)
				if frame.f == 0 then
					anim.first = i
				elseif frame.f == -1 then
					anim.last = (i - 1)
				end
			end
			
			previousFrame.x = (frame.x or previousFrame.x)
			previousFrame.y = (frame.y or previousFrame.y)
			previousFrame.image = (frame.i or previousFrame.image)
			previousFrame.alpha = (frame.a or previousFrame.alpha)
			previousFrame.xScale = (frame.sx or previousFrame.xScale)
			previousFrame.yScale = (frame.sy or previousFrame.yScale)
			previousFrame.xShear = (frame.ky or previousFrame.xShear)
			previousFrame.yShear = (frame.kx or previousFrame.yShear) -- its goofy for some reason, so invert X and Y
			previousFrame.active = (active == nil and previousFrame.active or active or false) -- yup !
			
			table.insert(frames, ReanimFrame:new(previousFrame))
		end
		if anim.last < anim.first then anim.last = #track.t end
		
		table.insert(reanim.guides, anim)
		table.insert(reanim.layers, {
			name = anim.name;
			frames = frames;
		})
	end
	
	return reanim
end

function Reanim.loadBinary(path, kind) -- .reanim.compiled
	local reanim = Reanim:new(kind)
	local bytePos = 0x08
	local null = -10000
	
	local data = Cache.decompressFile(path)
	local function readByte(kind, count)
		local prevByte = bytePos
		count = (count or 4)
		
		bytePos = (bytePos + count)
		local v = data:sub(prevByte + 1, prevByte + count)
		
		if kind == 'i32' then v = love.data.unpack('<i4', v)
		elseif kind == 'f32' then v = love.data.unpack('f', v)
		elseif kind == 'string' then --[[ well its already a string ]] end
		
		return v
	end
	local function throw(expected)
		error(('Reanimation file format mismatch at 0x%08x (expected 0x%02x)'):format(bytePos, expected))
	end
	
	local tracks = readByte('i32')
	reanim.fps = readByte('f32')
	
	bytePos = (bytePos + 4)
	if readByte('i32') ~= 0x0c then throw(0x0c) end
	
	local transforms = {}
	for i = 1, tracks do
		bytePos = (bytePos + 8)
		table.insert(transforms, readByte('i32'))
	end
	
	for i = 1, tracks do
		local trackName, f = readByte('string', readByte('i32')), nil
		if readByte('i32') ~= 0x2c then throw(0x2c) end
		
		local frames = {}
		local anim = {
			name = trackName;
			first = 1;
			last = -1;
		}
		local previousFrame = ReanimFrame:new()
		previousFrame.layerName = anim.name
		
		for i = 1, transforms[i] do
			f = readByte('f32'); previousFrame.x = (f == null and previousFrame.x or f)
			f = readByte('f32'); previousFrame.y = (f == null and previousFrame.y or f)
			f = readByte('f32'); previousFrame.yShear = (f == null and previousFrame.yShear or f)
			f = readByte('f32'); previousFrame.xShear = (f == null and previousFrame.xShear or f)
			f = readByte('f32'); previousFrame.xScale = (f == null and previousFrame.xScale or f)
			f = readByte('f32'); previousFrame.yScale = (f == null and previousFrame.yScale or f)
			f = readByte('f32'); previousFrame.active = (f == null and previousFrame.active or f >= 0); local active = f
			f = readByte('f32'); previousFrame.alpha = (f == null and previousFrame.alpha or f)
			bytePos = (bytePos + 12)
			
			if active ~= null then
				if active >= 0 then
					anim.first = i
				else
					anim.last = (i - 1)
				end
			end
			
			table.insert(frames, ReanimFrame:new(previousFrame))
		end
		if anim.last < anim.first then anim.last = transforms[i] end
		
		local lastImg, lastText, lastFont
		if (anim.name == '_ground') then
			lastImg = 'IMAGE_REANIM_GROUND'
		end
		for i = 1, transforms[i] do
			local img = readByte('string', readByte('i32'))
			if (#img > 0) then
				reanim.images[img] = Reanim.getResource(img)
				lastImg = img
			end
			local img = readByte('string', readByte('i32')) if (#img > 0) then lastText = text end
			local img = readByte('string', readByte('i32')) if (#img > 0) then lastFont = font end
			
			frames[i].image = lastImg
		end
		
		reanim.length = math.max(reanim.length, transforms[i])
		table.insert(reanim.guides, anim)
		table.insert(reanim.layers, {
			name = anim.name;
			frames = frames;
		})
	end
	
	return reanim
end

function Reanim.getResource(key)
	return (key and Cache.image(key:gsub('IMAGE_REANIM_', ''), 'reanim') or nil)
end

function Reanim:__tostring()
	return ('Reanim(name:%s, fps:%s, length:%s)'):format(self.name, self.fps, self.length)
end

return Reanim