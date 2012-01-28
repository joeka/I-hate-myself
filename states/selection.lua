local selection = Gamestate.new()
local music

font_big, font_small = nil, nil

function selection:init()

	font_big = love.graphics.newFont("assets/fonts/FrederickatheGreat-Regular.ttf",48)
	font_small = love.graphics.newFont("assets/fonts/FrederickatheGreat-Regular.ttf",16)
end

function selection:enter()

end

function selection:draw()
	love.graphics.setFont(font_big)
	love.graphics.setColor(255,255,255)
	love.graphics.print("SWEET JESUS", 200, 200)
	love.graphics.setFont(font_small)
	love.graphics.print("(or 'e' for editor)", 200, 260)
end

function selection:keypressed(key)
	love.audio.stop()
	if key == "escape" then
		love.event.push('q')
	elseif key == "e" then
		Gamestate.switch(states.editor)
	else
		Gamestate.switch(states.game)
	end
end

return selection