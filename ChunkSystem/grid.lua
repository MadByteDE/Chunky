

local Grid = {}
Grid.__index = Grid
setmetatable(Grid, {__call = function(cls, ...) return cls.new(...) end})



local function clearGrid(self, width, height)
	local grid = {}
	for y=1, height do
		grid[y] = {}
		for x=1, width do
			grid[y][x] = 0
		end
	end
	return grid
end



function Grid.new(width, height)
	local self 	= setmetatable({}, Grid)
	self.name		= name or "Grid"
	self.width	= width
	self.height	= height
	self.grid		= clearGrid(self, width, height)
	return self
end



function Grid:set(x, y, item)
	local x = math.floor(x)
	local y = math.floor(y)
	if self.grid[y] and self.grid[y][x] then
		self.grid[y][x] = item
		--print(self.name..": Item at {"..x..", "..y.."} has been set")
	end
	return item
end



function Grid:get(x, y)
	local x = math.floor(x)
	local y = math.floor(y)
	if self.grid[y] and self.grid[y][x] then
		return self.grid[y][x]
	end
end



function Grid:update(dt)
	for y=1, self.height do
		for x=1, self.width do
			local item = self.grid[y][x]
			if type(item) == "table" and item.update then item:update(dt) end
		end
	end
end



function Grid:draw()
	for y=1, self.height do
		for x=1, self.width do
			local item = self.grid[y][x]
			if type(item) == "table" and item.draw then item:draw() end
		end
	end
end

return Grid
