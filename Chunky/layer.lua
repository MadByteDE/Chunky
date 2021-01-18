

local Layer = {}
Layer.__index = Layer
setmetatable(Layer, {__call = function(cls, ...) return cls.new(...) end})

local cwd = (...):gsub('%.layer$', '') .. "."
local Grid = require(cwd .. "grid")
local Tile = require(cwd .. "tile")



local function generateTiles(self)
	for y = 1, self.height do
		for x = 1, self.width do
			local tiledata = {
				tile_size 	= self.tile_size,
				color				= {math.random(50)/100, math.random(50)/100, math.random(50)/100, 1} }
			self:setTile(x, y, tiledata)
		end
	end
end



local function convertToWorld(self)
	local w, h = self.width*self.tile_size, self.height*self.tile_size
	local x, y = self.x*w-w, self.y*h-h
	return {x=x, y=y, width=w, height=h}
end



--------------------------------------------------------------------------------------------------------------

function Layer.new(layerdata)
	local self 	= setmetatable({}, Layer)
	local layerdata = layerdata or {}
	self.name				= layerdata.name or "Layer"
	self.tile_size	= layerdata.tile_size
	self.x					= layerdata.x
	self.y					= layerdata.y
	self.width			= layerdata.width
	self.height			= layerdata.height
	self.properties = {
		opacity		= layerdata.opacity or .1
	}
	self.world			= convertToWorld(self)
	self.canvas			= love.graphics.newCanvas(self.width*self.tile_size, self.height*self.tile_size)
	self.tiles			= Grid(self.width, self.height)
	if layerdata.tiles then
		self.tiles:iterate(function(x, y, item)
			local tiledata = layerdata.tiles[y][x]
			tiledata.tile_size = self.tile_size
			self:setTile(x, y, tiledata)
		end)
	else generateTiles(self) end
	self:updateCanvas()
	return self
end



function Layer:updateCanvas()
	local previousCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()
	self.tiles:draw()
	love.graphics.setCanvas(previousCanvas)
end



function Layer:setTile(x, y, tiledata)
	return self.tiles:set(x, y, Tile(x, y, tiledata))
end



function Layer:getSaveData()
	local tiles = Grid(self.width, self.height)
	self.tiles:iterate(function(x, y, item)
		tiles:set(x, y, item:getSaveData())
	end)
	return {
		name = self.name,
		properties = self.properties,
		tiles = tiles:get(),
	}
end



function Layer:update(dt)
end



function Layer:draw()
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.setColor(1, 1, 1, self.properties.opacity)
	love.graphics.draw(self.canvas, self.world.x, self.world.y)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setBlendMode("alpha")
end

return Layer
