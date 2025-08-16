local LawnPrepareCutscene = Cutscene:extend('LawnPrepareCutscene')

LawnPrepareCutscene.timeSeedBankStart = 0
LawnPrepareCutscene.timeSeedBankEnd = 250

LawnPrepareCutscene.lawnMowerStart = { 300 ; 250; 200 ; 150 ; 100 ; 50 }
LawnPrepareCutscene.lawnMowerDuration = 250

LawnPrepareCutscene.curve = Curve.QUAD_IN_OUT

function LawnPrepareCutscene:init(challenge)
	Cutscene.init(self, challenge)
	
	self.cutscenePhase = 0
	
	challenge.seeds.y = -challenge.seeds.h
	challenge.seeds:revive()
end

function LawnPrepareCutscene:update(dt)
	Cutscene.update(self, dt)
	
	self.state.seeds.y = math.round(Curve.animate(self.timeSeedBankStart, self.timeSeedBankEnd, self.counter, -self.state.seeds.h, 0, self.curve))
	
	if self.counter >= self.timeSeedBankEnd and self.counter >= self.lawnMowerStart[1] + self.lawnMowerDuration then
		self:finish()
	end
end

return LawnPrepareCutscene