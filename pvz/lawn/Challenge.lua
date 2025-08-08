local Lawn = Cache.module('pvz.lawn.Lawn')
local SeedBank = Cache.module('pvz.hud.SeedBank')
local Challenge = UIContainer:extend('Challenge')
local FlagZombie = Cache.module(Cache.zombies('FlagZombie'))
local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
local WaveMeter = Cache.module('pvz.hud.WaveMeter')
local Sun = Cache.module('pvz.lawn.collectibles.Sun')

Challenge.wavesPerFlag = 10
Challenge.maxZombiesInWave = 50

Challenge.adventureIds = {}

Challenge.lawn = Lawn

function Challenge:init(challenge)
	UIContainer.init(self, 0, 0, game.w, game.h)
	
	self.flagWaves = {}
	self.waveZombies = {}
	self.currentWave = 0
	self.currentWaveZombies = {}
	self.currentWaveHealth = -1
	self.healthToNextWave = -1
	self.startWaveHealth = 0
	self.hugeWaveCountdown = 0
	self.challengeCompleted = false
	
	self.sunCountdown = (Constants.sunCountdown + random.int(Constants.sunCountdownRange))
	self.sunsFallen = 0
	
	self.challenge = (challenge or 1)
	self.challengeZombies = self:getZombies(challenge)
	self.challengeTitle = self:getTitle(challenge)
	self.waves = self:getWaveCount(challenge)
	self.flags = self:getFlags(challenge)
	self:initWaves()
	
	self.lawn = self:addElement(self.lawn:new(self, 0, 0))
	self.seeds = self:addElement(SeedBank:new(self.lawn, 10, 0, self.flags.startingSun))
	
	self.waveMeter = self:addElement(WaveMeter:new())
	self.waveMeter:setPosition(gameWidth - 42 - self.waveMeter.w, gameHeight - 25)
	self.waveMeter:setFlags(self.flagWaves)
	self.waveMeter.drawToTop = true
	self.waveMeter.visible = false
	self.waveMeterWidth = 0
	
	self.challengeText = self:addElement(Font:new('HouseOfTerror', 16, gameWidth - 300 - 14, gameHeight - 29, 300))
	self.challengeText:setLayerColor('Main', 223 / 255, 186 / 255, 97 / 255)
	self.challengeText:setAlignment('right')
	self.challengeText:setText(self.challengeTitle)
	
	self.collectibles = self:addElement(UIContainer:new(0, 0, gameWidth, gameHeight))
	self.collectibles.drawToTop = true
	self.collectibles.canClick = false
	
	self.lawn:setPosition(-220, 0)
	
	self.zombieSince = 0
	self.zombieCountdown = Constants.zombieCountdownFirstWave
	self.zombieCountdownStart = self.zombieCountdown
	
	self.debugInfo = Font:new('Pico12', 9, 0, 0, 400)
	self.challengeDebug = true
	
	trace('Challenge ' .. self.challenge)
end

function Challenge:initWaves()
	table.clear(self.flagWaves)
	table.clear(self.waveZombies)
	
	for wave = 1, self.waves do
		local zombiePoints = self:pointsOnWave(wave)
		
		if not self:zombiePickerRoutine(wave, zombiePoints) then
			trace('Couldn\'t place any zombies for wave ' .. wave)
		end
		
		if self:isFlagWave(wave) then
			table.insert(self.flagWaves, wave)
		end
	end
end
function Challenge:zombiePickerRoutine(wave, maxPoints)
	if self:isFlagWave(wave) then
		-- print('add flag zombys ' .. wave)
		
		local plainZombies = math.min(maxPoints, 8)
		maxPoints = (maxPoints * 2.5)
		
		for i = 1, plainZombies do
			maxPoints = (maxPoints - self:queueZombie(wave, BasicZombie).value)
		end
		maxPoints = (maxPoints - self:queueZombie(wave, FlagZombie).value)
	end
	
	local introZombie, spawnIntro = self:getIntroZombie(self.challenge), false
	if wave == math.floor(self.waves / 2) then
		spawnIntro = true
	end
	if spawnIntro and introZombie then
		maxPoints = (maxPoints - self:queueZombie(wave, introZombie).value)
	end
	
	local points, zombs = maxPoints, self.maxZombiesInWave
	while points > 0 and zombs > 0 do
		local zombie = self:pickZombie(wave, points)
		
		if zombie then
			zombs = (zombs - 1)
			points = (points - math.max(zombie.value, 1))
			self:queueZombie(wave, zombie)
		else
			break
		end
	end
	
	if self.waveZombies[wave] then
		return #self.waveZombies[wave]
	else
		self.waveZombies[wave] = {}
		return nil
	end
end
function Challenge:pickZombie(wave, maxPoints)
	local choices, weights = {}, {}
	
	for _, zombie in ipairs(self.challengeZombies) do
		if zombie.value > 0 and zombie.value <= maxPoints and zombie.firstAllowedWave <= wave then
			table.insert(choices, zombie)
			table.insert(weights, zombie.pickWeight)
		end
	end
	
	return random.pickWeighted(choices, weights)
end
function Challenge:queueZombie(wave, zombie)
	local zombies = (self.waveZombies[wave] or {})
	
	-- print('queued ' .. tostr(zombie) .. ' in wave ' .. wave)
	table.insert(zombies, zombie)
	
	self.waveZombies[wave] = zombies
	
	return zombie
end

function Challenge:update(dt)
	UIContainer.update(self, dt)
	
	self:updateSun(dt)
	self:updateChallenge(dt)
	self:updateWaveMeter(dt)
end
function Challenge:updateSun(dt)
	if not self.flags.fallingSun then return end
	
	self.sunCountdown = (self.sunCountdown - dt * Constants.tickPerSecond)
	
	if self.sunCountdown < 0 then
		self.sunsFallen = (self.sunsFallen + 1)
		self.sunCountdown = math.min(Constants.sunCountdownMax, Constants.sunCountdown + self.sunsFallen * 10) + random.int(Constants.sunCountdownRange)
		self:spawnSun()
	end
end
function Challenge:spawnSun()
	return self.collectibles:addElement(Sun:new(random.int(100, 649), 60, 'rain', self.seeds))
end
function Challenge:updateChallenge(dt)
	if self.challengeCompleted then return end
	
	self.currentWaveHealth = self:getCurrentWaveHealth()
	
	local nextWaveIsFlag = self:isFlagWave(self.currentWave + 1)
	local isFinalWave = self:isFinalWave(self.currentWave)
	local canSkipWave = (
		(self.currentWaveHealth <= self.healthToNextWave and not nextWaveIsFlag and not self:isFlagWave(self.currentWave) and self.currentWave > 0) or
		(self.currentWaveHealth <= 0 and self.currentWave > 0)
	)
	
	if isFinalWave then
		if canSkipWave then
			self.challengeCompleted = true
		else
			return
		end
	end
	
	if self.hugeWaveCountdown > 0 then
		local prevCountdown = self.hugeWaveCountdown
		self.hugeWaveCountdown = (self.hugeWaveCountdown - dt * Constants.tickPerSecond)
		if self.hugeWaveCountdown <= 725 and prevCountdown > 725 then
			Sound.play('hugewave')
		end
		if self.hugeWaveCountdown <= 0 then
			self.zombieCountdown = 0
		else
			return
		end
	end
	
	self.zombieSince = (self.zombieSince + dt * Constants.tickPerSecond)
	self.zombieCountdown = (self.zombieCountdown - dt * Constants.tickPerSecond)
	
	if self.zombieCountdown > 200 and canSkipWave and self.zombieSince >= Constants.zombieCountdownMin then
		self.zombieCountdown = 200
	elseif self.zombieCountdown <= 5 then
		if not self.hugeWaveComing and nextWaveIsFlag then
			self.hugeWaveCountdown = 750
			self.hugeWaveComing = true
			return
		end
	end
	
	if self.zombieCountdown <= 0 then
		self.hugeWaveComing = false
		self:startNextWave()
	end
end
function Challenge:updateWaveMeter(dt)
	if self.currentWave == 0 then return end
	
	local totalWidth = 150
	local hasFlags = (#self.flagWaves > 0)
	local wavesPerFlag = (math.min(self.wavesPerFlag, self.waves))
	
	if hasFlags then
		totalWidth = (totalWidth - 12 * self.waves / wavesPerFlag)
	end
	
	local waveLength = math.floor(totalWidth / (self.waves - 1))
	local curWaveLength = math.floor((self.currentWave - 1) * totalWidth / (self.waves - 1))
	local nextWaveLength = math.floor(self.currentWave * totalWidth / (self.waves - 1))
	
	if hasFlags then
		local extraLength = math.floor(self.currentWave / wavesPerFlag) * 12
		nextWaveLength = (nextWaveLength + extraLength)
		curWaveLength = (curWaveLength + extraLength)
	end
	
	local zombieFraction = math.remap(self.zombieCountdown, self.zombieCountdownStart, 0, 0, 1)
	if self.healthToNextWave > -1 then
		local healthFraction = math.clamp(math.remap(self.currentWaveHealth, self.startWaveHealth, self.healthToNextWave, 0, 1), 0, 1)
		zombieFraction = math.max(healthFraction, zombieFraction)
	end
	
	local length = math.clamp(math.lerp(curWaveLength, nextWaveLength, zombieFraction), 1, 150)
	local delta = (length - self.waveMeterWidth)
	if delta > waveLength then
		self.waveMeterWidth = math.min(self.waveMeterWidth + dt * Constants.tickPerSecond / 5, length)
	elseif delta > 0 then
		self.waveMeterWidth = math.min(self.waveMeterWidth + dt * Constants.tickPerSecond / 20, length)
	end
	
	self.waveMeter.progress = (self.waveMeterWidth / 150 * 100)
end
function Challenge:getCurrentWaveHealth()
	local waveHealth = 0
	if self.currentWaveZombies then
		for _, zombie in ipairs(self.currentWaveZombies) do
			if zombie.state ~= 'dead' then
				waveHealth = (waveHealth + math.max(zombie.hp, 0))
			end
		end
	end
	return waveHealth
end
function Challenge:getSpawnedZombies()
	local zombies = {}
	lambda.foreach(self.lawn.units, function(unit)
		if unit:instanceOf(Zombie) then
			table.insert(zombies, unit)
		end
	end)
	return zombies
end

function Challenge:startNextWave()
	if self.currentWave == 0 then
		self.waveMeter.visible = true
		self.challengeText.x = (gameWidth - 300 - 201)
		
		Sound.play('awooga')
	end
	
	self.zombieSince = 0
	self.currentWave = (self.currentWave + 1)
	self.zombieCountdown = (Constants.zombieCountdown + random.int(0, Constants.zombieCountdownRange))
	self.zombieCountdownStart = self.zombieCountdown
	self.waveMeter.currentWave = self.currentWave
	
	-- trace('wave ' .. self.currentWave)
	
	local waveZombies = self.waveZombies[self.currentWave]
	if waveZombies then
		self.currentWaveZombies = self:attemptSpawnZombies(waveZombies)
	else
		trace('No zombies for wave ' .. self.currentWave)
		self.currentWaveZombies = nil
	end
	
	self.startWaveHealth = self:getMaxWaveHealth(self.currentWave)
	if self:isFlagWave(self.currentWave) then
		Sound.play('siren')
	end
	if self:isFinalWave(self.currentWave) then
		self.healthToNextWave = 0
		self:showFinalWaveMessage()
	else
		self.healthToNextWave = (self.startWaveHealth * random.number(.5, .65))
	end
end
function Challenge:attemptSpawnZombies(zombies)
	local spawnZombies = {}
	for _, zombie in ipairs(zombies) do
		local newZombie = self:attemptSpawnZombie(zombie)
		if newZombie then table.insert(spawnZombies, newZombie) end
	end
	return spawnZombies
end
function Challenge:attemptSpawnZombie(zombie)
	local spawnRow = self:pickRowForZombie(zombie)
	if spawnRow then
		return self:spawnZombie(zombie:new(0, 0, self), spawnRow)
	else
		print('couldn\'t spawn zombie ' .. tostr(zombie) .. '!')
		return nil
	end
end
function Challenge:spawnZombie(zombie, row)
	self.lawn:spawnUnit(zombie, self.lawn.size.x, row)
	zombie:setPosition(220 + 800 + 20 + zombie.getSpawnOffset(), zombie.y)
	zombie:updateBoardPosition()
	
	return zombie
end
function Challenge:pickRowForZombie(zombie)
	local rows, weights = {}, {}
	for row = 1, self.lawn.size.y do
		if self:zombieCanSpawnInRow(zombie, row) then
			table.insert(rows, row)
			table.insert(weights, 1)
			
			-- mowed 1 wave ago -> 0.01
			-- mowed 2 waves ago -> 0.5
		end
	end
	return random.pickWeighted(rows, weights)
end
function Challenge:zombieCanSpawnInRow(zombie, row)
	return Zombie:canBeSpawnedAt(self.lawn, self.lawn.size.x, row)
end
function Challenge:showFinalWaveMessage()
	local finalWave = Reanimation:new('FinalWave', 0, 30)
	finalWave.animation.onFrame:add(function(animation) if animation.frame == 7 then Sound.play('finalwave') end end)
	finalWave.animation.onFinish:add(function(_) finalWave:destroy() end)
	finalWave.animation:setLoop(false)
	finalWave.drawToTop = true
	self:addElement(finalWave)
end

function Challenge:drawWindow()
	if not self.visible then return end
	
	if debugMode or self.debug or self.challengeDebug then
		love.graphics.setCanvas(debugCanvas)
		
		local debugString = ('challenge %d\n'):format(self.challenge)
		if self.challengeCompleted then
			debugString = (debugString .. 'CLEAR!')
		elseif self:isFinalWave(self.currentWave) then
			debugString = (debugString .. (
				'wave: %d / %d (final wave)'
			):format(self.currentWave, self.waves))
		elseif self.currentWave == 0 then
			debugString = (debugString .. (
				'wave: NA / %d\n' ..
				'zombie health: before first wave\n' ..
				'wave countdown: %.0f / %.0f (%.0f%%)'
			):format(
				self.waves,
				self.zombieCountdown, self.zombieCountdownStart, (100 - self.zombieCountdown / self.zombieCountdownStart * 100)
			))
		else
			debugString = (debugString .. (
				'wave: %d / %d\n' ..
				'time since last wave: %.0f %s\n' ..
				'wave countdown: %.0f / %.0f (%.0f%%)'
			):format(
				self.currentWave, self.waves,
				self.zombieSince, (self.zombieSince < Constants.zombieCountdownMin and '(too soon)' or ''),
				self.zombieCountdown, self.zombieCountdownStart, (100 - self.zombieCountdown / self.zombieCountdownStart * 100)
			))
		end
		
		if not self.challengeCompleted then
			if self.currentWave > 0 then
				local healthFraction = math.remap(self.currentWaveHealth, self.startWaveHealth, self.healthToNextWave, 0, 100)
				debugString = (debugString ..
					('\nzombie health: %d -> %d (%.0f%%)'):format(self.currentWaveHealth, self.healthToNextWave, healthFraction)
				)
			end
			
			if self.hugeWaveCountdown > 0 then
				debugString = (
					debugString ..
					('\nhuge wave countdown: %.0f'):format(self.hugeWaveCountdown)
				)
			end
			
			debugString = (
				debugString .. (
					'\n\nSUN DEBUG\n' ..
					'sun countdown: %.0f\n' ..
					'sun phase: %d'
				):format(
					self.sunCountdown,
					self.sunsFallen
				)
			)
		end
		
		local text = ('ZOMBIE SPAWNING DEBUG\n' .. debugString)
		love.graphics.setColor(1, 1, 1)
		self.debugInfo:setText(text)
		self.debugInfo:draw(5, 65)
		
		love.graphics.setCanvas()
	end
	
	UIContainer.drawWindow(self)
end

function Challenge:getWaveCount(challenge)
	return 10
end
function Challenge:getZombies(challenge)
	return {}
end
function Challenge:getFlags(challenge)
	return {
		startingSun = 50;
		fallingSun = true;
	}
end
function Challenge:getTitle(challenge)
	return ('Challenge %d'):format(challenge)
end

function Challenge:getIntroZombie(challenge)
	return lambda.find(self.challengeZombies, function(zombie) return zombie.startingLevel == challenge end)
end
function Challenge:pointsOnWave(wave)
	return (wave / 3 + 1)
end
function Challenge:isFlagWave(wave)
	return (wave % self.wavesPerFlag == 0 or self:isFinalWave(wave))
end
function Challenge:isFinalWave(wave)
	return (wave == self.waves)
end
function Challenge:getMaxWaveHealth(wave)
	local waveHealth = 0
	if self.waveZombies[wave] then
		for _, zombie in ipairs(self.waveZombies[wave]) do
			waveHealth = (waveHealth + zombie.maxHp)
		end
	end
	return waveHealth
end

return Challenge