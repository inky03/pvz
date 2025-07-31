local ReanimAnimationFrame = ReanimFrame:extend('ReanimAnimationFrame')

function ReanimAnimationFrame:init(frame)
	ReanimFrame.init(self, frame)
	
	self.attachments = {}
	self.diffX = 0
	self.diffY = 0
end

function ReanimAnimationFrame:attachReanim(reanim, transform)
	table.insert(self.attachments, {
		reanim = reanim;
		transform = transform;
	})
end

function ReanimAnimationFrame:setPosition(x, y)
	self.diffX, self.diffY = (x - self.x), (y - self.y)
	self.x, self.y = x, y
	return self
end

return ReanimAnimationFrame