local serialize = require "libs.serialize"

local savegame = {
	saveFile = "save.lua",
	saveData = {}
}


function savegame:load()
	if love.filesystem.isFile( self.saveFile ) then
		local fileData = love.filesystem.load(self.saveFile)
		self.saveData = fileData()
	end
	return self.saveData.levelID or 1
end
function savegame:save(levelID)
	if levelID then
		self.saveData.levelID = levelID
	end
	local fileData = "return " .. serialize( self.saveData )
	love.filesystem.write( self.saveFile, fileData, #fileData )
end

return savegame
