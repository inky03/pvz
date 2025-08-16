local ReanimAnimationFrame = ReanimFrame:extend('ReanimAnimationFrame')

function ReanimAnimationFrame:init(frame)
	ReanimFrame.init(self, frame)
	
	self.attachments = {}
end

function ReanimAnimationFrame:attach(object, transform)
	table.insert(self.attachments, {
		object = object;
		transform = transform;
	})
end

return ReanimAnimationFrame