local function serialize (o, tabs)
	local result = ""
	
	if tabs == nil then
		tabs = ""
	end

	if type(o) == "number" then
		result = result .. tostring(o)
	elseif type(o) == "string" then
		result = result .. string.format("%q", o)
	elseif type(o) == "table" then
		if o.dont_serialize_me then
			return "{}"
		end
		result = result .. "{\n"
		for k,v in pairs(o) do
			if type(v) ~= "function" then
				-- make sure that numbered keys are properly are indexified
				if type(k) == "number" then
					result = result .. tabs .. serialize(v, tabs .. "  ") .. ",\n"
				else
					result = result .. tabs .. "  " .. k .. " = " .. serialize(v, tabs .. "  ") .. ",\n"
				end
			end
		end
		result = result .. tabs .. "}"
	else
		print ("ignoring stuff")
	end
	return result
end

return serialize
