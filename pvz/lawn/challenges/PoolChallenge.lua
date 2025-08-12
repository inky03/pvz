local DayPool = Cache.module('pvz.lawn.stages.DayPool')
local PoolChallenge = Challenge:extend('DayChallenge')

local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))

PoolChallenge.adventureIds = { 21; 22; 23; 24; 25; 26; 27; 28; 29; 30 }
PoolChallenge.lawn = DayPool

function PoolChallenge:init(challenge)
	Challenge.init(self, challenge)
end

function PoolChallenge:getZombies(challenge)
	local zombies = {
		[21] = { BasicZombie };
	}
	
	return (zombies[challenge] or { BasicZombie })
end

function PoolChallenge:getWaveCount(challenge)
	local counts = {
		[21] = 10;	 [22] = 20;	 [23] = 20;	 [24] = 30;	 [25] = 20;
		[26] = 20;	 [27] = 30;	 [28] = 20;	 [29] = 30;	 [30] = 30;
	}
	
	return (counts[challenge] or 10)
end

function PoolChallenge:getTitle(challenge)
	return ('Level %d-%d'):format(3, challenge - 20)
end

return PoolChallenge