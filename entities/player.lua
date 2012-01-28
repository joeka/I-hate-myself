local commandHistory = {}

local function newHero(x,y,w,h,hardonCollider)
	local PLAYER_VELOCITY = 100

	local hero = {
		x = x or 0,
		y = y or 200,
		w = w or 5,
		h = h or 5,
		lastCommand = 1,
		controllerState = {},
		rect = hardonCollider:addRectangle(x,y,w,h),

		currentRoundTime = 0,

		jump_height = 150
	}
	
	hero.rect.type = TYPES.PLAYER
	hero.rect.y_velocity = 0

	function hero:insertCommand(command, arguments)
		table.insert(commandHistory, {command = command, arguments = arguments, time = self.currentRoundTime})
	end

	function hero:moveRightKey(state)
		self.controllerState["right"] = state
	end

	function hero:moveLeftKey(state)
		self.controllerState["left"] = state
	end

	function hero:jumpKey(state)
		self.controllerState["jump"] = state
	end

	function hero:executeHistory()
		while true do		
			local command = commandHistory[self.lastCommand]
			if command and self.currentRoundTime >= command.time then
				print(command)
				print(command.command)
				command.command(unpack(command.arguments))
				self.lastCommand = self.lastCommand + 1
			else
				break
			end
		end
	end

	function hero:update(dt)
		self.currentRoundTime = self.currentRoundTime + dt
		
		self:updatePosition(dt)
	end

	function hero:updatePosition(dt)
		local dx = 0
		local dy = 0

		if self.rect.y_velocity ~= 0 then
			dy = - self.rect.y_velocity * dt
			self.rect.y_velocity = self.rect.y_velocity - GRAVITY * dt

			if self.controllerState["left"] then
				dx = -dt * PLAYER_VELOCITY * 2/3
			end
			if self.controllerState["right"] then
				dx = dt * PLAYER_VELOCITY * 2/3
			end
		else
			if self.controllerState["jump"] then
				self.rect.y_velocity = self.jump_height
				print("jump")
			else
				self.rect.y_velocity = - GRAVITY * dt
			end
			if self.controllerState["left"] then
				dx = -dt * PLAYER_VELOCITY
			end
			if self.controllerState["right"] then
				dx = dt * PLAYER_VELOCITY
			end
		end
		self.rect:move(dx, dy)

		local cx, cy = self.rect:center()
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
