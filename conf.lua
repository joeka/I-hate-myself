function love.conf(t)
	t.screen.width = 800
	t.screen.height = 600
	t.screen.fullscreen = true

	t.title = "I hate myself"
	t.author = "Tilmann Hars, Martin Felis, Jonathan Wehrle"

	t.identity = "ihatemyself"

	t.version = "0.7.2"

	t.modules.joystick = true
	t.modules.physics = false

	t.input_timeout = 15
end
