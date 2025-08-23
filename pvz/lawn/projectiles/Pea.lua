local Pea = Projectile:extend('Pea')

Pea.particleName = 'PeaSplat'

function Pea:init(challenge)
	Projectile.init(self, 0, 0, challenge)
	
	self.texture = Cache.image('ProjectilePea', 'images')
	self.shadow = Cache.image('pea_shadows', 'images')
	
	self.shadowOffset = {x = 4; y = 66}
	self.shadowQuad = love.graphics.newQuad(0, 0, self.shadow:getPixelWidth() * .5, self.shadow:getPixelHeight(), self.shadow:getPixelWidth(), self.shadow:getPixelHeight())
end

function Pea:hit(collision, multiplier)
	Projectile.hit(self, collision, multiplier)
	Sound.playRandom({ 'splat' ; 'splat2' ; 'splat3' }, 10)
	
	self.board:spawnParticle(self.particleName, self.x + 28, self.y + 23)
end

function Pea:drawShadow(x, y)
	if self.flags.ignoreCollisions then return end
	
	love.graphics.draw(self.shadow, self.shadowQuad, x + self.shadowOffset.x, y + self.shadowOffset.y)
end

function Pea:drawSprite(x, y)
	love.graphics.draw(self.texture, math.round(x), math.round(y))
end

return Pea