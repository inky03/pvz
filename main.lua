utils = require 'utils'
require 'table.clear'

Gamera = require 'lib.gamera'
class = require 'lib.30log'
xml = require 'lib.xml'

Reanimation = require 'pvz.reanim.Reanimation'
SeedBank = require 'pvz.hud.SeedBank'
Lawn = require 'pvz.lawn.Lawn'
Cache = require 'pvz.Cache'
Signal = require 'pvz.Signal'
Unit = require 'pvz.lawn.Unit'
Plant = require 'pvz.lawn.Plant'
Zombie = require 'pvz.lawn.Zombie'
Projectile = require 'pvz.lawn.Projectile'

math.randomseed(os.clock())

local lawn = nil
local seeds = nil

local cursor = love.mouse.newCursor(love.image.newImageData('resources/cursor.png'))
local hand = love.mouse.newCursor(love.image.newImageData('resources/hand.png'))

windowWidth, windowHeight = love.graphics.getDimensions()
debugMode = false

function love.load()
	love.mouse.setCursor(cursor)
	
	lawn = Lawn:new()
	seeds = SeedBank:new()
	
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle('rough')
	
	camera = Gamera.new(0, 0, 1880, 720)
	camera:setPosition(240 + 220 + 400, 360)
	
	local PeaShooterZombie = Cache.module(Cache.zombies('PeaShooterZombie'))
	local BucketHeadZombie = Cache.module(Cache.zombies('BucketHeadZombie'))
	local ConeHeadZombie = Cache.module(Cache.zombies('ConeHeadZombie'))
	local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
	local FlagZombie = Cache.module(Cache.zombies('FlagZombie'))
	local PeaShooter = Cache.module(Cache.plants('PeaShooter'))
	local SunFlower = Cache.module(Cache.plants('SunFlower'))
	local Repeater = Cache.module(Cache.plants('Repeater'))
	local SnowPea = Cache.module(Cache.plants('SnowPea'))
	for i = 1, 5 do
		lawn:spawnUnit(SunFlower:new(), 1, i)
		lawn:spawnUnit(SunFlower:new(), 2, i)
		lawn:spawnUnit(SnowPea:new(), 3, i)
		lawn:spawnUnit(Repeater:new(), 4, i)
		lawn:spawnUnit(PeaShooter:new(), 5, i)
		lawn:spawnUnit(PeaShooter:new(), 6, i)
		lawn:spawnUnit(BucketHeadZombie:new(), 10, i)
		lawn:spawnUnit(ConeHeadZombie:new(), 11, i)
		lawn:spawnUnit(BasicZombie:new(), 12, i)
		lawn:spawnUnit(BasicZombie:new(), 13, i)
	end
end

function love.update(dt)
	lawn:update(dt)
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	camera:draw(drawBottom)
	drawHUD()
	camera:draw(drawTop)
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