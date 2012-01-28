local function newObstacle (x,y,w,h)
	local obstacle = {
		x = x, y = y, w = w, h = h,
		r = 255, g = 255, b = 255, a = 255,
		type = 0, name = "unnamed", rect = nil
	}
	
	function obstacle:setColor (r,g,b,a)
		self.r = r
		self.g = g
		self.b = b
		self.a = a
	end

	return obstacle
end

return newObstacle
