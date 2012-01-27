local game = Gamestate.new()
local HC = require "libs.HardonCollider"
newHero = require "entities.player"
require "entities.collision"

local entities
currentHero = nil
local currentRoundTime
local Collider
star = nil
obstacle = nil

-- Enums or whatever
TYPES = {
	PLAYER = 1,
	OTHER = 2
}

function game:enter()
	Collider = HC(100, on_collision, collision_stop)
	entities = {}
	table.insert(entities, newHero(0,200,15,15, Collider))
	currentHero = entities[1]
	currentRoundTime = 0
	
	star = Collider:addRectangle(150, 200, 10, 10)
	
	obstacle = Collider:addRectangle(200, 200, 15, 15)
	obstacle.type = TYPES.OTHER
end

function game:update(dt)
	currentRoundTime = currentRoundTime + dt

	for i,entity in ipairs(entities) do	
		entity:executeHistory (currentRoundTime)
		entity:updatePosition (dt)
	end
	
	Collider:update(dt)
end

function game:draw(dt)
	for i,entity in ipairs(entities) do

		love.graphics.setColor(0,255,255,math.max(50, 255*i/#entities))
		if entity == currentHero then
			love.graphics.setColor(255,0,0,255)
		end
		entity:draw()
		
	end
	love.graphics.setColor(255,255,0,255)
	star:draw("fill")
	
	love.graphics.setColor(255,120,120,255)
	obstacle:draw("fill")
end

function game:keypressed(key)
	if key == "x" then
		print(key)
		game:reset()
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

function game:reset()
	for i,entity in ipairs(entities) do
		entity.lastCommand = 1
		entity.x = 0
		entity.y = 200
	end
	
	currentRoundTime = 0

	table.insert(entities, newHero(math.random(800), 200, 15, 15, Collider))
	currentHero = entities[#entities]
end

function game:addObstacle(x,y,w,h)
	local obst = Collider:addRectangle(x,y,w,h)
	Collider:setPassive(obst)
	
end

return game
