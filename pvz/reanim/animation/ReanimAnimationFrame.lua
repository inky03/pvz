local ReanimAnimationFrame = ReanimFrame:extend('ReanimAnimationFrame')

function ReanimAnimationFrame:init(frame)
	ReanimFrame.init(self, frame)
	
	self.renderGroup = 1
	self.attachments = {}
	self.attachment = nil
	self.font = nil
end

function ReanimAnimationFrame:attach(object, transform)
	table.insert(self.attachments, {
		object = object;
		transform = transform;
	})
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
					self.attachment.animation:play(anim, animFake)
				end
				
				for _, tag in ipairs(tags) do
					if tag == 'hold' then
						self.attachment.animation.current.loop = false
					elseif tag == 'once' then
						self.attachment.animation.current.loop = false
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

return ReanimAnimationFrame