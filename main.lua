utils = require 'utils'
require 'table.clear'

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

local lawn = nil
local seeds = nil
local camera = nil

local cursor = love.mouse.newCursor(love.image.newImageData('resources/cursor.png'))
local hand = love.mouse.newCursor(love.image.newImageData('resources/hand.png'))

function love.load()
	love.mouse.setCursor(cursor)
	
	lawn = Lawn:new()
	seeds = SeedBank:new()
	
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle('rough')
	
	camera = Gamera.new(0, 0, 1880, 720)
	camera:setPosition(240 + 220 + 400, 360)
	
	local PeaShooter = Cache.module(Cache.plants('PeaShooter'))
	local SunFlower = Cache.module(Cache.plants('SunFlower'))
	for i = 1, 5 do
		lawn:plant(SunFlower:new(), 1, i)
		lawn:plant(SunFlower:new(), 2, i)
		lawn:plant(PeaShooter:new(), 3, i)
	end
end

function makeZomby()
	local mX, mY = camera:toWorld(love.mouse.getPosition())
	local zomby = Entity:new(mX - 40, mY - 80)
	-- table.insert(entities, zomby)
	-- zomby.shader = frost
	
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
end

function love.keypressed(key)
	if key == 'return' then
		-- entities[1]:doBlink()
		-- sprite:playAnimation(sprite.animation.name == 'idle' and 'eat' or 'idle')
	end
	if key == 'a' then
		makeZomby()
	end
end

function love.update(dt)
	lawn:update(dt)
end

function drawBottom()
	lawn:draw()
end
function drawHUD()
	seeds:draw(10, 0)
end
function drawTop()
	lawn:drawUnits()
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	camera:draw(drawBottom)
	drawHUD()
	camera:draw(drawTop)
end