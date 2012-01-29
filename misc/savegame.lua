local serialize = require "libs.serialize"

local savegame = {
	saveFile = "save.lua",
	saveData = {}
}


function savegame:load()
	if love.filesystem.isFile( self.saveFile ) then
		local fileData = love.filesystem.load(self.saveFile)
		self.saveData = fileData()
	else
		self.saveData.levelID = 1
	end
	return self.saveData.levelID
end
function savegame:save(levelID)
	if levelID then
		self.saveData.levelID = levelID
	end
	local fileData = "return " .. serialize( self.saveData )
	love.filesystem.write( self.saveFile, fileData, #fileData )
end
function savegame:reset()
	self.saveData = {}
	love.filesystem.remove( self.saveFile )
end

return savegame
