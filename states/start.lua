local start = Gamestate.new()


font_big, font_huge, font_medium, font_small = nil, nil, nil, nil

local background = nil

function start:init()
	start.clicksound = love.audio.newSource({"assets/sfx/scissor1.ogg"}, "static")
	start.clicksound:setVolume(0.5)
	
	start.music = love.audio.newSource("assets/music/startscreen.ogg")
	--start.music:setLooping(true)
	start.music:setPitch(1)
	font_huge = love.graphics.newFont("assets/fonts/FrederickatheGreat-Regular.ttf",72)
	font_big = love.graphics.newFont("assets/fonts/FrederickatheGreat-Regular.ttf",48)
	font_medium = love.graphics.newFont("assets/fonts/FrederickatheGreat-Regular.ttf",32)
	font_small = love.graphics.newFont("assets/fonts/FrederickatheGreat-Regular.ttf",16)

	background = love.graphics.newImage ("assets/graphics/background.png")
end

function start:enter()
	love.audio.play(start.music)
end

function start:draw()
	love.graphics.setColor(50, 50, 50, 255)
	love.graphics.draw( background )
	
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
		Gamestate.switch(states.editor)
	elseif key == "u" then
		savegame:reset()
		print( "savegame deleted" )
	else
		start.clicksound:play()
		start.clicksound:setPitch(0.75 + math.random()*0.5)
		
		Gamestate.switch(states.selection)
	end
end

return start
