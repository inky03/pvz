local PoolEffect = UIContainer:extend('PoolEffect')

PoolEffect.causticAlpha = nil
PoolEffect.textureName = 'pool'
PoolEffect.baseTextureName = 'pool_base'
PoolEffect.shadingTextureName = 'pool_shading'
PoolEffect.causticTextureName = 'pool_caustic_effect'
PoolEffect.shadingMaskTextureName = 'pool_shading_'
PoolEffect.baseMaskTextureName = 'pool_base_'
PoolEffect.textureOffset = {
	x = 1;
	y = 1;
}
PoolEffect.causticTextureOffset = {
	x = 11;
	y = 10;
}

function PoolEffect:init(pool, x, y)
	self.pool = pool
	self.poolCounter = 0
	
	self.texture = Cache.image(self.textureName, 'images')
	self.baseTexture = Cache.image(self.baseTextureName, 'images', nil, self.baseMaskTextureName)
	self.causticTexture = Cache.image(self.causticTextureName, 'images')
	self.shadingTexture = Cache.image(self.shadingTextureName, 'images', nil, self.shadingMaskTextureName)
	self.causticShader = Cache.shader('caustic')
	self.causticTexture:setWrap('repeat')
	
	UIContainer.init(self, x, y, self.texture:getPixelDimensions())
	
	self.offsets = table.populate(3, table.populate(16, table.populate(6, {0, 0}))) -- ummm
	self.verts = table.populate(#self.offsets, table.populate(150, table.populate(3, {-100, -100, -100, -100, 1, 1, 1, 1}))) -- yea!
	self.vertMap = table.populate(#self.verts, {})
	for a = 1, 3 do
		for b = 1, 150 do
			for c = 1, 3 do
				table.insert(self.vertMap[a], self.verts[a][b][c])
			end
		end
	end
	self.indexOffsetX, self.indexOffsetY = {0, 0, 1, 0, 1, 1}, {0, 1, 1, 0, 1, 0}
	self.mesh = love.graphics.newMesh(self.vertMap[1], 'triangles', 'dynamic')
	
	self.canClick = false
end

function PoolEffect:update(dt)
	self.poolCounter = (self.pool and self.pool.poolCounter or (self.poolCounter + dt * Constants.tickPerSecond))
	if shaders then self.causticShader:send('counter', self.poolCounter) end
end

function PoolEffect:draw(x, y)
	if not self.visible then return end
	
	local poolWidth, poolHeight = self.texture:getPixelDimensions()
	local gridW, gridH = (poolWidth / 15), (poolHeight / 5)
	local off = self.offsets
	
	if not (complex and shaders) then
		love.graphics.draw(self.texture, x, y)
		goto noshader
	end
	
	for x = 1, 16 do
		for y = 1, 6 do
			local xx, yy = (x - 1), (y - 1)
			local x3, y3 = (xx / 15), 0
			
			if x > 1 and x < 16 and y > 1 and y < 6 then
				local poolPhase = (self.poolCounter * 2 * math.pi)
				local wave1 = (poolPhase / 800)
				local wave2 = (poolPhase / 150)
				local wave3 = (poolPhase / 900)
				local wave4 = (poolPhase / 800)
				local wave5 = (poolPhase / 110)
				local xPhase = (xx * 3 * 2 * math.pi / 15)
				local yPhase = (yy * 3 * 2 * math.pi / 5)
				
				off[1][x][y][1] = (math.sin(yPhase + wave2) * .002 + math.sin(yPhase + wave1) * .005)
				off[1][x][y][2] = (math.sin(xPhase + wave2) * .01 + math.sin(yPhase + wave1) * .015 + math.sin(xPhase + wave4) * .005)
				
				off[2][x][y][1] = (math.sin(yPhase * .2 + wave2) * .015 + math.sin(yPhase * .2 + wave1) * .012)
				off[2][x][y][2] = (math.sin(xPhase * .2 + wave5) * .005 + math.sin(xPhase * .2 + wave3) * .015 + math.sin(xPhase * .2 + wave4) * .02)
				
				off[3][x][y][1] = (x3 + math.sin(yPhase + wave1 * 1.5) * .004 + math.sin(yPhase + wave2 * 1.5) * .005)
				off[3][x][y][2] = (y3 + math.sin(xPhase * 4 + wave5 * 2.5) * .005 + math.sin(xPhase * 2 + wave3 * 2.5) * .04 + math.sin(xPhase * 3 + wave4 * 2.5) * .02)
			else
				off[1][x][y][1], off[1][x][y][2] = 0, 0
				off[2][x][y][1], off[2][x][y][2] = 0, 0
				off[3][x][y][1], off[3][x][y][2] = x3, y3
			end
		end
	end
	
	for x = 1, 15 do
		for y = 1, 5 do
			local xx, yy = (x - 1), (y - 1)
			for layer = 1, 3 do
				local vertArray = self.verts[layer]
				for vertIndex = 1, 6 do
					local vert = vertArray[xx * 10 + yy * 2 + (vertIndex <= 3 and 1 or 2)][(vertIndex - 1) % 3 + 1]
					local indexX, indexY = (xx + self.indexOffsetX[vertIndex]), (yy + self.indexOffsetY[vertIndex])
					
					vert[3] = (indexX / 15 + off[layer][indexX + 1][indexY + 1][1])
					vert[4] = (indexY / 5 + off[layer][indexX + 1][indexY + 1][2])
					
					if layer == 3 then
						vert[1] = (indexX * 704 / 15 + self.causticTextureOffset.x)
						vert[2] = (indexY * 30 + self.causticTextureOffset.y)
						vert[4] = (indexY / 5 + off[layer][indexX + 1][indexY + 1][2] / 5)
						
						if indexX == 0 or indexX == 15 or indexY == 0 then
							vert[8] = (0x20 / 255)
						elseif self.causticAlpha then
							vert[8] = self.causticAlpha
						else
							vert[8] = ((indexX <= 7 and 0xc0 or 0x80) / 255)
						end
					else
						vert[1] = (indexX * gridW + self.textureOffset.x)
						vert[2] = (indexY * gridH + self.textureOffset.y)
					end
				end
			end
		end
	end
	
	self.mesh:setVertices(self.vertMap[1])
	self.mesh:setTexture(self.baseTexture)
	love.graphics.draw(self.mesh, x, y)
	self.mesh:setVertices(self.vertMap[2])
	self.mesh:setTexture(self.shadingTexture)
	love.graphics.draw(self.mesh, x, y)
	self.mesh:setVertices(self.vertMap[3])
	self.mesh:setTexture(self.causticTexture)
	love.graphics.setShader(self.causticShader)
	love.graphics.draw(self.mesh, x, y)
	love.graphics.setShader()
	
	if self.debug then
		self.mesh:setTexture()
		self.mesh:setVertices(self.vertMap[1])
		love.graphics.setColor(1, 0, 1)
		love.graphics.setWireframe(true)
		love.graphics.draw(self.mesh, x, y)
		love.graphics.setWireframe(false)
	end
	
	::noshader::
	UIContainer.draw(self, x, y)
end

return PoolEffect