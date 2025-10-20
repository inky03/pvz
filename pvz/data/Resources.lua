local Resources = class('Resources')

Resources.resources = {}
Resources.blobs = {}

function Resources.reload(path)
	local path = (path or Cache.main('properties/resources.xml'))
	
	local content = xml.parse(love.filesystem.read(path))
	local manifest = content.children[1]
	
	local allResources = Resources.resources
	local allBlobs = Resources.blobs
	table.clear(allResources)
	table.clear(allBlobs)
	
	for i = 1, #manifest.children do
		local blob = manifest.children[i]
		if blob.tag == 'Resources' then
			local folder, idprefix = '', ''
			local blobId = blob.attrs.id
			local resources = blob.children
			for j = 1, #resources do
				local res = resources[j]
				if res.tag == 'SetDefaults' then
					folder = res.attrs.path
					idprefix = res.attrs.idprefix
				else
					local newResource = {
						blob = blobId;
						type = res.tag;
						prefix = folder;
						path = res.attrs.path;
					}
					
					if res.tag == 'Image' then
						newResource.maskPath = res.attrs.alphagrid
						newResource.columns = tonumber(res.attrs.cols)
						newResource.rows = tonumber(res.attrs.rows)
					end
					allResources[idprefix .. res.attrs.id] = newResource
				end
			end
		end
	end
	
	for _, resource in pairs(allResources) do
		local blob = (allBlobs[resource.blob] or {})
		allBlobs[resource.blob] = blob
		
		table.insert(blob, resource)
	end
end

function Resources.formatPath(path, folder)
	return (path and ('%s/%s'):format(folder, path):match('(.*)%.') or nil)
end

function Resources.getBlob(blob)
	return lambda:find(Resources.blobs, function(_, key) return key:lower() == blob:lower() end)
end
function Resources.get(id, type, blob)
	local resource = Resources.resources[id:upper()]
	if resource then
		if type and resource.type:lower() ~= type:lower() then trace('Resource ' .. id .. ' type mismatch with ' .. type) return nil end
		if blob and resource.blob:lower() ~= blob:lower() then trace('Resource ' .. id .. ' not in blob ' .. blob) return nil end
		return resource
	else
		return nil
	end
end
function Resources.getPath(id, type, blob, formatPath)
	local resource = Resources.get(id, type, blob)
	if resource then
		if formatPath == false then
			return resources.path, resources.prefix
		else
			return Resources.formatPath(resources.path, resources.prefix)
		end
	else
		trace('Undefined resource ' .. id .. '')
	end
end
function Resources.getImageGrid(id, blob)
	local image = Resources.get(id, 'Image', blob)
	if image then return (image.columns or 1), (image.rows or 1) end
	return 1, 1
end
function Resources.fetch(id, type, blob, eval)
	local resource = Resources.get(id, type, blob)
	if resource then
		local path, folder = resource.path, resource.prefix
		
		if type == 'Image' then
			return Cache.image(path, folder, eval, resource.maskPath)
		elseif type == 'Sound' then
			return Cache.sound(Resources.formatPath(path, folder))
		elseif type == 'Font' then
			return Cache.font(path:gsub('.txt', ''), folder)
		end
	else
		local lastResort
		if type == 'Image' then
			if id:find('IMAGE_REANIM_') then
				local img = id:gsub('IMAGE_REANIM_', '')
				lastResort = Cache.image(img, 'reanim', true) or Cache.image(img, 'images', true) or Cache.image(img, 'particles', true)
			else
				local img = id:gsub('IMAGE_', '')
				lastResort = Cache.image(img, 'images', true) or Cache.image(img, 'particles', true)
			end
		elseif type == 'Sound' then
			lastResort = Cache.sound(id:gsub('SOUND_', ''), true)
		elseif type == 'Font' then
			lastResort = Cache.font(id:gsub('FONT_', ''), nil, true)
		end
		if lastResort then return lastResort end
		
		if not eval then trace('Undefined resource ' .. id .. '') end
		
		if type == 'Image' then
			return Cache.unknownTexture
		elseif type == 'Sound' then
			return Cache.sound()
		elseif type == 'Font' then
			return Cache.font()
		end
		return nil
	end
end

return Resources