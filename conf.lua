function love.conf(t)
	t.window.width = 800
	t.window.height = 600
	t.window.fullscreen = true

	t.title = "I hate myself"
	t.author = "Tilmann Hars, Martin Felis, Jonathan Wehrle"

	t.identity = "ihatemyself"

	t.version = "0.9.2"

	t.modules.joystick = true
	t.modules.physics = false

	t.input_timeout = 15
end
