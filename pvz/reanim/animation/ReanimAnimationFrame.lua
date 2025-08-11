local ReanimAnimationFrame = ReanimFrame:extend('ReanimAnimationFrame')

function ReanimAnimationFrame:init(frame)
	ReanimFrame.init(self, frame)
	
	self.attachments = {}
end

function ReanimAnimationFrame:attachReanim(reanim, transform)
	table.insert(self.attachments, {
		reanim = reanim;
		transform = transform;
	})
end

return ReanimAnimationFrame