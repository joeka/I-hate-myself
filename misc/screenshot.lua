local function screenshot()
	local s = love.graphics.newScreenshot()
	local d = love.image.newEncodedImageData(s, "bmp")
	local i = 0
	while love.filesystem.isFile( "screenshot".. i ..".bmp" ) do
		i = i + 1
	end
	local imageName = "screenshot".. i ..".bmp"
	love.filesystem.write(imageName, d)
end

return screenshot
