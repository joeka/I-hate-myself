require "libs.strict"
require "libs.imgui"
require "libs.slam"

no_game_code = nil
common = nil

Gamestate = require "libs.hump.gamestate"

states = {}

levels = {}

function loadLevels()
	local lfs = love.filesystem
	levels = lfs.enumerate("levels")
end

function love.load()
	math.randomseed(os.time())
	math.random();math.random();math.random()
	states.start = require "states.start"
	states.game = require "states.game"
	states.editor = require "states.editor"
	states.lose = require "states.lose"
	states.win = require "states.win"
	
	loadLevels()

	Gamestate.registerEvents()
	Gamestate.switch(states.start)
end
