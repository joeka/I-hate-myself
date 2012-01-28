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

		jump_height = 150,

		animations = {
			stand = newAnimation(img_stand, 15, 30, 0.5, 0),
			walk = newAnimation(img_walk, 15, 30, 0.5, 0),
			jump = newAnimation(img_jump, 15, 30, 0.5, 0)
		}
	}
	
	hero.animations.stand:setMode("once")
	hero.animations.walk:setMode("loop")
	hero.animations.jump:setMode("once")
	hero.currentAnim = hero.animations.stand

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

	function hero:setAnimation(animation)
		if self.currentAnim ~= animation then
			self.currentAnim:stop()
			self.currentAnim = animation
			self.currentAnim:play()
		end
	end

	function hero:executeHistory()
		while true do		
			local command = commandHistory[self.lastCommand]
			if command and self.currentRoundTime >= command.time then

				self[command.command](self, unpack(command.arguments))
				self.lastCommand = self.lastCommand + 1
			else
				break
			end
		end
	end

	function hero:update(dt)
		self.currentRoundTime = self.currentRoundTime + dt
		
		self:updatePosition(dt)

		self.currentAnim:update(dt)
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
			self:setAnimation(self.animations.jump)
		else
			if self.controllerState["left"] then
				dx = -dt * PLAYER_VELOCITY
				self:setAnimation(self.animations.walk)
			end
			if self.controllerState["right"] then
				dx = dt * PLAYER_VELOCITY
				self:setAnimation(self.animations.walk)
			end
			if self.controllerState["jump"] then
				self.rect.y_velocity = self.jump_height
				self:setAnimation(self.animations.jump)
			else
				self.rect.y_velocity = - GRAVITY * dt
			end
		end
		self.rect:move(dx, dy)
	end
	
	function hero:draw()
		local cx, cy = self.rect:center()
		
		self.currentAnim:draw( cx - self.w/2, cy - self.h/2  )
	end
	
	return hero
end

return newHero
