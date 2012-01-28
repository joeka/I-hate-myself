local vector = require "libs.hump.vector"

local COLOR_ACTIVE = {150, 150, 0, 255}
local COLOR_HOT = {200, 200, 0, 255}

local input_state = {
	mouse_pos = nil,
	hotitem = 0,
	activeitem = 0,
	last_char = ""
}

function inject_input (character)
end

function mouse_hit (x, y, w, h)
	input_state.mouse_pos = vector.new (love.mouse.getX(), love.mouse.getY())
	if input_state.mouse_pos 
		and input_state.mouse_pos.x > x and input_state.mouse_pos.x < x + w
		and input_state.mouse_pos.y > y and input_state.mouse_pos.y < y + h then
		return 1
	end

	return nil
end

function Button (id, name, xpos, ypos, width, height)
	input_state.hotitem = 0

	if mouse_hit (xpos, ypos, width, height) then
		love.graphics.setColor (COLOR_HOT)
		input_state.hotitem = id
	else
		love.graphics.setColor (COLOR_ACTIVE)
	end

	love.graphics.rectangle ("fill", xpos, ypos, width, height)
	love.graphics.setColor (255, 255, 255, 255)
	love.graphics.print (name, xpos + 4, ypos + height * 0.25)

	if input_state.hotitem == id and love.mouse.isDown ("l") then
		return 1
	end

	return nil
end
