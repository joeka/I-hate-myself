savegame = require "misc.savegame"
local selection = Gamestate.new()
local music

function selection:init()
	selection.selectionsound = love.audio.newSource({"assets/sfx/select1.ogg","assets/sfx/select2.ogg","assets/sfx/select3.ogg",}, "static")
	selection.selectionsound:setVolume(0.5)
end

function selection:enter()
	selection.levelid = savegame:load()
	selection.selectedLevel = 1
end

function selection:draw()
	love.graphics.setFont(font_huge)
	love.graphics.setColor(255,255,255)
	love.graphics.print("Select a level", 190, 20)
	love.graphics.setFont(font_small)
	love.graphics.print("(or 'e' for editor)", 650, 570)
	love.graphics.setFont(font_big)
	for i=1,selection.levelid do
		if i == selection.selectedLevel then
			love.graphics.setColor(255,255,255,60)
			love.graphics.rectangle("fill", 300, 120+i*70,130,60)
			love.graphics.setColor(255,255,255,255)
		end
		love.graphics.print(i, 350, 120+i*70)		
	end
end

function selection:keypressed(key)

	if key == "up" then
		selection.selectionsound:setPitch(0.75 + math.random()*0.5)
		selection.selectionsound:play()
		selection.selectedLevel = selection.selectedLevel - 1
	elseif key == "down" then
		selection.selectionsound:setPitch(0.75 + math.random()*0.5)
		selection.selectionsound:play()
		selection.selectedLevel = selection.selectedLevel + 1
	elseif key == "escape" then
		Gamestate.switch(states.start)
	elseif key == "e" then
		Gamestate.switch(states.editor)
	else
		love.audio.stop()
		Gamestate.switch(states.game, selection.selectedLevel)
	end
	if selection.selectedLevel <= 0 then
		selection.selectedLevel = selection.levelid
	end
	
	if selection.selectedLevel > selection.levelid then
		selection.selectedLevel = 1
	end
	
	print(selection.selectedLevel)
	print(selection.levelid)
end

return selection