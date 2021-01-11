

local Tile = {}
Tile.__index = Tile
setmetatable(Tile, {__call = function(cls, ...) return cls.new(...) end})



local function convertToWorld(self)
	local x, y = self.x*self.tilesize-self.tilesize, self.y*self.tilesize-self.tilesize
	return {x=x, y=y}
end



--------------------------------------------------------------------------------------------------------------

function Tile.new(x, y, tiledata)
	local self = setmetatable({}, Tile)
	local tiledata	= tiledata or {}
	self.id					= tiledata.id or 0
	self.tilesize 	= tiledata.tilesize or 16
	self.x					= x
	self.y					= y
	self.world			= convertToWorld(self)
	self.color			=	tiledata.color or {1, 1, 1, 1}
	self.image			= tiledata.image or nil
	self.quad				= tiledata.quad or nil
	return self
end



function Tile:update(dt)
end



function Tile:draw()
	local previousColor = {love.graphics.getColor()}
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill", self.world.x, self.world.y, self.tilesize, self.tilesize)
	love.graphics.setColor(previousColor)
end

return Tile
