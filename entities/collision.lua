function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
	
	-- collision player with other player
	if shape_a.type == TYPES.PLAYER and shape_b.type == TYPES.PLAYER then
		print("we are all gonna die")
		return
	end
	
	-- collision hero entites with level geometry
	if (shape_a == currentHero.rect and shape_b == star) or (shape_a == star and shape_b == currentHero.rect) then
		states.game:reset()
		star:moveTo(math.random(800), 200)
		return
	end
	
	-- collision hero entites with level geometry
	if shape_a.type == TYPES.PLAYER and shape_b.type == TYPES.OTHER then
		shape_a:move(mtv_x, mtv_y)
	elseif shape_b.type == TYPES.PLAYER and shape_a.type == TYPES.OTHER then
		shape_b:move(-mtv_x, -mtv_y)
	end
end

function collision_stop(dt, shape_a, shape_b)
	
end

