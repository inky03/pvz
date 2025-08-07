local deflate = require 'lib.deflate.deflatelua'
local gif = require 'lib.gifload'

local Cache = {
	cached = {
		images = {};
		sounds = {};
		reanim = {};
		
		levels = {};
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
			print('Module ' .. path .. ' not found')
		else
			print('Module ' .. path .. ' had errors:\n' .. result)
		end
		return nil
	end
end

function Cache.image(path)
	if path == nil then return nil end
	
	local img
	local key = path:lower()
	if not cached.images[key] then
		local fpath = Cache.main(path .. '.png')
		if love.filesystem.getInfo(fpath) then
			img = love.graphics.newImage(fpath, {mipmaps = true})
			goto loaded
		end
		
		local fpathJpg = Cache.main(path .. '.jpg')
		local fpathMask = Cache.main(path .. '_.png')
		if love.filesystem.getInfo(fpathJpg) then
			if love.filesystem.getInfo(fpathMask) then
				local image = love.image.newImageData(fpathJpg)
				local mask = love.image.newImageData(fpathMask)
				
				image:mapPixel(function(x, y, r, g, b)
					local a = mask:getPixel(x, y)
					return r, g, b, a
				end)
				
				img = love.graphics.newImage(image, {mipmaps = true})
				goto loaded
			else
				img = love.graphics.newImage(fpathJpg, {mipmaps = true})
				goto loaded
			end
		end
		
		local fpathGifMask = Cache.main(path .. '.gif')
		if love.filesystem.getInfo(fpathGifMask) then
			local gif = Cache.loadGifFile(fpathGifMask, 1).imgs[3]
			
			gif:mapPixel(function(x, y, r, g, b) return 1, 1, 1, r end)
			
			img = love.graphics.newImage(gif, {mipmaps = true})
			goto loaded
		end
			
		print('Resource for ' .. fpath .. ' doesn\'t exist')
		return Cache.unknownTexture
	else
		return cached.images[key]
	end
	
	::loaded::
	cached.images[key] = img
	img:setMipmapFilter('linear', .75)
	return img
end

function Cache.reanim(kind, folder)
	if kind == nil then return nil end
	
	local t = os.clock()
	local path = (folder and (folder .. '/' .. kind) or ('compiled/reanim/' .. kind))
	local key = kind:lower()
	if not cached.reanim[key] then
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
			print('Resource for ' .. fpath .. ' doesn\'t exist')
			return Reanim:new()
		end
		print(('%s Reanimation (%s) (%.2fms)'):format(kind, format, (os.clock() - t) * 1000))
	end
	
	return cached.reanim[key]
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