local WaveMeter = UIContainer:extend('WaveMeter')

function WaveMeter:init(x, y)
	self.texture = Cache.image('images/FlagMeter')
	self.textureParts = Cache.image('images/FlagMeterParts')
	self.textureProgress = Cache.image('images/FlagMeterLevelProgress')
	
	UIContainer.init(self, x, y, self.texture:getPixelWidth(), self.texture:getPixelHeight() * .5)
	
	self.quad = love.graphics.newQuad(0, 0, self.w, self.h, self.texture:getPixelDimensions())
	self.barBounds = {left = 8; right = 151}
	self.currentWave = 0
	self.progress = 0
	
	self:setFlags({})
end

function WaveMeter:setFlags(flagWaves)
	self.flags = {}
	for _, wave in ipairs(flagWaves) do
		table.insert(self.flags, {
			wave = wave;
			y = 0;
		})
	end
end

function WaveMeter:update(dt)
	for _, flag in ipairs(self.flags) do
		if self.currentWave < flag.wave then
			flag.y = 0
		else
			flag.y = math.max(flag.y - (dt * Constants.tickPerSecond / Constants.flagRaiseTime * 14), -14)
		end
	end
	
	UIContainer.update(self, dt)
end

function WaveMeter:draw(x, y)
	if not self.visible then return end
	
	local progressX = self:XAtProgress(self.progress)
	
	love.graphics.setColor(1, 1, 1)
	self.quad:setViewport(0, 0, self.w - progressX, self.h, self.texture:getPixelDimensions())
	love.graphics.draw(self.texture, self.quad, x, y)
	self.quad:setViewport(self.w - progressX, self.h, progressX, self.h, self.texture:getPixelDimensions())
	love.graphics.draw(self.texture, self.quad, x + self.w - progressX, y)
	
	for i = 1, #self.flags do
		local flagProgressX = self:XAtProgress(i / #self.flags * 100)
		local yy = self.flags[i].y
		
		self.quad:setViewport(25, 0, 25, 25, self.textureParts:getPixelDimensions())
		love.graphics.draw(self.textureParts, self.quad, x + self.w - flagProgressX - 2, y - 3)
		self.quad:setViewport(50, 0, 25, 25, self.textureParts:getPixelDimensions())
		love.graphics.draw(self.textureParts, self.quad, x + self.w - flagProgressX - 2, y + yy - 3)
	end
	
	love.graphics.draw(self.textureProgress, x + (self.w - self.textureProgress:getPixelWidth()) * .5, y + 14)
	
	local zombyProgressX = self:XAtProgress(self.progress, 6)
	self.quad:setViewport(0, 0, 25, 25, self.textureParts:getPixelDimensions())
	love.graphics.draw(self.textureParts, self.quad, x + self.w - zombyProgressX - 13, y - 3)
	
	UIContainer.draw(self, x, y)
end

function WaveMeter:XAtProgress(progress, pad)
	local pad = (pad or 0)
	return math.round(math.remap(progress, 0, 100, self.w - self.barBounds.right + pad, self.w - self.barBounds.left - pad))
end

return WaveMeter