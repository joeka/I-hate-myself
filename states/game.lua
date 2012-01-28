local game = Gamestate.new()
local HC = require "libs.HardonCollider"

require "libs.AnAL"

GRAVITY = 350
newHero = require "entities.player"
require "entities.collision"

local newObstacle = require "entities.obstacle"

local pick_mouse_delta = nil

entities = nil
game.Collider = nil
star = nil
floor = nil
wall = nil
was_edited = nil
commandHistory = nil

obstacles = {}
items = {}

-- Enums or whatever
TYPES = {
	PLAYER = 1,
	OTHER = 2,
	STAR = 3
}

images = {}

function game:init()
	images.stand = love.graphics.newImage("assets/graphics/dummy_stand.png")
	images.walk = love.graphics.newImage("assets/graphics/dummy_walk.png")
	images.jump = love.graphics.newImage("assets/graphics/dummy_jump.png")
	images.stand_left = love.graphics.newImage("assets/graphics/dummy_stand_left.png")
	images.walk_left = love.graphics.newImage("assets/graphics/dummy_walk_left.png")
	images.jump_left = love.graphics.newImage("assets/graphics/dummy_jump_left.png")
	
	self.currentLevel = 1;
end

-- initializes all world state variables so that the editor can work on it
function game:init_world()
	if game.Collider == nil then
		game.Collider = HC(100, on_collision, collision_stop)
	end
	if obstacles == nil then
		obstacles = {}
	end
	if items == nil then
		items = {}
	end
	if entities == nil then
		entities = {}
	end
end

function game:clear_world()
	game.Collider = HC(100, on_collision, collision_stop)
	obstacles = {}
	items = {}
	entities = {}
end

function game:enter(prev, levelNum)
	self:init_world()

	-- clear_world() must not be called... otherwise you end up in an empty
	-- world...
	commandHistory = {}

	if entities == nil then
		entities = {}
	end

	if not game.level_testmode then
		if levelNum then
			self.currentLevel = levelNum
		end
		states.editor:load("levels/"..levels[self.currentLevel])
	end

	table.insert(entities, newHero(0,0,15,30, game.Collider))
end

function game:update(dt)
	for i,entity in ipairs(entities) do	
		entity:executeHistory ()
		entity:update(dt)
	end
	
	game.Collider:update(dt)
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
	
	for i,item in ipairs(items) do
		love.graphics.setColor(item.r, item.g, item.b, item.a)
		love.graphics.rectangle("fill", item.x, item.y, item.w, item.h)
		if item.rect then
			--			item.rect.draw("fill")
		end
	end
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
	table.insert(entities, newHero(0, 0, 15, 30, game.Collider))
end

function game:registerObstacle(obstacle)
	obstacle.rect = game.Collider:addRectangle(
		obstacle.x, obstacle.y, obstacle.w, obstacle.h
		)

	obstacle.rect.type = obstacle.type 

	table.insert(obstacles, obstacle)
end

function game:registerItem(item) 
	item.rect = game.Collider:addRectangle(
		item.x, item.y, item.w, item.h
		)

	item.rect.type = item.type
	
	table.insert(items, item)
end

function game:moveObstacle(obstacle_index, newx, newy)
	obstacles[obstacle_index].x = newx
	obstacles[obstacle_index].y = newy
end

function game:removeStar(star)
	local rem = -1
	for i,v in ipairs(items) do
		if v.rect == star then
			rem = i
		end
	end
	print(rem)
	if rem > 0 then
		table.remove(items, rem)
		game.Collider:remove(star)
	end
	if #items == 0 then
		Gamestate.switch(states.win)
	end
end

return game
