

local ChunkFactory = {}
ChunkFactory.__index = ChunkFactory
setmetatable(ChunkFactory, {__call = function(cls, ...) return cls.new(...) end})

local floor = math.floor
local pairs = pairs
local tinsert = table.insert

local rel_path = (...):gsub('%.chunkFactory$', '') .. "."
local Grid 	= require(rel_path .. "grid")
local Chunk = require(rel_path .. "chunk")
local bitser = require(rel_path .. "bitser")


local function generateChunk(self, x, y)
	local chunkdata = { tile_size	= self.tile_size,
											width 		= self.tiles_x,
											height		= self.tiles_y }
	return self:addChunk(x, y, chunkdata)
end



--------------------------------------------------------------------------------------------------------------

function ChunkFactory.new(settings)
	local self = setmetatable({}, ChunkFactory)
	self.map_name		= settings.map_name
	self.tile_size	= settings.tile_size
	self.chunks_x		= settings.chunks_x or 10
	self.chunks_y		= settings.chunks_y or 10
	self.tiles_x		= settings.tiles_x or 64
	self.tiles_y		= settings.tiles_y or 64
	self.load_dist 	= settings.load_dist or 1
	self.active_dist= settings.active_dist or 0
	self.chunks			= Grid(self.chunks_x, self.chunks_y)
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



function ChunkFactory:setMainChunk(x, y)
	local chunk = self:getChunk(x, y)
	if not chunk or type(chunk) == "number" then return end

	if self.main_chunk then
		local x, y = self.main_chunk:getPosition()
		for k, neighbor in pairs(self:getNeighbors(x, y)) do
			if type(neighbor) == "table" then
				self:unloadChunk(x, y)
			end
		end
	end

	self.main_chunk = chunk
	self.main_chunk.active = true
	for k, neighbor in pairs(self:getNeighbors(x, y)) do
		if type(neighbor) == "table" then
			neighbor.active = true
			neighbor.visible = true
		end
	end
	return self.main_chunk
end



function ChunkFactory:loadChunk(x, y)
	local load_path = self.map_name.."/chunks/"..x.."-"..y..".dat"
	-- File found? Then load chunk data
	if love.filesystem.getInfo(load_path) then
		-- load file
		local binary_data = love.filesystem.read(load_path)
		local chunkdata = bitser.loads(binary_data)
		chunkdata.tile_size = self.tile_size
		chunkdata.width = self.tiles_x
		chunkdata.height = self.tiles_y
		return self:addChunk(x, y, chunkdata)
	else
		return generateChunk(self, x, y)
	end
end



function ChunkFactory:unloadChunk(x, y)
	local unload_path = "/"..self.map_name.."/chunks/"
	-- Create level directory if necessary
	if not love.filesystem.getInfo(unload_path) then
		love.filesystem.createDirectory(unload_path)
	end

	local chunk = self:getChunk(x, y)
	if type(chunk) == "number" then return end

	-- Set output
	local chunkfile_path = unload_path..x.."-"..y..".dat"

	-- Get save data and write it to the file
	local save_data = bitser.dumps(chunk:getSaveData())

	-- Save file
	love.filesystem.write(chunkfile_path, save_data)

	self.chunks:set(x, y, 0)
end



function ChunkFactory:updateProximity(x, y, camx, camy, scale)
	-- ! Load proximity chunks
	-- ! unload chunks not in proximity
	local wx = floor(((x + camx) / self.tiles_x  / self.tile_size / scale) + 1)
	local wy = floor(((y + camy) / self.tiles_y / self.tile_size / scale) + 1)
	local chunk = self:getChunk(wx, wy)
	if chunk == self.main_chunk then return end


	-- Generate new random chunk --
	if type(chunk) == "number" then self:loadChunk(wx, wy) end
	-- Set the chunk as currently selected --
	self:setMainChunk(wx, wy)
end



function ChunkFactory:getNeighbors(x, y, load_dist)
	local load_dist = load_dist or self.load_dist
	local neighbors = {}
	for ny = -load_dist, load_dist do
		for nx = -load_dist, load_dist do
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
