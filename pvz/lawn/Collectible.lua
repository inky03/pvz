local Collectible = Reanimation:extend('Collectible')

Collectible.reanimName = 'Sun'
Collectible.scoringDistance = 12
Collectible.pullMoveDelta = 21
Collectible.scaleDelta = .02
Collectible.fadeTicks = 15
Collectible.lifetime = 750
Collectible.scale = 1

function Collectible:init(x, y, mode)
	Reanimation.init(self, self.reanimName, x, y)
	
	self.fade = 0
	self.mode = mode
	self.dead = false
	self.state = 'normal'
	self.onGround = false
	
	self.life = self.lifetime
	
	local scale = self.scale
	self.collectionDistance = math.inf
	self.transform:setScale(scale, scale)
	
	self.destX, self.destY = 0, 0
	self.velX, self.velY = 0, 0
	self.gravityY = 0
	self.groundY = y
	
	if mode == 'rain' then
		self.velY = .67
		self.groundY = (300 + random.int(250))
	elseif mode == 'plant' then
		self.gravityY = .09
		self.velX = random.number(-.4, .4)
		self.velY = random.number(-1.7, -3.4)
		self.groundY = (self.y + 15 + random.int(20))
		self.transform:setScale(scale * .4, scale * .4)
	end
end

function Collectible:update(dt)
	Reanimation.update(self, dt)
	
	if self.state == 'normal' then
		if self.y < self.groundY then
			self.x = (self.x + self.velX * dt * Constants.tickPerSecond)
			self.y = (self.y + self.velY * dt * Constants.tickPerSecond)
			self.velY = math.min(self.velY + self.gravityY * dt * Constants.tickPerSecond, self.groundY)
		else
			self.velX, self.velY = 0, 0
			
			if not self.onGround then
				self:hitGround()
			end
			
			self.life = (self.life - dt * Constants.tickPerSecond)
			if self.life < 0 then
				self:fadeOut()
			end
		end
	elseif self.state == 'collected' then
		local dtt = math.min(dt / self.pullMoveDelta * Constants.tickPerSecond, 1)
		self:setPosition(
			math.lerp(self.x, self.destX, dtt),
			math.lerp(self.y, self.destY, dtt)
		)
		
		self.collectionDistance = math.eucldistance(self.x, self.y, self.destX, self.destY)
		if self.collectionDistance < self.scoringDistance then
			self:die()
		end
	elseif self.state == 'fade' then
		self.fade = (self.fade - dt * Constants.tickPerSecond)
		if self.fade < 0 then
			self:die()
		end
	end
	
	self:updateVisual(dt)
end
function Collectible:updateVisual(dt)
	if self.state == 'collected' then
		local scale = math.clamp(self.collectionDistance * .05, .5, 1)
		self.transform:setScale(scale, scale)
		
		self.transform.alpha = math.clamp(self.collectionDistance * .035, .35, 1)
	else
		if self.state == 'fade' then
			self.transform.alpha = math.remap(self.fade, self.fadeTicks, 0, 1, 0)
		end
		
		if self.mode == 'plant' then
			local scale = math.min(self.transform.xScale + dt * Constants.tickPerSecond * self.scaleDelta, self.scale)
			self.transform:setScale(scale, scale)
		end
	end
end
function Collectible:hitGround()
	self.onGround = true
end
function Collectible:fadeOut()
	self.state = 'fade'
	self.fade = self.fadeTicks
end

function Collectible:mousePressed(mouseX, mouseY, button, isTouch, presses)
	if not self.dead then
		self:onCollect()
	end
end

function Collectible:onSpawn() end
function Collectible:onDespawn(collected) end
function Collectible:onCollect()
	self.canClick = false
	self.state = 'collected'
end
function Collectible:die()
	self.dead = true
	self:onDespawn(self.state == 'collected')
	self:destroy()
end

return Collectible