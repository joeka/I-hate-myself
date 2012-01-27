require "libs.strict"

no_game_code = nil
common = nil

Gamestate = require "libs.hump.gamestate"

states = {}

function love.load()

	states.start = require "states.start"
	states.game = require "states.game"

	Gamestate.registerEvents()
	Gamestate.switch(states.start)
end
