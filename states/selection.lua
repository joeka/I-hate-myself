savegame = require "misc.savegame"
local selection = Gamestate.new()
local music
local background

local joystickSelectTime = .3

function selection:init()
	selection.selectionsound = love.audio.newSource({"assets/sfx/select1.ogg","assets/sfx/select2.ogg","assets/sfx/select3.ogg",}, "static")
	selection.selectionsound:setVolume(0.5)
	selection.clicksound = love.audio.newSource({"assets/sfx/scissor1.ogg"}, "static")
	selection.clicksound:setVolume(0.5)
	background = love.graphics.newImage ("assets/graphics/background.png")
end

function selection:enter()
	input_time = love.timer.getTime()

	selection.levelid = savegame:load()
	selection.selectedLevel = 1
end

function selection:draw()
	love.graphics.setColor (50, 50, 50, 255)
	love.graphics.draw (background, 0, 0)

	love.graphics.setFont(font_huge)
	love.graphics.setColor(255,255,255)
	love.graphics.print("Select a level", 190, 20)
	love.graphics.setFont(font_small)
	love.graphics.print("(or 'e' for editor)", 650, 570)
	love.graphics.setFont(font_big)
	local j
	local row = 0
	for i=1,math.min(selection.levelid,#levels) do
		j = math.floor((i-1)/4)
		row = row + 1
		if row > 4 then row = 1 end
		if i == selection.selectedLevel then
			love.graphics.setColor(255,255,255,60)
			love.graphics.rectangle("fill", 200 + j * 100, 120+row*70,130,60)
			love.graphics.setColor(255,255,255,255)
		end
		love.graphics.print(i, 250+j*100, 120+row*70)
	end
end

function selection:keypressed(key)
	input_time = love.timer.getTime()

	if key == "up" then
		selection.selectionsound:setPitch(0.75 + math.random()*0.5)
		selection.selectionsound:play()
		selection.selectedLevel = selection.selectedLevel - 1
	elseif key == "down" then
		selection.selectionsound:setPitch(0.75 + math.random()*0.5)
		selection.selectionsound:play()
		selection.selectedLevel = selection.selectedLevel + 1
	elseif key == "left" then
		selection.selectedLevel = selection.selectedLevel - 4
	elseif key == "right" then
		selection.selectedLevel = selection.selectedLevel + 4
	elseif key == "escape" then
		Gamestate.switch(states.start)
	elseif key == "e" then
		Gamestate.switch(states.editor)
	else
		selection.clicksound:play()
		selection.clicksound:setPitch(0.75 + math.random()*0.5)
		love.audio.stop(states.start.music)
		Gamestate.switch(states.game, selection.selectedLevel)
	end

	if selection.selectedLevel <= 0 then
		selection.selectedLevel = math.min(selection.levelid,#levels)
	end
	
	if selection.selectedLevel > math.min(selection.levelid,#levels) then
		selection.selectedLevel = 1
	end
end

function selection:update( dt )
	if joystick and love.timer.getTime() - input_time > joystickSelectTime then
		local horAxis, verAxis = love.joystick.getAxes( joystick )
		
		if verAxis < -.3  then
			input_time = love.timer.getTime()

			selection.selectionsound:setPitch(0.75 + math.random()*0.5)
			selection.selectionsound:play()
			selection.selectedLevel = selection.selectedLevel - 1
		elseif verAxis > .3 then
			input_time = love.timer.getTime()

			selection.selectionsound:setPitch(0.75 + math.random()*0.5)
			selection.selectionsound:play()
			selection.selectedLevel = selection.selectedLevel + 1
		elseif horAxis < -.3 then
			input_time = love.timer.getTime()

			selection.selectedLevel = selection.selectedLevel - 4
		elseif horAxis > .3 then
			input_time = love.timer.getTime()

			selection.selectedLevel = selection.selectedLevel + 4
		end

		if selection.selectedLevel <= 0 then
			selection.selectedLevel = math.min(selection.levelid,#levels)
		end
		
		if selection.selectedLevel > math.min(selection.levelid,#levels) then
			selection.selectedLevel = 1
		end
	end

	if love.timer.getTime() - input_time > input_timeout then
		Gamestate.switch(states.start)
	end
end

function selection:joystickpressed( joystick, key )
	if key == joystick_back then
		Gamestate.switch(states.start, selection.selectedLevel)
	else
		input_time = love.timer.getTime()

		selection.clicksound:play()
		selection.clicksound:setPitch(0.75 + math.random()*0.5)
		love.audio.stop(states.start.music)
		Gamestate.switch(states.game, selection.selectedLevel)
	end
end


return selection
