local game = Gamestate.new()


local entities
local currentHero
local currentRoundTime

function game:enter()
	entities = {}
	table.insert(entities, newHero())
	currentHero = entities[1]
	currentRoundTime = 0
	
end

function game:update(dt)
	currentRoundTime = currentRoundTime + dt

	if love.keyboard.isDown("left") then
		currentHero:insertCommand(currentHero.moveLeft, {currentHero,dt*50}, currentRoundTime)
	end
	if love.keyboard.isDown("right") then
		currentHero:insertCommand(currentHero.moveRight, {currentHero,dt*50}, currentRoundTime)
	end
	
	for i,entity in ipairs(entities) do	
		while true do		
			local command = entity.commandHistory[entity.lastCommand]
			if command and currentRoundTime >= command.time then
				command.command(unpack(command.arguments))
				entity.lastCommand = entity.lastCommand + 1
			else
				break
			end
		end
	end
end

function game:draw(dt)
	for i,entity in ipairs(entities) do
		love.graphics.setColor(255,255,255,255*i/#entities)
		love.graphics.rectangle("fill", entity.x, entity.y, 5, 5)		
	end

end

function game:keypressed(key)
	if key == "x" then
		print(key)
		for i,entity in ipairs(entities) do
			entity.lastCommand = 1
			entity.x = 0
			entity.y = 200
		end
		
		currentRoundTime = 0

	end
end

function newHero()
	local hero = {
		x = 0,
		y = 200,
		commandHistory = {},
		lastCommand = 1
	}

	function hero:insertCommand(command, arguments, time)
		table.insert(self.commandHistory, {command = command, arguments = arguments,time = time})
	end

	function hero:moveRight(amount)
		self.x = self.x + amount
	end
	
	function hero:moveLeft(amount)
		self.x = self.x - amount
	end
	
	
	
	return hero
end

return game
