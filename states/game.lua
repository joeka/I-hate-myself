local game = Gamestate.new()
local HC = require "libs.HardonCollider"

require "libs.AnAL"

Timer = require "libs.hump.timer"

GRAVITY = 850
newHero = require "entities.player"
require "entities.collision"
local messages = {}
local newObstacle = require "entities.obstacle"
local pick_mouse_delta = nil
local star_animation = nil

entities = nil
game.Collider = nil
was_edited = nil
commandHistory = nil

obstacles = {}
items = {}
spawn_point = {x = 0, y = 0, w = 35, h = 60}

-- Enums or whatever
TYPES = {
	PLAYER = 1,
	OTHER = 2,
	STAR = 3
}

images = {}

function game:init()
	print("init game")
	images.stand = love.graphics.newImage("assets/graphics/idle.png")
	images.walk = love.graphics.newImage("assets/graphics/walk_cycle_white.png")
	images.jump = love.graphics.newImage("assets/graphics/jump.png")
	images.stand_left = love.graphics.newImage("assets/graphics/idle_left.png")
	images.walk_left = love.graphics.newImage("assets/graphics/walk_cycle_white_left.png")
	images.jump_left = love.graphics.newImage("assets/graphics/jump_left.png")
	images.star = love.graphics.newImage("assets/graphics/star.png")

	images.blocks = {
		love.graphics.newImage ("assets/graphics/rectangle_normal.png"),
		love.graphics.newImage ("assets/graphics/rectangle_normal_2.png"),
		love.graphics.newImage ("assets/graphics/rectangle_square.png"),
		love.graphics.newImage ("assets/graphics/rectangle_wide.png"),
		love.graphics.newImage ("assets/graphics/rectangle_small.png"),
		love.graphics.newImage ("assets/graphics/rectangle_portrait.png"),
	}

	game.currentLevel = 1;

	images.background = love.graphics.newImage ("assets/graphics/background.png")
	self.diesound = love.audio.newSource({"assets/sfx/die1.ogg", "assets/sfx/die2.ogg", "assets/sfx/die3.ogg"}, "static")
	
	self.musicloop = love.audio.newSource("assets/music/loop.ogg", "static")
	self.musicloop:setLooping(true)
	self.musicloop:setVolume(0.2)
	
	self.drone = love.audio.newSource("assets/music/drone.ogg")
	self.drone:setLooping(true)
	self.drone:setVolume(0.1)
	
	game:init_world()
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
	spawn_point = {x = 383, y = 270, w = 35, h = 60}
end

function game:clear_world()
	game.Collider:clear()
	obstacles = {}
	items = {}
	entities = {}

	spawn_point = {x = 0, y = 0, w = 35, h = 60}
end

function game:enter(prev, levelNum)
	Timer.clear()
	self:checkLevelNumber(levelNum)
	love.audio.play(self.musicloop)
	love.audio.play(self.drone)
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
	else
		states.editor:load("level.txt")
	end

	--the end of the world
	local leftBorder = self.Collider:addRectangle(-30, -100, 30, 800)
	local rightBorder = self.Collider:addRectangle(800, -100, 30, 800)
	leftBorder.type = TYPES.OTHER
	rightBorder.type = TYPES.OTHER

	game.Collider:setSolid(items[1].rect)

	table.insert(entities, newHero(spawn_point.x, spawn_point.y, nil,nil, game.Collider))

	Timer.add(10, function()
		if #entities < 2 then
			game:spawnHero()
		end
	end)
end

function game:leave()
	messages = {}
	Timer.clear()
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

	for i,item in ipairs(items) do
		item.animation:update(dt / i)
	end

	game.Collider:update(dt)
	Timer.update(dt)
end

function game:draw(dt)
	love.graphics.setColor (90, 90, 90, 255)
	love.graphics.draw (images.background, 0, 0)

	for i,entity in ipairs(entities) do
		if i == 1 then
			love.graphics.setColor(233,233,233,255)
		else
			love.graphics.setColor(255,120,140,math.max(30, 200*i/#entities))
		end
		entity:draw()
		
	end

	for i,obstacle in ipairs(obstacles) do
		love.graphics.setColor(obstacle.r, obstacle.g, obstacle.b, obstacle.a)
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
--				love.graphics.rectangle("fill", item.x, item.y, item.w, item.h)
				item.animation:draw (item.x, item.y)
			else

				love.graphics.setColor(128, 128, 128, item.a / (i * i - 2*i + 1))
--				love.graphics.rectangle("fill", item.x, item.y, item.w, item.h)
				item.animation:draw (item.x, item.y)
			end
		end
	end
	
	game:drawMessages()
end

function game:keypressed(key)
	if key == "up" then
		entities[1]:insertCommand("jumpKey", {1}, entities[1].x, entities[1].y)
	elseif key == "right" then
		entities[1]:insertCommand("moveRightKey", {1}, entities[1].x, entities[1].y)
	elseif key == "left" then
		entities[1]:insertCommand("moveLeftKey", {1}, entities[1].x, entities[1].y)
	elseif key == "r" or key == "return" then
		game:reset()
	end
end

function game:reset()
--	states.game.drone:setPitch(1)
	love.audio.stop()

	states.game:clear_world()
	Gamestate.switch(states.game)
end

function game:keyreleased(key)
	if key == "up" then
		entities[1]:insertCommand("jumpKey", {nil}, entities[1].x, entities[1].y)
	elseif key == "right" then
		entities[1]:insertCommand("moveRightKey", {nil}, entities[1].x, entities[1].y)
	elseif key == "left" then
		entities[1]:insertCommand("moveLeftKey", {nil}, entities[1].x, entities[1].y)
	elseif key == "escape" then
		love.audio.stop()
		if game.level_testmode then
			Gamestate.switch (states.editor)
		else
			Gamestate.switch (states.start)
		end
	end
end

function game:spawnHero()
	table.insert(entities, newHero(spawn_point.x, spawn_point.y, nil, nil, game.Collider))
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
	--game.Collider:addToGroup("geometry", item.rect)
	--game.Collider:setPassive(item.rect)
	item.rect.type = item.type
	game.Collider:setGhost(item.rect)
	item.animation = newAnimation (images.star, 15, 15, 0.1, 0) 
	item.animation:play()
	item.animation:setMode("loop")
	item.animation.dont_serialize_me = 1

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

function game:checkLevelNumber(levelNum)
	if levelNum == 1 then
		table.insert(messages, {
			img = love.graphics.newImage("assets/graphics/arrows.png"),
			text = "move, jump",
			x = 150,
			y = 50
		})
		Timer.add(5, function() table.remove(messages, 1) end)
	end
end

function game:drawMessages()
	love.graphics.setFont(font_medium)
	love.graphics.setColor(255,255,255,255)
	for i,message in ipairs(messages) do
		if message.img then
			love.graphics.draw(message.img, message.x, message.y)
		end
		love.graphics.print(message.text, message.x+message.img:getWidth()+5, message.y)

	end
end

return game
