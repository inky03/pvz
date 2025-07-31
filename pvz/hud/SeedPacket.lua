local SeedPacket = class('SeedPacket')

function SeedPacket:init(plant)
	self.texture = Cache.image('images/seeds')
	
	self.quad = love.graphics.newQuad(50 * 2, 0, 50, self.texture:getPixelHeight(), self.texture)
	
	self.entity = Cache.module(Cache.plants(plant))
	if self.entity then
		self.display = Reanimation:new(self.entity:getReanim())
		self.display.animation:add('preview', self.entity:getPreviewAnimation())
		self.display.animation:play('preview', true)
		self.display.animation:setFrame(self.entity:getPreviewFrame())
		self.display.transform:setScale(.5, .5)
	end
end

function SeedPacket:draw(x, y)
	x, y = (x or 0), (y or 0)
	
	love.graphics.draw(self.texture, self.quad, x, y)
	
	if self.display then
		self.display:draw(x + 4.75, y + 8.75)
	end
end

return SeedPacket