local Unit = Sprite:extend('Unit')

Unit.pvzShader = love.graphics.newShader([[
	uniform float frost;
	uniform float glow;
	
	vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
		vec4 texColor = Texel(tex, texture_coords);
		
		if (frost > 0.) {
			vec3 frostColor = (vec3(texColor.rgb * .6) + vec3(0., 0., texColor.b));
			texColor.rgb = mix(texColor.rgb, frostColor, frost);
		}
		
		return vec4(texColor.rgb + texColor.rgb * glow, texColor.a);
	}
]])

function Unit:init(x, y)
	Sprite.init(self, self:getReanim(), x, y)
	
	self.board, self.boardX, self.boardY = nil, 0, 0
	self.shader = Unit.pvzShader
	self.hitbox = {
		x = 0;
		y = 0;
		w = 80;
		h = 80;
	}
	
	self.hp = 300
	self.animation.speed = random.number(1, 1.33)
end

function Unit:getReanim()
	return 'SunFlower'
end
function Unit:getPreviewAnimation()
	return 'idle'
end
function Unit:getPreviewFrame()
	return 0
end

function Unit:draw(x, y, transforms)
	Sprite.draw(self, x, y, transforms)
	self:debugDraw(x, y)
end

function Unit:debugDraw(x, y)
	x, y = (x or 0), (y or 0)
	
	love.graphics.rectangle('line', x + self.hitbox.x, y + self.hitbox.y, self.hitbox.w, self.hitbox.h)
end

return Unit