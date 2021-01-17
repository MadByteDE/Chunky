

local Tile = {}
Tile.__index = Tile
setmetatable(Tile, {__call = function(cls, ...) return cls.new(...) end})



local function convertToWorld(self)
	local x, y = self.x*self.tile_size-self.tile_size, self.y*self.tile_size-self.tile_size
	return {x=x, y=y}
end



--------------------------------------------------------------------------------------------------------------

function Tile.new(x, y, tiledata)
	local self = setmetatable({}, Tile)
	local tiledata	= tiledata or {}
	self.id					= tiledata.id or 0
	self.tile_size 	= tiledata.tile_size or 16
	self.x					= x
	self.y					= y
	self.world			= convertToWorld(self)
	self.properties = nil
	self.color			=	tiledata.color or {1, 1, 1, 1}
	self.image			= tiledata.image or nil
	self.quad				= tiledata.quad or nil
	return self
end



function Tile:getSaveData()
	return {
		id = self.id,
		properties = self.properties,
		color = self.color,
	}
end



function Tile:update(dt)
end



function Tile:draw()
	local previousColor = {love.graphics.getColor()}
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", self.world.x, self.world.y, self.tile_size, self.tile_size)
	love.graphics.setColor(previousColor)
end

return Tile
