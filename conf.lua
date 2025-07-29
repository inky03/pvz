function love.conf(t)
	t.window.resizable = false
	t.accelerometerjoystick = false

	t.window.title = 'Plants Vs. Zombies'
	t.window.identity = 'pvz-love'
	t.identity = 'pvz-love'
	t.release = false
	t.console = true

	t.modules.physics = false
	t.modules.video = false
	t.modules.thread = false
	t.modules.event = true
	t.modules.timer = true
	t.modules.mouse = true

	t.window.width = 800
	t.window.height = 600
	t.window.vsync = false
	t.window.usedpiscale = false
end