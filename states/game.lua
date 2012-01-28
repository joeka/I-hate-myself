local game = Gamestate.new()
local HC = require "libs.HardonCollider"

GRAVITY = 300
newHero = require "entities.player"
require "entities.collision"
local newObstacle = require "entities.obstacle"

entities = nil
local Collider
star = nil
floor = nil
wall = nil
was_edited = nil
commandHistory = nil

obstacles = {}
items = {}

-- variable used by the editor to fill the game level
game.level_obstacles = {}
game.level_testmode = {}

-- Enums or whatever
TYPES = {
	PLAYER = 1,
	OTHER = 2,
	STAR = 3
}

function game:enter()
	Collider = HC(100, on_collision, collision_stop)
	commandHistory = {}
	entities = {}
	table.insert(entities, newHero(0,200,15,15, Collider))
	
	star = Collider:addRectangle(150, 200, 10, 10)
	star.type = TYPES.STAR
	
	obstacles = {}
	if #self.level_obstacles > 0 then
		-- load obstacles from level_obstacles (which were hopefully filled by
		-- the editor
		print ("Loading " .. #game.level_obstacles .. "...")
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
	for i,entity in ipairs(entities) do	
		entity:executeHistory ()
		entity:update(dt)
	end
	
	Collider:update(dt)
end

function game:draw(dt)
	for i,entity in ipairs(entities) do

		love.graphics.setColor(0,255,255,math.max(50, 255*i/#entities))
		if i == 1 then
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
	if key == "up" then
		entities[1]:insertCommand("jumpKey", {1})
	end
	if key == "right" then
		entities[1]:insertCommand("moveRightKey", {1})
	end
	if key == "left" then
		entities[1]:insertCommand("moveLeftKey", {1})
	end
end

function game:keyreleased(key)
	if key == "up" then
		entities[1]:insertCommand("jumpKey", {nil})
	end
	if key == "right" then
		entities[1]:insertCommand("moveRightKey", {nil})
	end
	if key == "left" then
		entities[1]:insertCommand("moveLeftKey", {nil})
	end
	if key == "escape" then
		if game.level_testmode then
			Gamestate.switch (states.editor)
		else
			Gamestate.switch (states.start)
		end
	end
end

function game:reset()
	table.insert(entities, newHero(0, 200, 15, 15, Collider))
end

function game:registerObstacle(obstacle)
	obstacle.rect = Collider:addRectangle(
		obstacle.x, obstacle.y, obstacle.w, obstacle.h
		)

	obstacle.rect.type = obstacle.type 

	table.insert(obstacles, obstacle)
end

function game:registerItem(item) 
	item.rect = Collider:addRectangle(
		item.x, item.y, item.w, item.h
		)

	item.rect.type = item.type
	
	table.insert(items, item)
end

return game
