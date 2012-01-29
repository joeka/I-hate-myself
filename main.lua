require "libs.strict"
require "libs.imgui"
require "libs.slam"

screenshot = require "misc.screenshot"

no_game_code = nil
common = nil

Gamestate = require "libs.hump.gamestate"

states = {}

levels = {}

function loadLevels()
	local lfs = love.filesystem
	levels = lfs.enumerate("levels")
	for i,v in ipairs(levels) do
		print(tostring(v))
	end
end

function love.load()
	math.randomseed(os.time())
	math.random();math.random();math.random()
	states.start = require "states.start"
	states.game = require "states.game"
	states.editor = require "states.editor"
	states.lose = require "states.lose"
	states.win = require "states.win"
	states.selection = require "states.selection"
	
	loadLevels()

	Gamestate.registerEvents()
	Gamestate.switch(states.start)
end

function love.keypressed(key)
	if key == "f12" then
		screenshot()
	end
end
