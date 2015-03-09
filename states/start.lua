local start = Gamestate.new()


font_big, font_huge, font_medium, font_small = nil, nil, nil, nil

local background = nil
local block_image = nil


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
	block_image = love.graphics.newImage ("assets/graphics/rectangle_wide.png")
end

function start:enter()
	love.audio.play(start.music)
end

function start:draw()
	love.graphics.setColor(50, 50, 50, 255)
	love.graphics.draw( background )

	love.graphics.setColor(255, 255, 255, 200)
	love.graphics.draw (block_image, 120, 150, 0.03, 0.7, 0.7)
	
	love.graphics.setFont(font_big)
	love.graphics.setColor(0,0,0)
	love.graphics.print("I hate myself.", 200, 200)
	love.graphics.setFont(font_small)
	love.graphics.print("A Global Game Jam 2012 game.", 200, 260)
	love.graphics.print("About the past.", 200, 290)

	love.graphics.setColor(255,255,255)
	love.graphics.print("Please press a key", 550, 500)
end

function start:keypressed(key)
	if key == "escape" then
		love.event.quit()
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

function start:joystickpressed( joystick, button )
	start.clicksound:play()
	start.clicksound:setPitch(0.75 + math.random()*0.5)
	
	Gamestate.switch(states.selection)
end

return start
