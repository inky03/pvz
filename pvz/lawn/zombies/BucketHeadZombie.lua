local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local BucketHeadZombie = BasicZombie:extend('BucketHeadZombie')

BucketHeadZombie.maxHelmHp = 1100

BucketHeadZombie.value = 4
BucketHeadZombie.pickWeight = 3000
BucketHeadZombie.startingLevel = 8
BucketHeadZombie.firstAllowedWave = 1

function BucketHeadZombie:init(x, y, challenge)
	BasicZombie.init(self, x, y, challenge)
	
	self:toggleLayer('bucket', true)
end

function BucketHeadZombie:hurt(hp, glow)
	BasicZombie.hurt(self, hp, glow)
	
	if self.helmDamagePhase == 0 and self.helmHp <= (self.maxHelmHp - 350) then
		self:setHelmDamagePhase(1)
	end if self.helmDamagePhase == 1 and self.helmHp <= (self.maxHelmHp - 700) then
		self:setHelmDamagePhase(2)
	end if self.helmDamagePhase == 2 and self.helmHp <= 0 then
		self:setHelmDamagePhase(3)
	end
end

function BucketHeadZombie:setHelmDamagePhase(phase)
	BasicZombie.setHelmDamagePhase(self, phase)
	
	if phase == 1 then
		self:replaceImage('Zombie_bucket1', Reanim.getResource('Zombie_bucket2'))
	elseif phase == 2 then
		self:replaceImage('Zombie_bucket1', Reanim.getResource('Zombie_bucket3'))
	elseif phase == 3 then
		self:toggleLayer('bucket', false)
	end
end

return BucketHeadZombie