local function newHero()
	local PLAYER_VELOCITY = 100

	local hero = {
		x = 0,
		y = 200,
		commandHistory = {},
		lastCommand = 1,
		controllerState = {},
	}

	function hero:insertCommand(command, arguments, time)
		table.insert(self.commandHistory, {command = command, arguments = arguments,time = time})
	end

	function hero:moveRightKey(state)
		self.controllerState["right"] = state
	end

	function hero:moveLeftKey(state)
		self.controllerState["left"] = state
	end

	function hero:executeHistory(currentRoundTime)
		while true do		
			local command = self.commandHistory[self.lastCommand]
			if command and currentRoundTime >= command.time then
				command.command(unpack(command.arguments))
				self.lastCommand = self.lastCommand + 1
			else
				break
			end
		end
	end

	function hero:updatePosition(dt)
		if self.controllerState["left"] then
			self.x = self.x - dt * PLAYER_VELOCITY
		end
		if self.controllerState["right"] then
			self.x = self.x + dt * PLAYER_VELOCITY
		end
	end
	return hero
end

return newHero
