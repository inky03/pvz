local SeedPacket = UIContainer:extend('SeedPacket')

function SeedPacket:init(entity, x, y)
	self.texture = Cache.image('images/seeds')
	
	UIContainer.init(self, x, y, 50, self.texture:getPixelHeight())
	
	self.frame = 3
	self.entity = Cache.module(entity)
	if self.entity then
		self.display = self.entity:new()
		self.display.transform:setScale(.5, .5)
		
		if self.entity.isUpgradeOf() then
			self.frame = 2
		end
	end
	
	self.useHand = true
	
	self.quad = love.graphics.newQuad(50 * (self.frame - 1), 0, self.w, self.h, self.texture)
end

function SeedPacket:mousePressed(mouseX, mouseY)
	if lawn.hoveringEntity == nil and self.entity then
		lawn.hoveringEntity = self.entity:new()
		lawn.hoveringEntity.animation:setFrame(self.entity.getPreviewFrame())
		lawn:updateHover(mouseX, mouseY)
		
		self.parent.canClickChildren = false
	end
end

function SeedPacket:update(dt)
	UIContainer.update(self, dt)
end

function SeedPacket:draw(x, y)
	love.graphics.draw(self.texture, self.quad, x, y)
	
	if self.display then
		self.display:draw(x + 4.75, y + 8.75)
	end
	
	UIContainer.draw(self, x, y)
end

return SeedPacket