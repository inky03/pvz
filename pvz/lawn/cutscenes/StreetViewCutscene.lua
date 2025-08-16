local StreetViewCutscene = Cutscene:extend('StreetViewCutscene')

StreetViewCutscene.timePanRightStart = 1500
StreetViewCutscene.timePanRightEnd = 3500
StreetViewCutscene.timePanLeftStart = 4500
StreetViewCutscene.timePanLeftEnd = 6000

StreetViewCutscene.panRightX = (1400 - 800)
StreetViewCutscene.panLeftX = 220

StreetViewCutscene.panCurve = Curve.QUAD_IN_OUT

function StreetViewCutscene:init(challenge)
	Cutscene.init(self, challenge)
	
	challenge.lawn.x = 0
	
	self.houseMessage = self:addElement(Font:new('HouseOfTerror', 28, 0, 500, 800, 50))
	self.houseMessage:setAlignment('center', 'top')
	self.houseMessage:setText(challenge:getHouseMessage())
	
	challenge:placeStreetZombies(challenge.challenge)
end

function StreetViewCutscene:update(dt)
	Cutscene.update(self, dt)
	
	self.state.lawn.x = -Curve.animate(self.timePanLeftStart, self.timePanLeftEnd, self.counter,
		Curve.animate(self.timePanRightStart, self.timePanRightEnd, self.counter, 0, self.panRightX, self.panCurve)
	, self.panLeftX, self.panCurve)
	
	if self.counter >= 2250 then
		self.houseMessage.transform.alpha = math.max(self.houseMessage.transform.alpha - dt * 10, 0)
	end
	
	if self.counter >= 6000 then
		self:finish()
	end
end

function StreetViewCutscene:destroy()
	self.state:clearStreetZombies()
	Cutscene.destroy(self)
end

return StreetViewCutscene