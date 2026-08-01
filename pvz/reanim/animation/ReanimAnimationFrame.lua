local ReanimAnimationFrame = ReanimFrame:extend('ReanimAnimationFrame')

function ReanimAnimationFrame:init(frame)
	ReanimFrame.init(self, frame)
	
	self.renderGroup = 1
	self.attachmentRenderGroups = {}
	self.attachments = {}
	self.attachment = nil
	self.font = nil
end

function ReanimAnimationFrame:attach(object, transform, update)
	if not object then
		trace(('%s: Tried to attach null object'):format(self.layerName))
		
		return
	end
	
	local update = update if update == nil then update = true end
	
	table.insert(self.attachments, {
		object = object;
		update = update;
		transform = transform;
	})
	
	self._dirtyAttachments = true
	
	return object, transform
end
function ReanimAnimationFrame:detach(object, destroy)
	local attachment, i = lambda.find(self.attachments, function(attachment) return attachment.object == object end)
	
	if attachment then
		if destroy ~= false then attachment.object:destroy() end
		
		table.remove(self.attachments, i)
		
		self._dirtyAttachments = true
	else
		trace(('%s: %s is not attached'):format(self.layerName, object))
	end
end
function ReanimAnimationFrame:detachAll(destroy)
	if destroy ~= false then
		for i = 1, #self.attachments do
			self.attachments[i].object:destroy()
		end
	end
	
	table.clear(self.attachments)
end

function ReanimAnimationFrame:findAttachment(needle)
	if not self.active then return end
	
	if self.attachment == needle then
		return self.attachment
	elseif self.attachment and self.attachment:instanceOf(Reanimation) then
		if self.attachment:getName() == needle then return self.attachment end
		local attachment = self.attachment:findAttachment(needle)
		if attachment then return attachment end
	end
	
	for _, attachment in ipairs(self.attachments) do
		if attachment.object == needle then
			return attachment
		elseif attachment.object:instanceOf(Reanimation) then
			if attachment.object:getName() == needle then return attachment.object end
			local attachment = attachment.object:findAttachment(needle)
			if attachment then return attachment end
		end
	end
end
function ReanimAnimationFrame:updateAttacher()
	if self._dirtyAttachments then
		table.clear(self.attachmentRenderGroups)
		
		for i = 1, #self.attachments do
			local object = self.attachments[i].object
			
			if object and object.renderGroup then self.attachmentRenderGroups[object.renderGroup] = true end
		end
		
		self._dirtyAttachments = false
	end
	
	if self.active then
		if self.font then
			if not self.attachment or not self.attachment:instanceOf(Font) then
				self.attachment = Font:new(Resources.fetch(self.font, 'Font'), nil, 0, 0, gameWidth)
				self.attachment.transform:setOffset(self.attachment.w * .5, 0)
				self.attachment:setAlignment('middle')
			else
				self.attachment:setFontData(Resources.fetch(self.font, 'Font'))
			end
			
			self.attachment:setText(self.text)
			
			return
		elseif self.text then
			local attacherInfo = self.text:split('__')
			if #attacherInfo >= 2 then
				local tags = {}
				for i, s in ipairs(attacherInfo) do
					for tag in s:gmatch('%[(.-)%]') do
						table.insert(tags, tag)
					end
					
					local idx = s:find('%[')
					attacherInfo[i] = s:sub(1, idx and idx - 1 or nil)
				end
				
				if not self.attachment or not self.attachment:instanceOf(Reanimation) then
					self.attachment = Reanimation:new(attacherInfo[2])
				elseif self.attachment.reanim.name ~= attacherInfo[2] then
					self.attachment:setReanim(Cache.reanim(attacherInfo[2]))
				end
				
				local anim = attacherInfo[3]
				if anim then
					local animFake = (not self.attachment.animation:get(anim))
					
					if animFake then
						self.attachment.animation:add(anim, anim)
					end
					if self.attachment.animation.name ~= anim then
						self.attachment.animation:play(anim, animFake)
					end
				end
				
				for _, tag in ipairs(tags) do
					if tag == 'hold' or tag == 'once' then
						self.attachment.animation:setLoop(false)
					else
						local f = tonumber(tag)
						if f then self.attachment.animation._cur.fps = f end
					end
				end
				
				return
			end
		end
	end
	
	if self.attachment then self.attachment:destroy() end
	self.attachment = nil
end

function ReanimAnimationFrame:__tostring()
	local function round(n)
		return (math.round(n * 100) / 100)
	end
	
	return ('ReanimAnimationFrame(x:%s, y:%s, xShear:%s, yShear:%s, xScale:%s, yScale:%s, active:%s, alpha:%s, attachment:%s)'):format(
		round(self.x), round(self.y),
		round(self.xShear), round(self.yShear),
		round(self.xScale), round(self.yScale),
		tostring(self.active), round(self.alpha),
		tostring(self.attachment)
	)
end

return ReanimAnimationFrame