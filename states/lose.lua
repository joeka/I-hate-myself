local lose = Gamestate.new()

function lose:init()
	
end

function lose:draw()
	states.game:draw()
	love.graphics.setFont(font_big)
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("You die!", 200, 200)
end

function lose:keypressed(key)

	if key == "escape" then
		Gamestate.switch(states.start)
	else
		if states.game.level_testmode then
			Gamestate.switch(states.editor)
		else
			states.game:clear_world()
			Gamestate.switch(states.game)			
		end
	end
end

return lose