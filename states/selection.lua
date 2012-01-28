savegame = require "misc.savegame"
local selection = Gamestate.new()
local music

function selection:init()


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
			love.graphics.setColor(255,255,255,120)
			love.graphics.rectangle("fill", 300, 120+i*70,100,40)
			love.graphics.setColor(255,255,255,255)
		end
		love.graphics.print(i, 350, 120+i*70)		
	end
end

function selection:keypressed(key)
	love.audio.stop()
	if key == "up" then
		selection.selectedLevel = (selection.selectedLevel - 1)%selection.levelid
	elseif key == "down" then
		selection.selectedLevel = (selection.selectedLevel + 1)%selection.levelid
	elseif key == "escape" then
		love.event.push('q')
	elseif key == "e" then
		Gamestate.switch(states.editor)
	else
		Gamestate.switch(states.game)
	end
end

return selection