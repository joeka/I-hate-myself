local vector = require "libs.hump.vector"
newObstacle = require "entities.obstacle"
newItem = require "entities.item"
local Button = require "libs.imgui"
local Serialize = require "libs.serialize"
local HC = require "libs.HardonCollider"

local editor = Gamestate.new()

-- keeps a lightweight copy of the bounding boxes. Indices matches that of
-- the obstacles of the world! 
local obstacles = {}
-- keeps a lightweight copy of the bounding boxes. Indices matches that of
-- the obstacles of the world! 
local items = {}

local drag_start = {}
local med_font
-- Contains the obstacle that is currently edited
local active_obstacle = nil
local active_item = nil
-- Contains the obstacle local coordinates of the mouse
local active_move_mouse_delta = nil

local mouse_pos = vector.new(-1, -1)
local editor_mode = "add"

local FONT_SIZE = 12

-- Calculates the proper rectangle x,y,w,h coordinates from two points
function calc_rect_size (x1, y1, x2, y2)
	local w, h, x, y

	if x1 < x2 then
		w = x2 - x1
		x = x1
	else
		w = x1 - x2
		x = x2
	end
	
	if y1 < y2 then
		h = y2 - y1
		y = y1
	else
		h = y1 - y2
		y = y2
	end

	return {x = x, y = y, w = w, h = h}
end

-- Checks whether at the given position is an obstacle and returns its
-- index
function obstacle_pick (x, y)
	local last_obstacle = nil
	for i,obstacle in ipairs(obstacles) do
		if x > obstacle.x and y > obstacle.y
			and	x < obstacle.x + obstacle.w
			and y < obstacle.y + obstacle.h then
			last_obstacle = i
		end
	end

	return last_obstacle
end

function item_pick (x, y)
	local last_item = nil
	for i,item in ipairs(items) do
		if x > item.x and y > item.y
			and	x < item.x + item.w
			and y < item.y + item.h then
			last_item = i
		end
	end

	return last_item
end

function editor:enter()
	love.mouse.setVisible(true)
	states.game.editmode = true
	states.game:init()
	states.game.init_world()
	editor_mode = "add"
	
	med_font = love.graphics.newFont(FONT_SIZE)
	if states.game.level_testmode == 1 then
		states.game.level_testmode = 0
		self:load("level.txt")
	end
end

function editor:leave()
	states.game.editmode = nil
end

function editor:update(dt)
	mouse_pos.x = love.mouse.getX()
	mouse_pos.y = love.mouse.getY()

	if active_item then
		items[active_item].x = mouse_pos.x + active_move_mouse_delta.x
		items[active_item].y = mouse_pos.y + active_move_mouse_delta.y
	end

	if active_obstacle then
		states.game:moveObstacle(active_obstacle,
			mouse_pos.x + active_move_mouse_delta.x,
			mouse_pos.y + active_move_mouse_delta.y
		)
	end

	if editor_mode == "test" then
		self:save("level.txt")
		states.game:clear_world()
		self:load("level.txt")
		states.game.level_testmode = 1
		Gamestate.switch(states.game)
	end
end

function editor:save(filename)
	local level_data = { obstacles = obstacles, items = items }
	local data = "return " .. Serialize (level_data)

	--print (data)

	love.filesystem.write (filename, data, #data)
end

function editor:load(filename)
	local chunk = love.filesystem.load (filename)
	local data_values = chunk()

	-- reset game state
	states.game.clear_world()
	items = {}
	obstacles = {}

	local obstacle_list = data_values.obstacles

	for i,obstacle in ipairs(obstacle_list) do
		self:addObstacle (obstacle.x, obstacle.y, obstacle.w, obstacle.h)
	end

	local item_list = data_values.items

	for i,item in ipairs(item_list) do
		self:addItem (item.x, item.y)
	end

	print ("Loaded " .. #items .. " items and " .. #obstacles .. " obstacles.")
end

function editor:draw(dt)
	states.game.draw(0)

	love.graphics.setFont(med_font)

	love.graphics.setColor (255, 255, 0, 255)

	if Button (1, "Load", 650, 10, 60, 30) then
		self:load("level.txt")
	end

	if #items > 0 and Button (2, "Test", 720, 10, 60, 30) then
		editor_mode = "test"
	end

	if Button (3, "Add", 100, 10, 60, 30) then
		editor_mode = "add"
	end

	if Button (4, "Move", 170, 10, 60, 30) then
		editor_mode = "move"
	end

	if Button (5, "Star", 240, 10, 60, 30) then
		editor_mode = "star"
	end

	if Button (6, "Del", 340, 10, 60, 30) then
		editor_mode = "delete"
	end
	
	love.graphics.print ("Editor: " .. editor_mode, 6, 12)

	for i,obstacle in ipairs(obstacles) do
--		love.graphics.setColor(255,255,255,255*i/#obstacles)
--		love.graphics.rectangle ("fill", obstacle.x, obstacle.y, obstacle.w, obstacle.h)

		-- highlight the active obstacle
		if i == active_obstacle then
			love.graphics.setColor(255, 255, 0, 128)
			love.graphics.setLine (2, "smooth")
			love.graphics.rectangle ("line", obstacle.x, obstacle.y, obstacle.w, obstacle.h)
		end
	end

	for i,item in ipairs(items) do
--		love.graphics.setColor(255,255,255,255*i/#items)
--		love.graphics.rectangle ("fill", item.x, item.y, item.w, item.h)

		-- highlight the active item
		if i == active_item then
			love.graphics.setColor(255, 255, 0, 128)
			love.graphics.setLine (2, "smooth")
			love.graphics.rectangle ("line", item.x, item.y, item.w, item.h)
		end
	end

	-- draw the state of the obstacle that is being added
	if editor_mode == "add" and drag_start.x then
		local dimensions = calc_rect_size (drag_start.x, drag_start.y, love.mouse.getX(), love.mouse.getY())
		love.graphics.setColor(255, 255, 255, 128)
		love.graphics.rectangle ("fill", dimensions.x, dimensions.y, dimensions.w, dimensions.h)
		love.graphics.setColor(255, 255, 0, 128)
		love.graphics.setLine (2, "smooth")
		love.graphics.rectangle ("line", dimensions.x, dimensions.y, dimensions.w, dimensions.h)
	end
		love.graphics.setColor(255, 255, 255, 255)
end

function editor:keypressed(key)
	if key == "f1" then
		editor_mode = "add"
	elseif key == "f2" then
		editor_mode = "move"
	elseif key == "f3" then
		editor_mode = "star"
	elseif key == "f5" then
		editor_mode = "test"
	elseif key == "f8" then
		editor_mode = "delete"
	end
end

function editor:keyreleased(key)
	if key == "escape" then
		states.game.level_testmode = 0
		Gamestate.switch (states.start)
	end
end

function editor:addObstacle (x, y, w, h)
	if w < 15 or h < 15 then
		return
	end

	local obstacle = newObstacle(x, y, w, h)
	obstacle.type = TYPES.OTHER

	table.insert (obstacles, obstacle)
	states.game:registerObstacle (obstacle)
	--	table.insert (states.game.level_obstacles, obstacle)
end

function editor:deleteObstacle (obstacle_id)
	local delete_obstacle = obstacles[obstacle_id]
	states.game:deleteObstacle(delete_obstacle)

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

function editor:addItem (x, y)
	local item = newItem(x, y)
	item.r = 255
	item.g = 255
	item.b = 20
	item.a = 255
	item.type = TYPES.STAR

	table.insert (items, item)
	states.game:registerItem (item)
end

function editor:deleteItem (item_id)
	local delete_item = items[item_id]
	states.game:deleteItem(delete_item)

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

function editor:mousepressed (x, y, button)
	if editor_mode == "add" then
		if button == "l" then
			-- only add stuff if we are below the button line
			if y < 50 then
				return
			end

			drag_start = vector.new (x,y)
		end
	elseif editor_mode == "move" then

		-- first check for items
		active_item = item_pick (x, y)
		
		if active_item then
			active_move_mouse_delta = vector.new(
				items[active_item].x - x,
				items[active_item].y - y
			)
			return
		end

		-- if that fails check for obstacles
		active_obstacle = obstacle_pick (x, y)

		if active_obstacle then
			active_move_mouse_delta = vector.new(
				obstacles[active_obstacle].x - x,
				obstacles[active_obstacle].y - y
				)
			end
	elseif editor_mode == "star" then
		-- only add stuff if we are below the button line
		if y < 50 then
			return
		end

		self:addItem (x, y)
	elseif editor_mode == "delete" then
		local item = item_pick (x, y)
		if item then
			self:deleteItem(item)
		end

		local obstacle = obstacle_pick (x, y)
		if obstacle then
			self:deleteObstacle(obstacle)
		end
	end
end

function editor:mousereleased (x, y, button)
	if editor_mode == "add" then
		if button == "l" and drag_start and drag_start.x and drag_start.y then
			local dimensions = calc_rect_size (drag_start.x, drag_start.y, x, y)
			self:addObstacle (dimensions.x, dimensions.y, dimensions.w, dimensions.h)
			drag_start = {}
		end
	elseif editor_mode == "move" then
		active_obstacle = nil
		active_item = nil
	end
end

return editor
