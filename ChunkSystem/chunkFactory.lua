

local ChunkFactory = {}
ChunkFactory.__index = ChunkFactory
setmetatable(ChunkFactory, {__call = function(cls, ...) return cls.new(...) end})

local floor = math.floor
local pairs = pairs
local tinsert = table.insert

local cwd = (...):gsub('%.chunkFactory$', '') .. "."
local Grid 	= require(cwd .. "grid")
local Chunk = require(cwd .. "chunk")



local function generateChunk(self, x, y)
	local chunkdata = { tilesize	= self.tilesize,
											width 		= self.tilesW,
											height		= self.tilesH }
	return self:addChunk(x, y, chunkdata)
end



--------------------------------------------------------------------------------------------------------------

function ChunkFactory.new(mapdata)
	local self = setmetatable({}, ChunkFactory)
	local mapdata			= mapdata or {}
	self.tilesize			= mapdata.tilesize
	self.chunksW			= mapdata.chunksW or 10
	self.chunksH			= mapdata.chunksH or 10
	self.tilesW				= mapdata.tilesW or 64
	self.tilesH				= mapdata.tilesH or 64
	self.chunks 			= Grid(self.chunksW, self.chunksH)

	--local x, y = math.ceil(self.chunksW/2), math.ceil(self.chunksH/2)
	--local chunk = generateChunk(self, x, y)
	--self:setCurrentChunk(chunk)
	return self
end



function ChunkFactory:addChunk(x, y, chunkdata)
	return self.chunks:set(x, y, Chunk(x, y, chunkdata))
end



function ChunkFactory:getChunk(x, y)
	return self.chunks:get(x, y)
end



function ChunkFactory:addLayerToChunk(x, y, layerdata)
	local chunk = self.chunks:get(x, y)
	if chunk and type(chunk) == "table" then
		chunk:addLayer(layerdata)
		print("Added new layer to chunk at {"..x..", "..y.."}")
	end
end



function ChunkFactory:setCurrentChunk(chunk)
	if not chunk then return end

	if self.currentChunk then
		self.currentChunk.active = false
		for k, neighbor in pairs(self:getNeighbors(self.currentChunk)) do
			if type(neighbor) == "table" then
				neighbor.active = false
				neighbor.visible = false
			end
		end
	end

	self.currentChunk = chunk
	self.currentChunk.active = true
	for k, neighbor in pairs(self:getNeighbors(self.currentChunk)) do
		if type(neighbor) == "table" then
			neighbor.active = true
			neighbor.visible = true
		end
	end
	return self.currentChunk
end



function ChunkFactory:loadChunk(x, y)
end



function ChunkFactory:unloadChunk(x, y)
end



function ChunkFactory:updateProximity(x, y, camx, camy, scale)
	-- ! Load proximity chunks
	-- ! unload chunks not in proximity
	local wx = floor(((x + camx) / self.tilesW  / self.tilesize / scale) + 1)
	local wy = floor(((y + camy) / self.tilesH / self.tilesize / scale) + 1)
	local chunk = self:getChunk(wx, wy)
	if chunk == self.currentChunk then return end

	-- Generate new random chunk --
	if type(chunk) == "number" then chunk = generateChunk(self, wx, wy) end
	print(chunk)
	-- Set the chunk as currently selected --
	self:setCurrentChunk(chunk)
end



function ChunkFactory:getNeighbors(chunk, radius)
	if not chunk then return end
	local x, y = chunk:getPosition()
	local radius = radius or 1
	local neighbors = {}
	for ny = -radius, radius do
		for nx = -radius, radius do
			local neighbor = self:getChunk(x+nx, y+ny)
			if neighbor and neighbor ~= 0 then tinsert(neighbors, neighbor) end
		end
	end
	return neighbors
end



function ChunkFactory:update(dt)
	self.chunks:update(dt)
end



function ChunkFactory:draw()
	self.chunks:draw()
end

return ChunkFactory
