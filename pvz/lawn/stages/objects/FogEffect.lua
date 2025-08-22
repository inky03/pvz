local FogEffect = UIContainer:extend('FogEffect')

FogEffect.textureName = 'fog'
FogEffect.maskTextureName = 'fog_'
FogEffect.simpleTextureName = 'fog_software'
FogEffect.complexCels = 8
FogEffect.simpleCels = 3

FogEffect.fogOffset = {x = -55; y = -60}
FogEffect.simpleFogOffset = {x = -45; y = -57}

function FogEffect:init(lawn, columns)
	UIContainer.init(self)
	
	local fogColumns = (columns or 3)
	
	self.simpleTexture = Cache.image(self.simpleTextureName, 'images')
	self.texture = Cache.image(self.textureName, 'images')
	self.quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
	self.lawn = lawn
	
	self.fogCounter = 0
	
	self.fogValid = table.populate(self.lawn.size.y + 1, table.populate(self.lawn.size.x + 1, false))
	self.fogAlpha = table.populate(self.lawn.size.y + 1, table.populate(self.lawn.size.x + 1, 0))
	self.randoms = table.populate(self.lawn.size.y + 1, function()
		return table.populate(self.lawn.size.x + 1, function()
			return random.int(0, 20)
		end)
	end)
	
	for row = 1, self.lawn.size.y + 1 do
		for col = self.lawn.size.x - fogColumns + 1, self.lawn.size.x + 1 do
			self.fogValid[row][col] = true
		end
	end
end

function FogEffect:update(dt)
	UIContainer.update(self, dt)
	
	self.fogCounter = (self.fogCounter + dt * Constants.tickPerSecond)
	self:updateFog(dt)
end

function FogEffect:updateFog(dt)
	local fadeInSpeed = 3
	
	for row = 1, self.lawn.size.y + 1 do
		for col = 1, self.lawn.size.x + 1 do
			if self.fogValid[row][col] then
				local maxAlpha = (self.fogValid[row][col - 1] and 255 or 200)
				self.fogAlpha[row][col] = math.min(self.fogAlpha[row][col] + dt * Constants.tickPerSecond * fadeInSpeed, maxAlpha)
			end
		end
	end
end

function FogEffect:draw(x, y)
	for row = 1, #self.fogAlpha do
		for col = 1, #self.fogAlpha[row] do
			local xx, yy = (col - 1), (row - 1)
			local alpha = self.fogAlpha[row][col]
			
			local fogTexture = (complex and self.texture or self.simpleTexture)
			local fogOffset = (complex and self.fogOffset or self.simpleFogOffset)
			
			if alpha <= 0 then goto continue end
			
			local celLook = self.randoms[row][col]
			
			local fogX, fogY = self.lawn:elementToScreen(self.lawn:getWorldPosition(col, row))
			local fogWidth = (complex and (self.texture:getPixelWidth() / self.complexCels) or (self.simpleTexture:getPixelWidth() / self.simpleCels))
			
			local celID = (celLook % self.complexCels)
			if not complex then celID = (celID % self.simpleCels) end
			self.quad:setViewport(celID * fogWidth, 0, fogWidth, fogTexture:getPixelHeight(), fogTexture:getPixelDimensions())
			
			if complex then
				local phaseX, phaseY = (6 * math.pi * xx / (self.lawn.size.x - 1)), (6 * math.pi * yy / (self.lawn.size.y - 1))
				local motion = (13 + 4 * math.sin(self.fogCounter / 900 + phaseY) + 8 * math.sin(self.fogCounter / 500 * phaseX))
				
				local colorVariant = (255 - celLook * 1.5 - motion * 1.5)
				local lightnessVariant = (255 - celLook - motion)
				
				love.graphics.setColor(colorVariant / 255, colorVariant / 255, lightnessVariant / 255, alpha / 255)
			else
				love.graphics.setColor(1, 1, 1, alpha / 255)
			end
			
			love.graphics.draw(fogTexture, self.quad, x + fogX + fogOffset.x, y + fogY + fogOffset.y)
			
			::continue::
		end
	end
	
	love.graphics.setColor(1, 1, 1)
	UIContainer.draw(self, x, y)
end

return FogEffect