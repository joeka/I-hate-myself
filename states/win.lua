local win = Gamestate.new()

function win:enter()
	if states.game.currentLevel == savegame.saveData.levelID then
		savegame:save(savegame.saveData.levelID + 1)
	end

	love.audio.stop()
	states.game.drone:setPitch(1)
end

function win:draw()
	states.game:draw()
	love.graphics.setFont(font_huge)
	love.graphics.setColor(0,0,0,150)
	love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Level complete!", 150, 200)
end

function win:wonGame()
	print("won, nothing")
end

function win:keypressed(key)
	states.game:clear_world()
	states.game.currentLevel = states.game.currentLevel + 1
	if states.game.currentLevel > #levels then
		states.game.currentLevel = 1
		self:wonGame()
	end

	if key == "escape" then
		Gamestate.switch(states.start)
	else
		if states.game.level_testmode then
			Gamestate.switch(states.editor)
		else
			states.game:clear_world()
			Gamestate.switch(states.game, states.game.currentLevel)
		end
	end
end

return win
