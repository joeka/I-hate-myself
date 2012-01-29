local start = Gamestate.new()
local music

font_big, font_huge, font_small = nil, nil

function start:init()
	music = love.audio.newSource("assets/music/startscreen.ogg")
	music:setLooping(true)
	font_huge = love.graphics.newFont("assets/fonts/FrederickatheGreat-Regular.ttf",72)
	font_big = love.graphics.newFont("assets/fonts/FrederickatheGreat-Regular.ttf",48)
	font_small = love.graphics.newFont("assets/fonts/FrederickatheGreat-Regular.ttf",16)
end

function start:enter()
	love.audio.play(music)
end

function start:draw()
	love.graphics.setFont(font_big)
	love.graphics.setColor(255,255,255)
	love.graphics.print("press any key", 200, 200)
	love.graphics.setFont(font_small)
	love.graphics.print("(or 'e' for editor)", 200, 260)
end

function start:keypressed(key)
	if key == "escape" then
		love.event.push('q')
	elseif key == "e" then
		love.audio.stop()
		Gamestate.switch(states.editor)
	elseif key == "u" then
		savegame:reset()
		print( "savegame deleted" )
	else
		Gamestate.switch(states.selection)
	end
end

return start
