local start = Gamestate.new()

local font_big

function start:init()
	font_big = love.graphics.newFont(48)
end

function start:draw()
	love.graphics.setFont(font_big)
	love.graphics.setColor(255,255,255)
	love.graphics.print("press any key", 200, 200)
end

function start:keyreleased(key)
	if key == "escape" then
		love.event.push('q')
	else
		Gamestate.switch(states.game)
	end
end

return start
