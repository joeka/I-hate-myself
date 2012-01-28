local function newHero(x,y,w,h,hardonCollider)
	local PLAYER_VELOCITY = 100

	local hero = {
		x = x or 0,
		y = y or 200,
		w = w or 35,
		h = h or 60,
		lastCommand = 1,
		controllerState = {},

		currentRoundTime = 0,

		jump_height = 400,

		animations = {},

		direction = 1,
		jumpsound = love.audio.newSource({"assets/sfx/jump1.ogg","assets/sfx/jump2.ogg"}, "static"),
		pickupsound = love.audio.newSource({"assets/sfx/pickup.ogg"}, "static")		
	}
	
	hero.rect = hardonCollider:addRectangle(hero.x+5,hero.y+4,hero.w-10,hero.h-8)
	
	hero.animations.stand = {
		newAnimation(images.walk, 35, 60, 0.1, 0),
		newAnimation(images.walk_left,  35, 60, 0.1, 0)

	}
	hero.animations.walk = {
		newAnimation(images.walk, 35, 60, 0.1, 0),
		newAnimation(images.walk_left,  35, 60, 0.1, 0)
	}
	hero.animations.jump = {
		newAnimation(images.jump, 35, 60, 0.07, 0),
		newAnimation(images.jump_left,  35, 60, 0.07, 0)
	}

	hero.animations.stand[1]:setMode("once")
	hero.animations.stand[2]:setMode("once")
	hero.animations.walk[1]:setMode("loop")
	hero.animations.walk[2]:setMode("loop")
	hero.animations.jump[1]:setMode("once")
	hero.animations.jump[2]:setMode("once")
	
	hero.currentAnim = hero.animations.stand[1]

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
			self.currentAnim:reset()
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
	
	
	function hero:correctDirection(dir)
		self.direction = dir
		local old_dir = (dir == 1 and 2) or (dir == 2 and 1)
		for key, anim in pairs(self.animations) do
			if self.currentAnim == anim[old_dir] then
				self.currentAnim = anim[dir]
			end
		end
	end

	function hero:updatePosition(dt)
		local dx = 0
		local dy = 0
		
		if self.controllerState["left"] then
			dx = -dt * PLAYER_VELOCITY
		end
		if self.controllerState["right"] then
			dx = dt * PLAYER_VELOCITY
		end	
		
		
		if self.rect.y_velocity ~= 0 then
			dy = - self.rect.y_velocity * dt
			self.rect.y_velocity = self.rect.y_velocity - GRAVITY * dt

			if dx > 0 and self.direction == 2 then
				self:correctDirection(1)
			elseif dx < 0 and self.direction == 1 then
				self:correctDirection(2)
			end
		else
			if dx > 0 then
				self.direction = 1
			elseif dx < 0 then
				self.direction = 2
			end

			if self.controllerState["jump"] then
				
				local instance = self.jumpsound:play()
				if self ~= entities[1] then
					instance:setVolume(0.1)
				end
				
				self.rect.y_velocity = self.jump_height
				self:setAnimation(self.animations.jump[self.direction])
			else
				if dx ~= 0 then
					self:setAnimation(self.animations.walk[self.direction])
				else
					self:setAnimation(self.animations.stand[self.direction])
				end
				self.rect.y_velocity = - GRAVITY * dt
			end
		end
		self.rect:move(dx, dy)
	end
	
	function hero:draw()
		local cx, cy = self.rect:center()
		
		self.currentAnim:draw( cx - self.w/2, cy - self.h/2 )
	end
	
	return hero
end

return newHero
