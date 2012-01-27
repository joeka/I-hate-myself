local vector = require "libs.hump.vector"
local editor = Gamestate.new()

local obstacles
local drag_start = {}
local med_font

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

function editor:enter()
	love.mouse.setVisible(true)
	obstacles = {}
	med_font = love.graphics.newFont(24)
end

function editor:update(dt)
end

function editor:draw(dt)
	love.graphics.setFont(med_font)
	love.graphics.print ("Editor", 6, 12)
	for i,obstacle in ipairs(obstacles) do
		love.graphics.setColor(255,255,255,255*i/#obstacles)
		love.graphics.rectangle ("fill", obstacle.x, obstacle.y, obstacle.w, obstacle.h)
	end

	if drag_start.x then
		local dimensions = calc_rect_size (drag_start.x, drag_start.y, love.mouse.getX(), love.mouse.getY())
		love.graphics.setColor(255, 255, 255, 128)
		love.graphics.rectangle ("fill", dimensions.x, dimensions.y, dimensions.w, dimensions.h)
		love.graphics.setColor(255, 255, 0, 128)
		love.graphics.setLine (2, "smooth")
		love.graphics.rectangle ("line", dimensions.x, dimensions.y, dimensions.w, dimensions.h)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function editor:keypressed(key)
end

function editor:keyreleased(key)
end

function editor:addObstacle (x, y, w, h)
	local obstacle = {x = x, y = y, w = w, h = h}
	table.insert (obstacles, obstacle)
end

function editor:mousepressed (x, y, button)
	if button == "l" then
		drag_start = vector.new (x,y)
	end
end

function editor:mousereleased (x, y, button)
	if button == "l" then
		local dimensions = calc_rect_size (drag_start.x, drag_start.y, x, y)
		self:addObstacle (dimensions.x, dimensions.y, dimensions.w, dimensions.h)
		drag_start = {}
	end
end


return editor
