local PeaShooter = Plant:extend('PeaShooter')
local Pea = Cache.module(Cache.projectiles('Pea'))

PeaShooter.reanimName = 'PeaShooterSingle'
PeaShooter.previewAnimation = 'full_idle'
PeaShooter.stemLayer = 'stem'
PeaShooter.maxHp = 300

PeaShooter.projectile = Pea

function PeaShooter:init(x, y, challenge)
	Plant.init(self, x, y, challenge)
	
	self.fireRate = 150
	self.fireTimer = self.fireRate
	self:setSpeed(random.number(1, 1.25))
	
	self.animation:add('idle', 'idle')
	self.animation:play('idle', true)
	
	self.head = Reanimation:new(self.reanimName)
	self.head.animation.speed = self.animation.speed
	self.head.animation.parallel['idle'] = true
	self.head.animation:add('idle', 'head_idle')
	self.head.animation:add('shoot', 'shooting', false)
	self.head.animation:get('shoot').speed = 3
	self.head.animation:play('idle', true)
	
	self:animate()
	
	self:attachBlink(self.head, 'face')
	self:attachReanim(self.stemLayer, self.head)
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
	
	Plant.update(self, dt)
	
	self.fireTimer = (self.fireTimer - dt * Constants.tickPerSecond * self.speed * self.speedMultiplier)
	
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
			if math.within(unit.boardX, self.boardX + .3, self.board.size.x + 1)
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
	Sound.playRandom({ 'throw' ; 'throw' ; 'throw' ; 'throw2' }, 10)
	local projectile = self.board:spawnUnit(self.projectile:new(), self.boardX, self.boardY)
	projectile.x = (projectile.x + 64)
	projectile.yOffset = random.int(-12, -16)
end

return PeaShooter