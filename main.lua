utils = require 'utils'
require 'table.clear'

class = require 'lib.30log'
xml = require 'lib.xml'

Cache = require 'pvz.Cache'
Signal = require 'pvz.Signal'
Constants = require 'pvz.Constants'
UIContainer = require 'pvz.hud.UIContainer'

Reanimation = require 'pvz.reanim.Reanimation'

Unit = require 'pvz.lawn.Unit'
Plant = require 'pvz.lawn.Plant'
Zombie = require 'pvz.lawn.Zombie'
Projectile = require 'pvz.lawn.Projectile'
Challenge = require 'pvz.lawn.Challenge'

math.randomseed(os.clock())

game = nil
level = nil

local pointer = love.mouse.newCursor(love.image.newImageData('resources/cursor.png'))
local hand = love.mouse.newCursor(love.image.newImageData('resources/hand.png'), 4)

windowWidth, windowHeight = love.graphics.getDimensions()
hoveringElement = nil
debugMode = false

local gc = 0
local objs = 0
local stats = nil
local gcTimer = 0
local drawtime = {}

function love.load()
	love.mouse.setCursor(pointer)
	
	game = UIContainer:new(0, 0, 1400, 600)
	level = game:addElement(Cache.module('pvz.lawn.challenges.DayChallenge'):new(3))
	
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle('rough')
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
	
	gcTimer = (gcTimer - dt)
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	
	game:draw(game.x, game.y)
	game:drawTop(game.x, game.y)
	
	updateDebug()
end

function updateDebug()
	if gcTimer < 0 then
		gcTimer = (gcTimer + 1 / 15)
		gc = collectgarbage('count')
		stats = love.graphics.getStats()
		objs = game:getCount()
	end
	
	local time = love.timer.getTime()
	table.insert(drawtime, time)
	while drawtime[1] < time - 1 do
		table.remove(drawtime, 1)
	end
	
	outlineText(('%d fps\n%d mb\n%d objects\n%d drawcalls'):format(#drawtime, ((stats.texturememory / 1024) + gc) / 1024, objs, stats.drawcalls), 8, 8)
end

function outlineText(text, x, y, r, g, b, a)
	local rr, gg, bb, aa = love.graphics.getColor()
	
	love.graphics.setColor(r or 0, g or 0, b or 0, a or 1)
	for d = 0, 3, 1 do
		local dx, dy = math.cos(d * math.pi * .5), math.sin(d * math.pi * .5)
		love.graphics.print(text, x + dx, y + dy)
	end
	
	love.graphics.setColor(rr, gg, bb, aa)
	love.graphics.print(text, x, y)
end