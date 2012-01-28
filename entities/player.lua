local function newHero(x,y,w,h,hardonCollider)
	local PLAYER_VELOCITY = 100

	local hero = {
		x = x or 0,
		y = y or 200,
		w = w or 5,
		h = h or 5,
		commandHistory = {},
		lastCommand = 1,
		controllerState = {},
		rect = hardonCollider:addRectangle(x,y,w,h),

		jump_height = 150,

		y_velocity = 0
	}
	
	hero.rect.type = TYPES.PLAYER

	function hero:insertCommand(command, arguments, time)
		table.insert(self.commandHistory, {command = command, arguments = arguments,time = time})
	end

	function hero:moveRightKey(state)
		self.controllerState["right"] = state
	end

	function hero:moveLeftKey(state)
		self.controllerState["left"] = state
	end

	function hero:jump()
		self.y_velocity = self.jump_height
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
		local dx = 0
		local dy = 0
		if self.y_velocity ~= 0 then
			dy = - self.y_velocity * dt
			self.y_velocity = self.y_velocity - GRAVITY * dt

			if self.controllerState["left"] then
				dx = -dt * PLAYER_VELOCITY * 2/3
			end
			if self.controllerState["right"] then
				dx = dt * PLAYER_VELOCITY * 2/3
			end
		else
			if self.controllerState["left"] then
				dx = -dt * PLAYER_VELOCITY
			end
			if self.controllerState["right"] then
				dx = dt * PLAYER_VELOCITY
			end
		end
		self.rect:move(dx, dy)

		local cx, cy = self.rect:center()
		if cy >= 210 then
			self.y_velocity = 0
		end
	end
	
	function hero:draw()
		self.rect:draw("fill")
	end
	
	-- internal for collision response
	function hero:move(x, y)
		self.x = self.x + x
		self.y = self.y + y
		self.rect:move(x, y)
	end
	return hero
end

return newHero
