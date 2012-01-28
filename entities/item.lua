local function newItem (x,y)
	local item = {
		x = x, y = y, w = 15, h = 15,
		r = 255, g = 255, b = 255, a = 255,
		type = 0, name = "unnamed", rect = nil
	}
	
	function item:setColor (r,g,b,a)
		self.r = r
		self.g = g
		self.b = b
		self.a = a
	end

	return item
end

return newItem
