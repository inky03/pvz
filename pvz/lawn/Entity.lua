local Entity = Sprite:extend('Entity')

function Entity:init(x, y)
	Sprite.init(self, self:getReanim(), x, y)
	
	self.hitbox = {
		x = 0;
		y = 0;
		w = 80;
		h = 80;
	}
	
	self.hp = 300
end

function Entity:getReanim()
	return 'Zombie'
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