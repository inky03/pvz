local DayLawn = Cache.module('pvz.lawn.stages.DayLawn')
local DayChallenge = Challenge:extend('DayChallenge')

local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local ConeHeadZombie = Cache.module(Cache.zombies('ConeHeadZombie'))
local BucketHeadZombie = Cache.module(Cache.zombies('BucketHeadZombie'))
local PoleVaulterZombie = Cache.module(Cache.zombies('PoleVaulterZombie'))

DayChallenge.adventureIds = { 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 }
DayChallenge.lawn = DayLawn

function DayChallenge:init(challenge)
	Challenge.init(self, challenge)
end

function DayChallenge:getZombies(challenge)
	local zombies = {
		[1]	 = { BasicZombie };
		[2]	 = { BasicZombie };
		[3]	 = { BasicZombie; ConeHeadZombie };
		[4]	 = { BasicZombie; ConeHeadZombie };
		[5]	 = { BasicZombie; ConeHeadZombie };
		[6]	 = { BasicZombie; ConeHeadZombie; PoleVaulterZombie };
		[7]	 = { BasicZombie; ConeHeadZombie; PoleVaulterZombie };
		[8]	 = { BasicZombie; ConeHeadZombie; BucketHeadZombie };
		[9]	 = { BasicZombie; ConeHeadZombie; BucketHeadZombie; PoleVaulterZombie };
		[10] = { BasicZombie; ConeHeadZombie; BucketHeadZombie; PoleVaulterZombie };
	}
	
	return (zombies[challenge] or { BasicZombie })
end

function DayChallenge:getWaveCount(challenge)
	local counts = {
		[1] = 4;	 [2] = 6;	 [3] = 8;	 [4] = 10;	 [5] = 8;
		[6] = 10;	 [7] = 20;	 [8] = 10;	 [9] = 20;	 [10] = 20;
	}
	
	return (counts[challenge] or 10)
end

return DayChallenge