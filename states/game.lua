local game = Gamestate.new()

newHero = require "entities.player"

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

--	if love.keyboard.isDown("left") then
--		currentHero:insertCommand(currentHero.moveLeft, {currentHero,dt*50}, currentRoundTime)
--	end
--	if love.keyboard.isDown("right") then
--		currentHero:insertCommand(currentHero.moveRight, {currentHero,dt*50}, currentRoundTime)
--	end
	
	for i,entity in ipairs(entities) do	
		entity:executeHistory (currentRoundTime)
		entity:updatePosition (dt)
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
	if key == "right" then
		currentHero:insertCommand(currentHero.moveRightKey, {currentHero, 1}, currentRoundTime)
	end
	if key == "left" then
		currentHero:insertCommand(currentHero.moveLeftKey, {currentHero, 1}, currentRoundTime)
	end
end

function game:keyreleased(key)
	if key == "right" then
		currentHero:insertCommand(currentHero.moveRightKey, {currentHero}, currentRoundTime)
	end
	if key == "left" then
		currentHero:insertCommand(currentHero.moveLeftKey, {currentHero}, currentRoundTime)
	end
end

return game
