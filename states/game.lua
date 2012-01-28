local game = Gamestate.new()
local HC = require "libs.HardonCollider"

require "libs.AnAL"

Timer = require "libs.hump.timer"

GRAVITY = 850
newHero = require "entities.player"
require "entities.collision"

local newObstacle = require "entities.obstacle"

local pick_mouse_delta = nil

entities = nil
game.Collider = nil
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

	images.blocks = {
		love.graphics.newImage ("assets/graphics/rectangle_normal.png"),
		love.graphics.newImage ("assets/graphics/rectangle_normal_2.png"),
		love.graphics.newImage ("assets/graphics/rectangle_square.png"),
		love.graphics.newImage ("assets/graphics/rectangle_wide.png"),
		love.graphics.newImage ("assets/graphics/rectangle_small.png"),
	}

	game.currentLevel = 1;

	images.background = love.graphics.newImage ("assets/graphics/background.png")
	
	self.musicloop = love.audio.newSource("assets/music/loop.ogg", "static")
	self.musicloop:setLooping(true)
	self.musicloop:setVolume(0.2)
	love.audio.play(self.musicloop)
	
	self.drone = love.audio.newSource("assets/music/drone.ogg", "static")
	self.drone:setLooping(true)
	self.drone:setVolume(0.1)
	love.audio.play(self.drone)
	
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

	--the end of the world
	local leftBorder = self.Collider:addRectangle(-30, -100, 30, 800)
	local rightBorder = self.Collider:addRectangle(800, -100, 30, 800)
	leftBorder.type = TYPES.OTHER
	rightBorder.type = TYPES.OTHER

	game.Collider:setSolid(items[1].rect)

	table.insert(entities, newHero(0,0,15,30, game.Collider))

	Timer.add(10, function()
		if #entities < 2 then
			game:reset()
		end
	end)
end

function game:update(dt)
	for i,entity in ipairs(entities) do	
		entity:executeHistory ()
		entity:update(dt)
	end
	
	local cx, cy = entities[1].rect:center()
	if cy > 666 then
		Gamestate.switch(states.lose)
	end

	game.Collider:update(dt)
	Timer.update(dt)
end

function game:draw(dt)
	love.graphics.setColor (90, 90, 90, 255)
	love.graphics.draw (images.background, 0, 0)

	for i,entity in ipairs(entities) do
		love.graphics.setColor(0,255,255,math.max(50, 255*i/#entities))
		if i == 1 then
			love.graphics.setColor(255,0,0,255)
		end
		entity:draw()
		
	end

	for i,obstacle in ipairs(obstacles) do
		love.graphics.setColor(obstacle.r, obstacle.g, obstacle.b, obstacle.a)
--		love.graphics.rectangle("fill", obstacle.x, obstacle.y, obstacle.w, obstacle.h)
		love.graphics.draw (images.blocks[obstacle.block_sprite_index],
			obstacle.x - obstacle.w * 0.05, obstacle.y - obstacle.h * 0.05, 0,
			obstacle.block_scale_x, obstacle.block_scale_y
			)
	end
	
	for i,item in ipairs(items) do
		if game.editmode then
			love.graphics.setColor(item.r, item.g, item.b, item.a)
			love.graphics.rectangle("fill", item.x, item.y, item.w, item.h)
			
			love.graphics.setColor(0,0,0,255)
			love.graphics.print(tostring(i), item.x, item.y)
		else
			if i == 1 then
				love.graphics.setColor(item.r, item.g, item.b, item.a)
				love.graphics.rectangle("fill", item.x, item.y, item.w, item.h)
			else
				love.graphics.setColor(item.r, item.g, item.b, item.a / 20)
				love.graphics.rectangle("fill", item.x, item.y, item.w, item.h)
			end
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
	
	-- depending on the ratio choose the proper rectangle
	local ratio = obstacle.w / obstacle.h
	local best_ratio = 1000.
	local best_ratio_index = 10000 
	local best_image = nil
	for i,image in ipairs(images.blocks) do
		local image_ratio = image:getWidth() / image:getHeight()
	
		if math.abs (ratio - image_ratio) < best_ratio then
			best_ratio = math.abs (ratio - image_ratio)
			best_ratio_index = i
			best_image = image
		end
	end

	-- also compute the proper scaling
	obstacle.block_sprite_index = best_ratio_index
	obstacle.block_scale_x = 1.1 * obstacle.w / best_image:getWidth()
	obstacle.block_scale_y = 1.1 * obstacle.h / best_image:getHeight()

	table.insert(obstacles, obstacle)
end

function game:deleteObstacle(delete_obstacle)
	for i=#obstacles,1,-1 do
		if obstacles[i].x == delete_obstacle.x and
			obstacles[i].y == delete_obstacle.y and
			obstacles[i].w == delete_obstacle.w and
			obstacles[i].h == delete_obstacle.h then
			table.remove(obstacles, i)
			return
		end
	end
end

function game:registerItem(item) 
	item.rect = game.Collider:addRectangle(
		item.x, item.y, item.w, item.h
		)

	item.rect.type = item.type
	game.Collider:setGhost(item.rect)
	
	table.insert(items, item)
end

function game:deleteItem(delete_item)
	for i=#items,1,-1 do
		if items[i].x == delete_item.x and
			items[i].y == delete_item.y and
			items[i].w == delete_item.w and
			items[i].h == delete_item.h then
			table.remove(items, i)
			return
		end
	end
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
			if items[i+1] then
				game.Collider:setSolid(items[i+1].rect)
			end
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
