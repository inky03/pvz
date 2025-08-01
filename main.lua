utils = require 'utils'
require 'table.clear'

class = require 'lib.30log'
xml = require 'lib.xml'

Cache = require 'pvz.Cache'
UIContainer = require 'pvz.hud.UIContainer'

Reanimation = require 'pvz.reanim.Reanimation'
SeedBank = require 'pvz.hud.SeedBank'
Lawn = require 'pvz.lawn.Lawn'
Signal = require 'pvz.Signal'
Unit = require 'pvz.lawn.Unit'
Plant = require 'pvz.lawn.Plant'
Zombie = require 'pvz.lawn.Zombie'
Projectile = require 'pvz.lawn.Projectile'

math.randomseed(os.clock())

game = nil
lawn = nil
seeds = nil

local pointer = love.mouse.newCursor(love.image.newImageData('resources/cursor.png'))
local hand = love.mouse.newCursor(love.image.newImageData('resources/hand.png'), 4)

windowWidth, windowHeight = love.graphics.getDimensions()
hoveringElement = nil
debugMode = false -- true

function love.load()
	love.mouse.setCursor(pointer)
	
	game = UIContainer:new(0, 0, 1880, 720)
	lawn = game:addElement(Lawn:new(0, 0))
	seeds = game:addElement(SeedBank:new(10, 0))
	
	lawn:setPosition(-240 - 220, -60)
	
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle('rough')
	
	local BasicZombie = Cache.module(Cache.zombies('BasicZombie'))
	for i = 1, 5 do
		lawn:spawnUnit(BasicZombie:new(), 11, i)
		lawn:spawnUnit(BasicZombie:new(), 12, i)
		lawn:spawnUnit(BasicZombie:new(), 13, i)
	end
end

function love.mousepressed(mouseX, mouseY, button, isTouch, presses)
	updateHover(mouseX, mouseY)
	if hoveringElement then hoveringElement:mousePressed(mouseX, mouseY, button, isTouch, presses) end
	updateCursor()
end
function love.mousereleased(mouseX, mouseY, button, isTouch, presses)
	updateHover(mouseX, mouseY)
	if hoveringElement then hoveringElement:mouseReleased(mouseX, mouseY, button, isTouch, presses) end
	updateCursor()
end
function love.mousemoved(mouseX, mouseY, deltaX, deltaY, touch)
	updateHover(mouseX, mouseY)
	if hoveringElement then hoveringElement:mouseMoved(mouseX, mouseY, deltaX, deltaY, touch) end
	updateCursor()
end

function updateHover(mouseX, mouseY)
	local prevHovering = hoveringElement
	hoveringElement = game:getHoveringElement(game.x, game.y, mouseX, mouseY)
	
	if prevHovering ~= hoveringElement and prevHovering then prevHovering:setHovering(false) end
end
function updateCursor()
	if hoveringElement then hoveringElement:setHovering(true) end
	if hoveringElement and hoveringElement.useHand and hoveringElement:canBeClicked() then
		love.mouse.setCursor(hand)
	else
		love.mouse.setCursor(pointer)
	end
end

function love.update(dt)
	game:update(dt)
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	
	game:draw(game.x, game.y)
	game:drawTop(game.x, game.y)
end