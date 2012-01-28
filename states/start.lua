local start = Gamestate.new()

font_big, font_small = nil, nil

function start:init()
	font_big = love.graphics.newFont(48)
	font_small = love.graphics.newFont(12)
end

function start:draw()
	love.graphics.setFont(font_big)
	love.graphics.setColor(255,255,255)
	love.graphics.print("press any key", 200, 200)
	love.graphics.setFont(font_small)
	love.graphics.print("(or 'e' for editor)", 200, 255)
end

function start:keypressed(key)
	if key == "escape" then
		love.event.push('q')
	elseif key == "e" then
		Gamestate.switch(states.editor)
	else
		Gamestate.switch(states.game)
	end
end

return start
