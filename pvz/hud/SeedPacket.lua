local SeedPacket = class('SeedPacket')

function SeedPacket:init(plant)
	self.texture = Cache.image('images/seeds')
	
	self.quad = love.graphics.newQuad(50 * 2, 0, 50, self.texture:getPixelHeight(), self.texture)
	
	self.entity = Cache.module(Cache.plants(plant))
	self.display = Sprite:new()
	if self.entity then
		print(self.entity:getReanim())
		self.display:setReanim(Cache.reanim(self.entity:getReanim()))
		self.display:playAnimation(self.entity:getPreviewAnimation(), true)
		self.display:setFrame(self.display.animation.curFrame + self.entity:getPreviewFrame())
		self.display.transform:setScale(.5, .5)
	else
	end
end

function SeedPacket:draw(x, y)
	x, y = (x or 0), (y or 0)
	
	love.graphics.draw(self.texture, self.quad, x, y)
	
	self.display:draw(x + 4.75, y + 8.75)
end

return SeedPacket