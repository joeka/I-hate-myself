local lose = Gamestate.new()

function lose:init()
	self.sentences = {
		"You encountered the terrors of your past.",
		"Seems like the past did catch up with you.",
		"The past came back to haunt you.",
		"Evil-you from the past killed you."
	}
end

function lose:enter()
	states.game.drone:setPitch(1)
	--	love.audio.stop()
	self.currentSentence = self.sentences[math.random(#self.sentences)]
end

function lose:draw()
	states.game:draw()

	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(font_big)
	love.graphics.print("OH NOES!", 200, 200)
	love.graphics.setFont(font_small)
	love.graphics.print(self.currentSentence, 200, 250)
end

function lose:keypressed(key)

	if key == "escape" then
		Gamestate.switch(states.start)
	else
		states.game:reset()
	end
end

return lose
