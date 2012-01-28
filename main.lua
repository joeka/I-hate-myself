require "libs.strict"
require "libs.imgui"

no_game_code = nil
common = nil

Gamestate = require "libs.hump.gamestate"

states = {}

function love.load()
	math.randomseed(os.time())
	math.random();math.random();math.random()
	states.start = require "states.start"
	states.game = require "states.game"
	states.editor = require "states.editor"
	states.lose = require "states.lose"

	Gamestate.registerEvents()
	Gamestate.switch(states.start)
end
