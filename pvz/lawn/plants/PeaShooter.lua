local PeaShooter = Plant:extend('PeaShooter')
local Pea = Cache.module(Cache.projectiles('Pea'))

function PeaShooter:init(x, y)
	Plant.init(self, x, y)
	self.hp = 300
	
	self.fireRate = 24
	self.fireTimer = self.fireRate
	self:setSpeed(random.number(1, 1.25))
	
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	
	self.head = Reanimation:new(self.getReanim())
	self.head.animation.speed = self.animation.speed
	self.head.animation.parallel['idle'] = true
	self.head.animation:add('idle', 'head_idle')
	self.head.animation:add('shoot', 'shooting', false)
	self.head.animation:get('shoot').speed = 2.5
	self.head.animation:play('idle', true)
	
	self:animate()
	
	self:attachReanim(self.getStem(), self.head)
end

function PeaShooter:animate()
	self.head.animation.onFrame:add(function(animation)
		if animation.name == 'shoot' then
			if animation.frame == 12 then
				self:fireProjectile()
			elseif animation.frame > 18 then
				self.head.animation:play('idle', false, nil, false)
			end
		end
	end)
end

function PeaShooter:update(dt)
	if not self.active then return end
	
	Plant.update(self, dt * self.speedMultiplier)
	
	self.fireTimer = (self.fireTimer - dt * self.reanim.fps * self.speed * self.speedMultiplier)
	
	if self.fireTimer < 0 then
		self.fireTimer = (self.fireTimer + self.fireRate)
		
		if self:canFire() then
			self:fire()
		end
	end
end

function PeaShooter:canFire()
	if not self.board then return false end
	
	for _, unit in ipairs(self.board.units) do
		if unit:instanceOf(self.damageGroup) and not unit.dead then
			if math.within(unit.boardX, self.boardX + .5, self.board.size.x + .99)
			and math.round(unit.boardY) == math.round(self.boardY) then
				return true
			end
		end
	end
	
	return false
end
function PeaShooter:fire()
	self.head.animation:play('shoot', false, self.head.animation:framesToSeconds(1))
end
function PeaShooter:fireProjectile()
	local projectile = self.board:spawnUnit(Pea:new(), self.boardX, self.boardY)
	projectile.x = (projectile.x + 64)
	projectile.yOffset = random.number(-12, -16)
end

function PeaShooter.getReanim()
	return 'PeaShooterSingle'
end
function PeaShooter.getStem()
	return 'stem'
end
function PeaShooter.getPreviewAnimation()
	return 'full_idle'
end

return PeaShooter