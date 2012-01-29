local start = Gamestate.new()


font_big, font_huge, font_medium, font_small = nil, nil, nil, nil

local background = {
	x = -20,
	y = -15,
	w = 840,
	h = 630,

	ox = 0,
	oy = 0,

	image = nil,
	color = {50, 50, 50, 255}
}
function background:draw()
	love.graphics.setColor(unpack(self.color))
	local iw, ih = self.image:getWidth(), self.image:getHeight()
	local sx, sy = self.w / iw, self.h / ih
	love.graphics.draw( self.image, self.x, self.y, 0, sx, sy, self.ox, self.oy )
end
function background:update(dt)
	local ox = self.ox + math.random( -70 * dt, 70 * dt) 
	local oy = self.oy + math.random( -50 * dt, 50 * dt)

	if math.abs(ox) < math.abs(self.x) then
		self.ox = ox
	end
	if math.abs(oy) < math.abs(self.y) then
		self.oy = oy
	end
end

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

	background.image = love.graphics.newImage ("assets/graphics/background.png")
end

function start:enter()
	love.audio.play(start.music)
end

function start:draw()
	background:draw()

	love.graphics.setFont(font_big)
	love.graphics.setColor(255,255,255)
	love.graphics.print("press any key", 200, 200)
	love.graphics.setFont(font_small)
	love.graphics.print("(or 'e' for editor)", 200, 260)
end

function start:update(dt)
	background:update(dt)
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
