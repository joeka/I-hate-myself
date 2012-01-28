local vector = require "libs.hump.vector"
newObstacle = require "entities.obstacle"
local editor = Gamestate.new()

local obstacles
local drag_start = {}
local med_font
-- Contains the obstacle that is currently edited
local active_obstacle = nil
-- Contains the obstacle local coordinates of the mouse
local active_obstacle_mouse_delta = nil

local mouse_pos = vector.new(-1, -1)

local editor_mode = "add"

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

function editor:enter()
	love.mouse.setVisible(true)
	obstacles = {}
	med_font = love.graphics.newFont(24)
end

function editor:update(dt)
	mouse_pos.x = love.mouse.getX()
	mouse_pos.y = love.mouse.getY()

	if active_obstacle then
		obstacles[active_obstacle].x = mouse_pos.x + active_obstacle_mouse_delta.x
		obstacles[active_obstacle].y = mouse_pos.y + active_obstacle_mouse_delta.y
	end
end

function editor:save(filename)
	local data = "return {\n"

	for i,obstacle in ipairs(obstacles) do
		data = data .. "{" .. obstacle.x .. ", " .. obstacle.y .. ", " .. obstacle.w .. ", " .. obstacle.h .. "},\n"
	end

	data = data .. "}"

	print (love.filesystem.write (filename, data, #data))
end

function editor:load(filename)
	local chunk = love.filesystem.load (filename)
	local data_values = chunk()

	obstacles = {}

	for i,values in ipairs(data_values) do
		self:addObstacle (values[1], values[2], values[3], values[4])
	end
end

function editor:draw(dt)
	love.graphics.setFont(med_font)

	love.graphics.setColor (255, 255, 0, 255)

	if Button (1, "Save", 400, 30, 80, 40) then
		editor_mode = "Saving..."
		self:save("level.txt")
	end

	if Button (1, "Load", 490, 30, 80, 40) then
		editor_mode = "Loading..."
		self:load("level.txt")
	end

	love.graphics.print ("Editor: " .. editor_mode, 6, 12)
	for i,obstacle in ipairs(obstacles) do
		love.graphics.setColor(255,255,255,255*i/#obstacles)
		love.graphics.rectangle ("fill", obstacle.x, obstacle.y, obstacle.w, obstacle.h)

		-- highlight the active obstacle
		if i == active_obstacle then
			love.graphics.setColor(255, 255, 0, 128)
			love.graphics.setLine (2, "smooth")
			love.graphics.rectangle ("line", obstacle.x, obstacle.y, obstacle.w, obstacle.h)
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
	elseif key == "f8" then
		editor_mode = "delete"
	end
end

function editor:keyreleased(key)
	if key == "escape" then
		Gamestate.switch (states.start)
	end
end

function editor:addObstacle (x, y, w, h)
	local obstacle = newObstacle(x, y, w, h)
	obstacle.type = TYPES.OTHER

	table.insert (obstacles, obstacle)
	table.insert (states.game.level_obstacles, obstacle)
end

function editor:mousepressed (x, y, button)
	if editor_mode == "add" then
		if button == "l" then
			drag_start = vector.new (x,y)
		end
	elseif editor_mode == "move" then
		active_obstacle = obstacle_pick (x, y)

		if active_obstacle then
			active_obstacle_mouse_delta = vector.new(
				obstacles[active_obstacle].x - x,
				obstacles[active_obstacle].y - y
			)
		end
	end
end

function editor:mousereleased (x, y, button)
	if editor_mode == "add" then
		if button == "l" then
			local dimensions = calc_rect_size (drag_start.x, drag_start.y, x, y)
			self:addObstacle (dimensions.x, dimensions.y, dimensions.w, dimensions.h)
			drag_start = {}
		end
	elseif editor_mode == "move" then
		active_obstacle = nil
	end
end


return editor
