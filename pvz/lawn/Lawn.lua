local Lawn = class('Lawn')

function Lawn:init()
	self.image = Cache.image('images/background1')
	
	self.topLeft = {
		x = 460 + 40;
		y = 60 + 80;
	}
	self.boardSpacing = {
		x = 80;
		y = 100;
	}
	self.boardSize = {
		x = 9;
		y = 5;
	}
	
	self.width, self.height = self.image:getPixelDimensions()
end

function Lawn:draw(x, y)
	local x, y = (x or 0), (y or 0)
	love.graphics.draw(self.image, x + (1880 - self.width) * .5, y + (720 - self.height) * .5)
	
	self:debugDraw(x, y)
end

function Lawn:debugDraw(x, y)
	for col = 1, self.boardSize.y do
		for row = 1, self.boardSize.x do
			local x, y = self:getTilePosition(col, row)
			love.graphics.rectangle('line', x, y, self.boardSpacing.x, self.boardSpacing.y)
		end
	end
end

function Lawn:getTilePosition(row, col)
	return (self.topLeft.x + (col - 1) * self.boardSpacing.x), (self.topLeft.y + (row - 1) * self.boardSpacing.y)
end

return Lawn