local win = Gamestate.new()



function win:draw()
	states.game:draw()
	love.graphics.setFont(font_big)
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Level complete!", 200, 200)
end

function win:keypressed(key)
	states.game:clear_world()
	if key == "escape" then
		--Gamestate.switch(states.start)
	else
		Gamestate.switch(states.game)		
	end
end

return win