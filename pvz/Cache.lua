local deflate = require 'lib.deflate.deflatelua'
local gif = require 'lib.gifload'

local Cache = {
	cached = {
		images = {}; -- file type
		sounds = {};
		shaders = {};
		
		font = {}; -- data type
		reanim = {};
		
		levels = {}; -- module
		entities = {};
	}
}

local cached = Cache.cached

function Cache.module(path)
	if cached.entities[path] then
		return cached.entities[path]
	end
	
	local success, result = pcall(require, path)
	
	if success then
		cached.entities[path] = result
		return result
	else
		if result:find('module \'') then
			trace('Module ' .. path .. ' not found')
		else
			trace('Module ' .. path .. ' had errors:\n' .. result)
		end
		return nil
	end
end

function Cache.image(path, folder, eval, maskPath)
	if path == nil then return nil end
	
	local img
	local key = path:lower()
	local folder = (folder and folder .. '/' or '')
	if not cached.images[key] then
		local fpathMaskPng, fpathMaskJpg = Cache.main(folder .. (maskPath or path .. '_') .. '.png'), Cache.main(folder .. (maskPath or path .. '_') .. '.jpg')
		local fpathPng, fpathJpg = Cache.main(folder .. path .. '.png'), Cache.main(folder .. path .. '.jpg')
		local fpath = (
			(love.filesystem.getInfo(fpathPng) and fpathPng) or
			(love.filesystem.getInfo(fpathJpg) and fpathJpg)
		)
		local fpathMask = (
			(love.filesystem.getInfo(fpathMaskPng) and fpathMaskPng) or
			(love.filesystem.getInfo(fpathMaskJpg) and fpathMaskJpg)
		)
		if fpath then
			if fpathMask then
				local image = love.image.newImageData(fpath)
				local mask = love.image.newImageData(fpathMask)
				
				image:mapPixel(function(x, y, r, g, b)
					local a = mask:getPixel(x, y)
					return r, g, b, a
				end)
				
				img = love.graphics.newImage(image, {mipmaps = true})
				goto loaded
			else
				img = love.graphics.newImage(fpath, {mipmaps = true})
				goto loaded
			end
		end
		
		local fpathPngAlpha = Cache.main(folder .. '_' .. path .. '.png')
		if love.filesystem.getInfo(fpathPngAlpha) then
			local png = love.image.newImageData(fpathPngAlpha)
			
			png:mapPixel(function(x, y, r, g, b) return 1, 1, 1, r end)
			
			img = love.graphics.newImage(png, {mipmaps = true})
			goto loaded
		end
		
		local fpathGifAlpha = Cache.main(folder .. '_' .. path .. '.gif')
		if love.filesystem.getInfo(fpathGifAlpha) then
			local gif = Cache.loadGifFile(fpathGifAlpha, 1).imgs[3]
			
			gif:mapPixel(function(x, y, r, g, b) return 1, 1, 1, r end)
			
			img = love.graphics.newImage(gif, {mipmaps = true})
			goto loaded
		end
		
		if eval then return nil end
		trace('Resource for ' .. folder .. path .. ' doesn\'t exist')
		return Cache.unknownTexture
	else
		return cached.images[key]
	end
	
	::loaded::
	cached.images[key] = img
	img:setMipmapFilter('linear', .75)
	return img
end

function Cache.sound(snd)
	local key = snd:lower()
	if not cached.sounds[key] then
		local fpathOgg = Cache.main('sounds/' .. snd .. '.ogg')
		local fpath = (
			(love.filesystem.getInfo(fpathOgg) and fpathOgg)
		)
		if fpath then
			cached.sounds[key] = love.audio.newSource(fpath, 'static')
		else
			trace('Resource for ' .. snd .. ' doesn\'t exist')
		end
	end
	
	return cached.sounds[key]
end

function Cache.reanim(kind, folder)
	if kind == nil then return nil end
	
	local t = os.clock()
	local key = kind:lower()
	if not cached.reanim[key] then
		local path = (folder and (folder .. '/' .. kind) or ('compiled/reanim/' .. kind))
		local fpathCompiled = Cache.main(path .. '.reanim.compiled')
		local fpath = Cache.main(path .. '.reanim')
		local format = ''
		
		if love.filesystem.getInfo(fpath) then
			format = 'XML'
			cached.reanim[key] = Reanim.loadXML(fpath, kind)
		elseif love.filesystem.getInfo(fpathCompiled) then
			format = 'Binary'
			cached.reanim[key] = Reanim.loadBinary(fpathCompiled, kind)
		else
			trace('Resource for ' .. fpath .. ' doesn\'t exist')
			return Reanim:new()
		end
		trace(('%s Reanimation (%s) (%.2fms)'):format(kind, format, (os.clock() - t) * 1000))
	end
	
	return cached.reanim[key]
end

function Cache.font(name, folder)
	if name == nil then return nil end
	
	local key = name:lower()
	if not cached.font[key] then
		local folder = Cache.main(folder and folder .. '/' or 'data/')
		local fpath = (folder .. name .. '.txt')
		
		if love.filesystem.getInfo(fpath) then
			cached.font[key] = FontData.load(name, folder)
		else
			trace('Resource for ' .. fpath .. ' doesn\'t exist')
			return FontData:new()
		end
	end
	
	return cached.font[key]
end

function Cache.shader(name)
	if name == nil then return nil end
	
	local key = name:lower()
	local fpathFrag, fpathVert = ('resources/love/shaders/' .. name .. '.frag'), ('resources/love/shaders/' .. name .. '.vert')
	local frag, vert =
		(love.filesystem.getInfo(fpathFrag) and love.filesystem.read(fpathFrag)),
		(love.filesystem.getInfo(fpathVert) and love.filesystem.read(fpathVert))
	
	if frag or vert then
		cached.shaders[key] = love.graphics.newShader(frag, vert)
	else
		trace('No frag or vert code exists for ' .. name)
	end
	
	return cached.shaders[key]
end

function Cache.resources(path)
	return ('resources/' .. path)
end
function Cache.main(path)
	return Cache.resources('main/' .. path)
end
function Cache.plants(path)
	return ('pvz.lawn.plants.' .. path)
end
function Cache.zombies(path)
	return ('pvz.lawn.zombies.' .. path)
end
function Cache.projectiles(path)
	return ('pvz.lawn.projectiles.' .. path)
end

function Cache.decompressFile(path)
	local file = love.filesystem.newFile(path, 'r')
	local val = file:read(4)
	local int = love.data.unpack('<i4', val)
	if int == -559022380 then -- zlib compressed reanimation
		local bytes = {}
		local output = deflate.inflate_zlib({
			input = file:read():sub(5);
			output = function(b) table.insert(bytes, string.char(b)) end;
		})
		
		return table.concat(bytes, '')
	else
		return file:read()
	end
end
function Cache.loadGifFile(path, frames)
	local file = love.filesystem.newFile(path, 'r')
	local gif = gif()
	
	while true do
		local data = file:read(65536)
		if not data or data == '' then break end
		gif:update(data)
		if frames and gif.ncomplete >= frames then break end
	end
	
	file:close()
	return gif:done()
end

Cache.unknownTexture = love.graphics.newImage(Cache.resources('noTexture.png'))
Cache.unknownTexture:setFilter('nearest', 'nearest')

return Cache