utils = require 'utils'

Gamera = require 'lib.gamera'
class = require 'lib.30log'
xml = require 'lib.xml'

SeedBank = require 'pvz.hud.SeedBank'
Lawn = require 'pvz.lawn.Lawn'
Cache = require 'pvz.Cache'
Signal = require 'pvz.Signal'
Sprite = require 'pvz.Sprite'
Entity = require 'pvz.lawn.Entity'
Plant = require 'pvz.lawn.Plant'

local hud = nil
local lawn = nil
local camera = nil
local entities = {}

local cursor = love.mouse.newCursor(love.image.newImageData('resources/cursor.png'))
local hand = love.mouse.newCursor(love.image.newImageData('resources/hand.png'))

function love.load()
	love.mouse.setCursor(cursor)
	
	frost = love.graphics.newShader([[
		vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
			vec4 texColor = Texel(tex, texture_coords);
			vec4 frost = vec4(texColor.rgb * .6, 1.);
			frost.b += texColor.b;
			return min(frost, texColor.a) * color;
		}
	]])
	
	lawn = Lawn:new()
	hud = SeedBank:new()
	
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle('rough')
	
	camera = Gamera.new(0, 0, 1880, 720)
	camera:setPosition(240 + 220 + 400, 360)
	
	local PeaShooter = require 'pvz.lawn.plants.PeaShooter'
	local test = PeaShooter:new(600, 200)
	test:playAnimation('idle', true)
	table.insert(entities, test)
end

function makeZomby()
	local mX, mY = camera:toWorld(love.mouse.getPosition())
	local zomby = Entity:new(mX - 40, mY - 80)
	table.insert(entities, zomby)
	-- zomby.shader = frost
	sortDrawables()
	
	zomby:playAnimation(random.bool(50) and 'walk' or 'walk2')
	
	zomby:replaceImage('Zombie_cone1', Cache.image(random.bool(50) and 'reanim/Zombie_cone2' or (random.bool(50) and 'reanim/Zombie_cone3' or nil)))
	zomby:replaceImage('Zombie_bucket1', Cache.image(random.bool(50) and 'reanim/Zombie_bucket2' or (random.bool(50) and 'reanim/Zombie_bucket3' or nil)))
	
	zomby:toggleLayer('Zombie_mustache', false)
	zomby:toggleLayer('Zombie_flaghand', false)
	
	zomby:toggleLayer('screendoor', false)
	zomby:toggleLayer('Zombie_outerarm_screendoor', false)
	zomby:toggleLayer('Zombie_innerarm_screendoor', false)
	zomby:toggleLayer('Zombie_innerarm_screendoor_hand', false)
	
	zomby:toggleLayer('cone', random.bool(50))
	zomby:toggleLayer('tongue', random.bool(50))
	zomby:toggleLayer('Zombie_duckytube', random.bool(50))
	zomby:toggleLayer('bucket', zomby:layerIsHidden('cone') and random.bool(50) or false)
	
	zomby.animation.speed = random.number(1, 1.25)
end

function love.keypressed(key)
	if key == 'return' then
		entities[1]:doBlink()
		-- sprite:playAnimation(sprite.animation.name == 'idle' and 'eat' or 'idle')
	end
	if key == 'a' then
		makeZomby()
	end
end

function love.update(dt)
	for _, sprite in ipairs(entities) do
		sprite:update(dt)
	end
end

function sortDrawables()
	table.sort(entities, function(a, b) return (a.y < b.y) end)
end

function drawBottom()
	lawn:draw()
end

function drawTop()
	for _, sprite in ipairs(entities) do
		sprite:draw(sprite.x, sprite.y)
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	camera:draw(drawBottom)
	hud:draw()
	camera:draw(drawTop)
end