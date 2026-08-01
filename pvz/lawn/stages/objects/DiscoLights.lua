local DiscoLights = UIContainer:extend('DiscoLights')

DiscoLights.offsets = { 0 ; math.pi / 2 ; math.pi / 2 * 3 ; math.pi }
DiscoLights.uvOffsets = { 0, 0 ; 1, 0 ; 0, 1 ; 1, 1 }

function DiscoLights:init()
	UIContainer.init(self)
	
	self.time = 0
	
	self.texture = Resources.fetch('IMAGE_REANIM_CREDITS_DISCOLIGHTS', 'Image')
	
	self.vert = {{0, 0; 0, 0}; {0, 0; 0, 0}; {0, 0; 0, 0}; {0, 0; 0, 0}}
	
	self.mesh = love.graphics.newMesh(4, 'strip', 'stream')
	self.mesh:setTexture(self.texture)
end

function DiscoLights:update(dt)
	UIContainer.update(self, dt)
	
	self.time = (self.time + dt)
end

function DiscoLights:render(renderGroup)
	local time = self.time
	local vert = self.vert
	
	for i = 1, 4 do
		vert[i][1], vert[i][2] = (math.sin(DiscoLights.offsets[i] + self.time) * 600), (math.cos(DiscoLights.offsets[i] + self.time) * 200)
		vert[i][3], vert[i][4] = DiscoLights.uvOffsets[i * 2 - 1], DiscoLights.uvOffsets[i * 2]
	end
	
	self.mesh:setVertices(vert)
	
	love.graphics.setBlendMode('add')
	love.graphics.setColor(1, 1, 1, .5)
	love.graphics.draw(self.mesh)
	
	if self.debug then
		self.mesh:setTexture()
		
		love.graphics.setColor(1, 0, 1)
		love.graphics.line(vert[1][1], vert[1][2], vert[2][1], vert[2][2])
		love.graphics.line(vert[2][1], vert[2][2], vert[4][1], vert[4][2])
		love.graphics.line(vert[4][1], vert[4][2], vert[3][1], vert[3][2])
		love.graphics.line(vert[3][1], vert[3][2], vert[1][1], vert[1][2])
		
		self.mesh:setTexture(self.texture)
	end
end

return DiscoLights
