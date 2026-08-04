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
	
	if not content.track or #content.track == 0 then return nil end
	
	for _, track in ipairs(content.track) do
		reanim.length = math.max(#track.t, reanim.length)
		
		local frames = {}
		local anim = {
			name = track.name;
			keyframes = {};
		}
		local currentKeyframe = nil
		local previousFrame = ReanimFrame:new()
		previousFrame.layerName = anim.name
		
		if (anim.name == '_ground') then
			previousFrame.image = 'IMAGE_REANIM_GROUND'
		end
		for i, frame in ipairs(track.t) do
			if frame.i and not reanim.images[frame.i] then
				reanim.images[frame.i] = Reanim.getResource(frame.i)
			end
			
			previousFrame.x = (frame.x or previousFrame.x)
			previousFrame.y = (frame.y or previousFrame.y)
			previousFrame.image = (frame.i or previousFrame.image)
			previousFrame.alpha = (frame.a or previousFrame.alpha)
			previousFrame.xScale = (frame.sx or previousFrame.xScale)
			previousFrame.yScale = (frame.sy or previousFrame.yScale)
			previousFrame.xShear = (frame.ky or previousFrame.xShear)
			previousFrame.yShear = (frame.kx or previousFrame.yShear) -- its goofy for some reason, so invert X and Y
			if frame.f then previousFrame.active = (frame.f >= 0) end
			previousFrame.text = (frame.text or previousFrame.text)
			previousFrame.font = (frame.font or previousFrame.font)
			
			if previousFrame.active then
				if not currentKeyframe then
					currentKeyframe = { first = i ; last = i }
					table.insert(anim.keyframes, currentKeyframe)
				end
			elseif currentKeyframe then
				currentKeyframe.last = (i - 1)
				currentKeyframe = nil
			end
			
			table.insert(frames, ReanimFrame:new(previousFrame))
		end
		if currentKeyframe then currentKeyframe.last = reanim.length end
		
		table.insert(reanim.guides, anim)
		table.insert(reanim.layers, {
			name = anim.name;
			frames = frames;
		})
	end
	
	return reanim
end

local I32, F32, STRING = 0, 1, 2
function Reanim.loadBinary(path, kind) -- .reanim.compiled
	local reanim = Reanim:new(kind)
	local bytePos = 0x08
	local null = -10000
	
	local data = Cache.decompressFile(path)
	local function readByte(kind, count)
		local prevByte, count = bytePos, (count or 4)
		
		bytePos = (bytePos + count)
		local v = data:sub(prevByte + 1, bytePos)
		
		if kind == I32 then return (love.data.unpack('<i4', v))
		elseif kind == F32 then return (love.data.unpack('f', v))
		elseif kind == STRING then return v end
	end
	local function assertByte(byte, expected)
		if byte ~= expected then
			error(('Reanimation file format mismatch at 0x%08x (expected 0x%02x)'):format(bytePos, byte))
		end
	end
	
	local tracks = readByte(I32)
	reanim.fps = readByte(F32)
	
	bytePos = (bytePos + 4)
	assertByte(readByte(I32), 0x0c)
	
	local transforms = {}
	for i = 1, tracks do
		bytePos = (bytePos + 8)
		table.insert(transforms, readByte(I32))
	end
	
	for i = 1, tracks do
		local trackName, f = readByte(STRING, readByte(I32)), nil
		assertByte(readByte(I32), 0x2c)
		
		local frames = {}
		local anim = {
			name = trackName;
			keyframes = {};
		}
		local currentKeyframe = nil
		local previousFrame = ReanimFrame:new()
		previousFrame.layerName = anim.name
		
		for i = 1, transforms[i] do
			f = readByte(F32); previousFrame.x = (f == null and previousFrame.x or f)
			f = readByte(F32); previousFrame.y = (f == null and previousFrame.y or f)
			f = readByte(F32); previousFrame.yShear = (f == null and previousFrame.yShear or f)
			f = readByte(F32); previousFrame.xShear = (f == null and previousFrame.xShear or f)
			f = readByte(F32); previousFrame.xScale = (f == null and previousFrame.xScale or f)
			f = readByte(F32); previousFrame.yScale = (f == null and previousFrame.yScale or f)
			f = readByte(F32); if f ~= null then previousFrame.active = (f >= 0) end
			f = readByte(F32); previousFrame.alpha = (f == null and previousFrame.alpha or f)
			bytePos = (bytePos + 12)
			
			if previousFrame.active then
				if not currentKeyframe then
					currentKeyframe = { first = i ; last = i }
					table.insert(anim.keyframes, currentKeyframe)
				end
			elseif currentKeyframe then
				currentKeyframe.last = (i - 1)
				currentKeyframe = nil
			end
			
			table.insert(frames, ReanimFrame:new(previousFrame))
		end
		if currentKeyframe then currentKeyframe.last = transforms[i] end
		
		local lastImg, lastFont, lastText
		if (anim.name == '_ground') then
			lastImg = 'IMAGE_REANIM_GROUND'
		end
		for i = 1, transforms[i] do
			local f = readByte(STRING, readByte(I32))
			if #f > 0 then
				if not reanim.images[f] then
					reanim.images[f] = Reanim.getResource(f)
				end
				lastImg = f
			end
			local f = readByte(STRING, readByte(I32)) if #f > 0 then lastFont = f end
			local f = readByte(STRING, readByte(I32)) if #f > 0 then lastText = f end
			
			frames[i].image = lastImg
			frames[i].font = lastFont
			frames[i].text = lastText
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

function Reanim.preload(reanim, _preloaded)
	if type(reanim) == 'string' then
		return Reanim.preload(Cache.reanim(reanim), recursive)
	elseif reanim then
		local root = (not _preloaded)
		
		local _preloaded = (_preloaded or {})
		_preloaded[reanim.name] = true
		
		for _, layer in ipairs(reanim.layers) do
			for _, frame in ipairs(layer.frames) do
				frame:preload(_preloaded)
			end
		end
		
		if root then
			trace('Preloaded ' .. reanim.name)
		end
	end
end

function Reanim.getResource(key)
	return (key and (Cache.image(key:gsub('IMAGE_REANIM_', ''), 'reanim', true) or Resources.fetch(key, 'Image')))
end

function Reanim:__tostring()
	return ('Reanim(name:%s, fps:%s, length:%s)'):format(self.name, self.fps, self.length)
end

return Reanim