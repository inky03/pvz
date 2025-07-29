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
Unit = require 'pvz.lawn.Unit'
Plant = require 'pvz.lawn.Plant'
Zombie = require 'pvz.lawn.Zombie'

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
	
	local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
	local PeaShooter = Cache.module(Cache.plants('PeaShooter'))
	local SunFlower = Cache.module(Cache.plants('SunFlower'))
	for i = 1, 5 do
		lawn:spawnUnit(SunFlower:new(), 1, i)
		lawn:spawnUnit(SunFlower:new(), 2, i)
		lawn:spawnUnit(PeaShooter:new(), 3, i)
		lawn:spawnUnit(BasicZombie:new(), 10, i)
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