function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
	
	-- collision hero entites with special items
	if (shape_a == entities[1].rect and shape_b.type == TYPES.STAR) or (shape_a.type == TYPES.STAR and shape_b == entities[1].rect) then
		states.game:reset()
		if shape_a.type == TYPES.STAR then
			states.game:removeStar(shape_a)
		else
			states.game:removeStar(shape_b)
		end
		local instance = entities[1].pickupsound:play()
		instance:setPitch(math.sqrt(1/(#items+1)))
		states.game.drone:setPitch(1+(1/(#items+1)))
		return
	end
	
	-- collision hero entites with level geometry
	if shape_a.type == TYPES.PLAYER and shape_b.type == TYPES.OTHER then
		shape_a:move(mtv_x, mtv_y)
		
		if math.abs(mtv_y) > math.abs(mtv_x) then
			if mtv_y < 0 then
				shape_a.y_velocity = 0
			else
				shape_a.y_velocity = -1
			end
		end
	elseif shape_b.type == TYPES.PLAYER and shape_a.type == TYPES.OTHER then
		shape_b:move(-mtv_x, -mtv_y)

		if math.abs(mtv_y) > math.abs(mtv_x) then
			if mtv_y > 0 then
				shape_b.y_velocity = 0
			else
				shape_b.y_velocity = -1
			end
		end
	end
	
	-- collision hero with old entitiy
	if shape_a == entities[1].rect and shape_b.type == TYPES.PLAYER then
		Gamestate.switch(states.lose)
		return
	elseif shape_b == entities[1].rect and shape_a.type == TYPES.PLAYER then
		Gamestate.switch(states.lose)		
		return
	end
	
end

function collision_stop(dt, shape_a, shape_b)
	
end

