require "libs.strict"

no_game_code = nil


Gamestate = require "libs.hump.gamestate"

local states = {}

function love.load()
	love.mouse.setVisible(false)
	states.game = require "states.game"

	Gamestate.registerEvents()
	Gamestate.switch(states.game)
end
