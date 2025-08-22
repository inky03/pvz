local NightPool = Cache.module('pvz.lawn.stages.NightPool')
local FogChallenge = Challenge:extend('FogChallenge')

local FogEffect = Cache.module('pvz.lawn.stages.objects.FogEffect')

local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))

FogChallenge.adventureIds = { 31; 32; 33; 34; 35; 36; 37; 38; 39; 40 }
FogChallenge.lawn = NightPool
FogChallenge.fogReturnTime = 2000
FogChallenge.fogIntroReturnTime = 200

function FogChallenge:init(challenge)
	Challenge.init(self, challenge)
	
	self.animateFog = false
	self.fogBlownCountdown = self.fogReturnTime
	self.fogColumns = self:getFogColumns(challenge)
	
	self.fog = self:addElement(FogEffect:new(self.lawn, self.fogColumns), self:indexOf(self.lawn) + 1)
	self.fog.drawToTop = true
	
	self.fogMaxOffset = (1065 - 220 - self.fogColumns * self.lawn.tileSize.x)
	self.fog.x = self.fogMaxOffset
end

function FogChallenge:startChallenge(challenge)
	Challenge.startChallenge(self, challenge)
	self.animateFog = true
end

function FogChallenge:update(dt)
	Challenge.update(self, dt)
	
	if self.animateFog then
		local fogTime = (self.challengeStarted and self.fogReturnTime or self.fogIntroReturnTime)
		
		self.fogBlownCountdown = math.max(self.fogBlownCountdown - dt * Constants.tickPerSecond, 0)
		self.fog.x = Curve.animate(fogTime, 0, self.fogBlownCountdown, self.fogMaxOffset, 0, Curve.QUAD_OUT)
	end
end

function FogChallenge:getZombies(challenge)
	local zombies = {
		[31] = { BasicZombie };
	}
	
	return (zombies[challenge] or { BasicZombie })
end
function FogChallenge:getWaveCount(challenge)
	local counts = {
		[31] = 10;	[32] = 20;	[33] = 10;	[34] = 20;	[35] = 20;
		[36] = 10;	[37] = 20;	[38] = 10;	[39] = 20;	[40] = 20;
	}
	
	return (counts[challenge] or 10)
end
function FogChallenge:getFogColumns(challenge)
	local columns = {
		[31] = 3;	[32] = 4;	[33] = 4;	[34] = 4;	[35] = 4;
		[36] = 4;	[37] = 5;	[38] = 5;	[39] = 5;	[40] = 0;
	}
	
	return (columns[challenge] or 4)
end
function FogChallenge:getFlags(challenge)
	local flags = Challenge.getFlags(self, challenge)
	flags.fallingSun = false
	return flags
end
function FogChallenge:getHouseMessage(challenge)
	return Strings:get('PLAYERS_BACKYARD', {PLAYER = username})
end

return FogChallenge