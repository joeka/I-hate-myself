require "libs.strict"

no_game_code = nil


Gamestate = require "libs.hump.gamestate"

states = {}

function love.load()
	love.mouse.setVisible(false)
	states.start = require "states.start"
	states.game = require "states.game"
	states.editor = require "states.editor"

	Gamestate.registerEvents()
	Gamestate.switch(states.start)
end
