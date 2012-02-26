local win = Gamestate.new()

local game_complete = 0

local background = love.graphics.newImage ("assets/graphics/background.png")
local block_image = love.graphics.newImage ("assets/graphics/rectangle_wide.png")
local icon_image = love.graphics.newImage ("assets/graphics/icon.png")

function win:leave()
	game_complete = 0
end

function win:enter()
	if states.game.currentLevel == savegame.saveData.levelID then
		savegame:save(savegame.saveData.levelID + 1)
	end

	if states.game.currentLevel + 1> #levels then
		states.game.currentLevel = 1
		self:wonGame()
	end

	states.game.drone:setVolume(0.08)
	states.game.drone:setPitch(1)
	states.game.drone:setLooping(false)
end

function win:draw()
	if game_complete == 0 then
		states.game:draw()
		love.graphics.setFont(font_huge)
		love.graphics.setColor(0,0,0,150)
		love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Level complete!", 150, 200)
	else 
		love.graphics.setColor(50, 50, 50, 255)
		love.graphics.draw(background)

		love.graphics.setColor(255, 255, 255, 200)
		love.graphics.draw (block_image, 110, 150, 0.03, 0.8, 0.7)

		love.graphics.setFont(font_big)
		love.graphics.setColor(0,0,0)
		love.graphics.setFont(font_small)
		love.graphics.print("You find your old diary (it was common, before blogs existed). You read", 160, 230)
		love.graphics.print("about your excitement of writing your first program. You read about", 160, 260)
		love.graphics.print("your dreams to write a video game. You realize, you just did that.", 160, 290)

		love.graphics.setColor(255,255,255)
		love.graphics.print("Thank You.", 550, 500)
	end
end

function win:wonGame()
	game_complete = 1
end

function win:keypressed(key)
	states.game:clear_world()
	states.game.currentLevel = states.game.currentLevel + 1
	if key == "escape" then
		Gamestate.switch(states.start)
	else
		if game_complete == 1 then
			Gamestate.switch(states.start)
		else
			if states.game.level_testmode then
				Gamestate.switch(states.editor, states.game.currentLevel)
			else
				states.game:clear_world()
				Gamestate.switch(states.game, states.game.currentLevel)			
			end
		end
	end
end

return win
