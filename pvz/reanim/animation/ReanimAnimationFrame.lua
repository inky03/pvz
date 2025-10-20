local ReanimAnimationFrame = ReanimFrame:extend('ReanimAnimationFrame')

function ReanimAnimationFrame:init(frame)
	ReanimFrame.init(self, frame)
	
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
function ReanimAnimationFrame:findAttachment(name)
	if not self.active then return end
	
	if self.attachment and self.attachment:instanceOf(Reanimation) and self.attachment:getName() == name then
		return self.attachment
	end
	
	for _, attachment in ipairs(self.attachments) do
		if attachment:instanceOf(Reanimation) and attachment.object:getName() == name then
			return attachment.object
		end
	end
end

return ReanimAnimationFrame