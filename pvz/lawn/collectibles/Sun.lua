local Sun = Collectible:extend('Sun')

Sun.scoringDistance = 8
Sun.value = 25

function Sun:init(x, y, mode, bank)
	Collectible.init(self, x, y, mode)
	
	self.bank = bank
	self.board = nil
	
	self.useHand = true
	self.canClick = true
	
	self.transform:setOffset(-40, -40)
	
	self.destX, self.destY = 15, 0
	
	self._nextMoney = nil
end

function Sun:onCollect()
	Collectible.onCollect(self)
	
	Sound.play('points', 10)
	
	if self.bank then
		self.bank.money = (self.bank.money + self.value)
		self._nextMoney = self.bank.money
	end
end
function Sun:onDespawn(collected)
	Collectible.onDespawn(self, collected)
	
	if collected and self.bank then
		self.bank.visualMoney = math.min(self.bank.money, self._nextMoney)
	end
end

return Sun