local Entity = Sprite:extend('Entity')

function Entity:init(x, y)
	Sprite.init(self, self:getReanim(), x, y)
	
	self.board, self.boardX, self.boardY = nil, 0, 0
	self.hitbox = {
		x = 0;
		y = 0;
		w = 80;
		h = 80;
	}
	
	self.hp = 300
	self.animation.speed = random.number(.75, 1.25)
end

function Entity:getReanim()
	return 'Zombie'
end
function Entity:getPreviewAnimation()
	return 'idle'
end
function Entity:getPreviewFrame()
	return 0
end

function Entity:draw(x, y, transforms)
	self.super.draw(self, x, y, transforms)
	self:debugDraw(x, y)
end

function Entity:debugDraw(x, y)
	x, y = (x or 0), (y or 0)
	
	love.graphics.rectangle('line', x + self.hitbox.x, y + self.hitbox.y, self.hitbox.w, self.hitbox.h)
end

return Entity