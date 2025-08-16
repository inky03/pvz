require 'import'

trace('PVZ')

gameWidth, gameHeight = love.graphics.getDimensions()
hoveringElement = nil
accumulator = 0

local gc = 0
local objs = 0
local stats = nil
local gcTimer = 0
local fpsCount = 0
local drawtime = {}

function love.load()
	debugMode = flags.debugMode
	math.randomseed(os.clock())
	reloadCursors()
	
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle('rough')
	love.mouse.setCursor(cursors.pointer)
	-- love.window.setFullscreen(true, 'desktop')
	
	game = UIContainer:new(0, 0, gameWidth, gameHeight)
	level = game:addElement(Cache.module('pvz.lawn.challenges.PoolChallenge'):new(21))
	debugInfo = Font:new('Pico12', 9, 0, 0, 120, 60)
	
	debugCanvas = love.graphics.newCanvas(220, 200)
	
	--[[
	grasswalk = love.audio.newSource('resources/love/music/grasswalk.mp3', 'stream')
	grasswalk:setLooping(true)
	grasswalk:play()
	]]
end

function love.mousepressed(mouseX, mouseY, button, isTouch, presses)
	local mouseX, mouseY = windowToGame(mouseX, mouseY)
	updateHover(mouseX, mouseY)
	if hoveringElement then hoveringElement:mousePressed(mouseX, mouseY, button, isTouch, presses) end
end
function love.mousereleased(mouseX, mouseY, button, isTouch, presses)
	local mouseX, mouseY = windowToGame(mouseX, mouseY)
	updateHover(mouseX, mouseY)
	if hoveringElement then hoveringElement:mouseReleased(mouseX, mouseY, button, isTouch, presses) end
end
function love.mousemoved(mouseX, mouseY, deltaX, deltaY, touch)
	local mouseX, mouseY = windowToGame(mouseX, mouseY)
	updateHover(mouseX, mouseY)
	if hoveringElement then hoveringElement:mouseMoved(mouseX, mouseY, deltaX, deltaY, touch) end
end

function updateHover(mouseX, mouseY)
	local prevHovering = hoveringElement
	hoveringElement = game:getHoveringElement(mouseX, mouseY)
	
	if prevHovering ~= hoveringElement and prevHovering then prevHovering:setHovering(false) end
end
function updateCursor()
	if hoveringElement then hoveringElement:setHovering(true) end
	if hoveringElement and hoveringElement.useHand and hoveringElement:canBeClicked() then
		love.mouse.setCursor(cursors.hand)
	else
		love.mouse.setCursor(cursors.pointer)
	end
end
function reloadCursors()
	cursors = {
		pointer = love.mouse.newCursor(love.image.newImageData('resources/cursor.png'));
		hand = love.mouse.newCursor(love.image.newImageData('resources/hand.png'), 4);
	}
end

function love.update(dt)
	if flags.useFrameskip then
		accumulator = (accumulator + dt * Constants.tickPerSecond)
		
		if accumulator >= 1 then
			for i = 1, math.floor(math.min(flags.maxFrameskip, accumulator)) do
				game:update(1 / Constants.tickPerSecond)
			end
			accumulator = (accumulator % 1)
		end
	else
		game:update(dt)
	end
	
	updateCursor()
	
	gcTimer = (gcTimer - dt)
end

function love.draw()
	love.graphics.setCanvas(debugCanvas)
	love.graphics.clear()
	love.graphics.setCanvas()
	
	local ratio = getAspectRatio()
	local winW, winH = love.graphics.getDimensions()
	local gameOffsetX, gameOffsetY = windowToGame(0, 0)
	
	love.graphics.push()
	love.graphics.setColor(1, 1, 1)
	love.graphics.scale(ratio, ratio)
	love.graphics.translate(-gameOffsetX, -gameOffsetY)
	
	game:draw(game.x, game.y)
	game:drawTop(game.x, game.y)
	
	love.graphics.pop()
	love.graphics.setColor(0, 0, 0)
	
	local borderW, borderH = (gameOffsetX * ratio), (gameOffsetY * ratio)
	local wr, hr = (winW / gameWidth), (winH / gameHeight)
	if wr > hr then
		love.graphics.rectangle('fill', 0, -borderH, -borderW, gameHeight * ratio)
		love.graphics.rectangle('fill', winW + borderW, -borderH, -borderW, gameHeight * ratio)
	elseif wr < hr then
		love.graphics.rectangle('fill', -borderW, 0, gameWidth * ratio, -borderH)
		love.graphics.rectangle('fill', -borderW, winH + borderH, gameWidth * ratio, -borderH)
	end
	
	game:drawWindow()
	drawDebug()
end

function getAspectRatio()
	local winW, winH = love.graphics.getDimensions()
	return math.min(
		winW / gameWidth,
		winH / gameHeight
	)
end
function windowToGame(x, y)
	local ratio = getAspectRatio()
	local winW, winH = love.graphics.getDimensions()
	return (math.round(x - (winW - gameWidth * ratio) * .5) / ratio), (math.round(y - (winH - gameHeight * ratio) * .5) / ratio)
end

function drawDebug()
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
	local fps = math.round((fpsCount + #drawtime) / 2)
	fpsCount = #drawtime
	
	love.graphics.setCanvas(debugCanvas)
	
	local text = ('%d fps\n%d mb\n%d objects\n%d drawcalls'):format(fps, ((stats.texturememory / 1024) + gc) / 1024, objs, stats.drawcalls)
	love.graphics.setColor(1, 1, 1)
	debugInfo:setText(text)
	debugInfo:draw(5, 5)
	
	love.graphics.setCanvas()
	
	love.graphics.setColor(0, 0, 0)
	for ang = 0, 7 do
		local rad = (ang * math.pi * .25)
		love.graphics.draw(debugCanvas, math.round(math.cos(rad)), math.round(math.sin(rad)))
	end
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(debugCanvas)
end