

local Map = {}
Map.__index = Map
setmetatable(Map, {__call = function(cls, ...) return cls.new(...) end})

local cwd = (...):gsub('%.init$', '') .. "."
local Camera			 = require(cwd .. "camera")
local ChunkFactory = require(cwd .. "chunkFactory")


--------------------------------------------------------------------------------------------------------------
-- mapdata: tilesize, chunksW, chunksH, tilesW, tilesH
function Map.new(mapdata)
	local self 	= setmetatable({}, Map)
	local mapdata = mapdata or {tilesize = 16}
	self.tilesize			= mapdata.tilesize
	self.camera				= Camera()
	self.camera:setScale(.05)
	self.camera:setSpeed(400)
	self.chunkFactory = ChunkFactory(mapdata)
	return self
end



function Map:addChunk(x, y, chunkdata)
	return self.chunkFactory:addChunk(x, y, chunkdata)
end



function Map:update(dt)
	if love.keyboard.isDown("a") then self.camera:move(-1, 0, dt) end
	if love.keyboard.isDown("d") then self.camera:move(1, 0, dt) end
	if love.keyboard.isDown("w") then self.camera:move(0, -1, dt) end
	if love.keyboard.isDown("s") then self.camera:move(0, 1, dt) end

	self.chunkFactory:update(dt)
	local mx, my = love.mouse.getPosition()
	self.chunkFactory:updateProximity(mx, my, self.camera.x, self.camera.y, self.camera.scale)
end



function Map:draw()
	self.camera:set()
	self.chunkFactory:draw()
	self.camera:unset()
end



function Map:wheelmoved(x, y)
	if y > 0 and self.camera.scale < 1.8 then self.camera:rescale(.1) end
	if y < 0 and self.camera.scale > .1 then self.camera:rescale(-.1) end
end

return Map
