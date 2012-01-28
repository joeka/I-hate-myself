local game = Gamestate.new()
local HC = require "libs.HardonCollider"

GRAVITY = 300
newHero = require "entities.player"
require "entities.collision"
local newObstacle = require "entities.obstacle"

local entities
currentHero = nil
local currentRoundTime
local Collider
star = nil
floor = nil
wall = nil
was_edited = nil

obstacles = {}

-- variable used by the editor to fill the game level
game.level_obstacles = {}

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

	obstacles = {}
	if #self.level_obstacles > 0 then
		-- load obstacles from level_obstacles (which were hopefully filled by
		-- the editor
		for i,obst in ipairs(game.level_obstacles) do
			self:registerObstacle(obst)
		end
	else
		-- manual test level
		local obst = newObstacle (200, 200, 15, 15)
		obst:setColor (255, 120, 120, 255)
		obst.name = "somebox"
		obst.type = TYPES.OTHER
		self:registerObstacle (obst)

		local floor = newObstacle (0, 215, 800, 30)
		floor:setColor (255, 120, 120, 255)
		floor.name = "floor"
		floor.type = TYPES.OTHER
		self:registerObstacle (floor)

		local wall = newObstacle (250, 175, 100, 15)
		wall:setColor (255, 120, 120, 255)
		wall.name = "wall"
		wall.type = TYPES.OTHER
		self:registerObstacle (wall)
	end
end

function game:update(dt)
	currentRoundTime = currentRoundTime + dt
	
	if currentHero.rect.y_velocity == 0 and love.keyboard.isDown( "up" ) then
		currentHero:insertCommand(currentHero.jump, {currentHero}, currentRoundTime)
	end

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

	for i,obstacle in ipairs(obstacles) do
		love.graphics.setColor(obstacle.r, obstacle.g, obstacle.b, obstacle.a)
		love.graphics.rectangle("fill", obstacle.x, obstacle.y, obstacle.w, obstacle.h)
		if obstacle.rect then
			--			obstacle.rect.draw("fill")
		end
	end

	love.graphics.setColor(255,255,0,255)
	star:draw("fill")
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
	if key == "escape" then
		Gamestate.switch (states.start)
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

function game:registerObstacle(obstacle)
	obstacle.rect = Collider:addRectangle(
		obstacle.x, obstacle.y, obstacle.w, obstacle.h
		)

	obstacle.rect.type = obstacle.type 

	table.insert(obstacles, obstacle)
end

return game
