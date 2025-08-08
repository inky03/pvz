local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local ConeHeadZombie = BasicZombie:extend('ConeHeadZombie')

ConeHeadZombie.maxHelmHp = 470

ConeHeadZombie.value = 2
ConeHeadZombie.startingLevel = 3
ConeHeadZombie.firstAllowedWave = 1

function ConeHeadZombie:init(x, y, challenge)
	BasicZombie.init(self, x, y, challenge)
	
	self:toggleLayer('cone', true)
end

function ConeHeadZombie:hurt(hp, glow)
	if self.helmHp > 0 then
		Sound.playRandom({ 'plastichit' ; 'plastichit2' }, 5)
	end
	
	BasicZombie.hurt(self, hp, glow)
	
	if self.helmDamagePhase == 0 and self.helmHp <= (self.maxHelmHp - 130) then
		self:setHelmDamagePhase(1)
	end if self.helmDamagePhase == 1 and self.helmHp <= (self.maxHelmHp - 260) then
		self:setHelmDamagePhase(2)
	end if self.helmDamagePhase == 2 and self.helmHp <= 0 then
		self:setHelmDamagePhase(3)
	end
end

function ConeHeadZombie:setHelmDamagePhase(phase)
	BasicZombie.setHelmDamagePhase(self, phase)
	
	if phase == 1 then
		self:replaceImage('Zombie_cone1', Reanim.getResource('Zombie_cone2'))
	elseif phase == 2 then
		self:replaceImage('Zombie_cone1', Reanim.getResource('Zombie_cone3'))
	elseif phase == 3 then
		self:toggleLayer('cone', false)
	end
end

return ConeHeadZombie