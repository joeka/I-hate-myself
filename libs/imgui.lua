local vector = require "libs.hump.vector"

local COLOR_NORMAL = {150, 150, 0, 255}
local COLOR_HOT = {200, 200, 0, 255}
local COLOR_ACTIVE = {220, 220, 0, 255}

local input_state = {
	mouse_pos = nil,
	hotitem = 0,
	activeitem = 0,
	last_char = ""
}

function mouse_hit (x, y, w, h)
	input_state.mouse_pos = vector.new (love.mouse.getX(), love.mouse.getY())
	if input_state.mouse_pos 
		and input_state.mouse_pos.x > x and input_state.mouse_pos.x < x + w
		and input_state.mouse_pos.y > y and input_state.mouse_pos.y < y + h then
		return 1
	end

	return nil
end
	
local button_state = {}

local function Button (id, caption, xpos, ypos, width, height)
	input_state.hotitem = 0

	--	print (button_state.pressed)

	if mouse_hit (xpos, ypos, width, height) then
		love.graphics.setColor (COLOR_HOT)

		if not button_state[id] then
			button_state[id] = {hot = 1, pressed = nil}
		end
		button_state[id].hot = 1
	else
		love.graphics.setColor (COLOR_NORMAL)
		button_state[id] = nil
	end

	love.graphics.rectangle ("fill", xpos, ypos, width, height)
	love.graphics.setColor (255, 255, 255, 255)
	love.graphics.print (caption, xpos + 4, ypos + height * 0.25)

	if button_state[id] and button_state[id].pressed and not love.mouse.isDown ("l") then
		button_state[id].pressed = nil
		button_state[id] = nil
		return 1
	end

	if button_state[id] and button_state[id].hot and love.mouse.isDown ("l") then
		button_state[id].pressed = 1
	end

	return nil
end

return Button
