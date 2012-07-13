require "libs.strict"
require "libs.imgui"
require "libs.slam"

screenshot = require "misc.screenshot"

no_game_code = nil
common = nil

Gamestate = require "libs.hump.gamestate"

-- used for input timeout -> automatic game reset
input_time = nil
input_timeout = nil

joystick = nil
joystick_back = 3

states = {}

levels = {}

function loadLevels()
	local lfs = love.filesystem
	levels = lfs.enumerate("levels")
	table.sort(levels, function(a,b) return tonumber(a:match("%d+")) < tonumber(b:match("%d+")) end)
	for i,v in ipairs(levels) do
		print(tostring(v))
	end
end

function love.load()
	-- set the icon
	local icon = love.graphics.newImage("assets/graphics/icon.png")
	print (icon)
	love.graphics.setIcon (icon)

	math.randomseed(os.time())
	math.random();math.random();math.random()
	states.start = require "states.start"
	states.game = require "states.game"
	states.editor = require "states.editor"
	states.lose = require "states.lose"
	states.win = require "states.win"
	states.selection = require "states.selection"
	
	loadLevels()

	if love.joystick.getNumJoysticks( ) > 0 then
		joystick = love.joystick.getNumJoysticks( ) - 1
	end

	input_timeout = 20
	input_time = love.timer.getTime()

	Gamestate.registerEvents()
	Gamestate.switch(states.start)
end


function love.keypressed(key)
	if key == "f12" then
		screenshot()
	end
end
