

local Chunk = {}
Chunk.__index = Chunk
setmetatable(Chunk, {__call = function(cls, ...) return cls.new(...) end})

local cwd = (...):gsub('%.chunk$', '') .. "."
local Container	 = require(cwd .. "conta")
local Layer			 = require(cwd .. "layer")



local function convertToWorld(self)
	local w, h = self.width*self.tilesize, self.height*self.tilesize
	local x, y = self.x*w-w, self.y*h-h
	return {x=x, y=y, width=w, height=h}
end


--------------------------------------------------------------------------------------------------------------

function Chunk.new(x, y, chunkdata)
	local self = setmetatable({}, Chunk)
	local chunkdata 	= chunkdata or {}
	self.tilesize			= chunkdata.tilesize
	self.x						= x
	self.y						= y
	self.width				= chunkdata.width
	self.height				= chunkdata.height
	self.visible			= chunkdata.visible or true
	self.active				= chunkdata.active or true
	self.layers				= Container()
	self.objects			= Container()
	self.world				= convertToWorld(self)

	self:addLayer(layerdata)
	return self
end



function Chunk:getPosition()
	return self.x, self.y
end



function Chunk:getSaveData()
	local layers = {}
	local objects = {}
	self.layers:iterate(function(k, layer) layers[k] = layer:getSaveData() end)
	self.objects:iterate(function(k, object) objects[k] = object:getSaveData() end)
	return {
		x = self.x,
		y = self.y,
		layers = layers,
		objects = objects,
	}
end



function Chunk:addLayer(layerdata)
	local layerdata 	= layerdata or
	{ tilesize 	= self.tilesize,
		x					= self.x,
		y					= self.y,
		width 		= self.width,
		height 		= self.height }
	return self.layers:add(Layer(layerdata))
end



function Chunk:update(dt)
	if self.active then
		self.layers:update(dt)
		self.objects:update(dt)
	end
end



function Chunk:draw()
	if self.visible then self.layers:draw() end
	if self.active then love.graphics.setColor(1, 1, 0, 1)
	else love.graphics.setColor(1, 1, 1, 1) end
	love.graphics.rectangle("line", self.world.x, self.world.y, self.world.width, self.world.height)
	love.graphics.setColor(1, 1, 1, 1)
end

return Chunk
