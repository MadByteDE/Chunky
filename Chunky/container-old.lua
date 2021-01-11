

local Container = {}
Container.__index = Container
setmetatable(Container, {__call = function(cls, ...) return cls.new(...) end})



function Container.new(item)
	local self 	= setmetatable({}, Container)
	self:add(item)
	return self, item
end



function Container:add(item)
	if not self.items then self.items = {} end
	self.items[#self.items+1] = item
	return item
end



function Container:update(dt)
	for i=#self.items, 1, -1 do
		local item = self.items[i]
		if not item.removed then
			if item.update then item:update(dt) end
		else table.remove(self.items, i) end
	end
end



function Container:draw()
	for i=#self.items, 1, -1 do
		local item = self.items[i]
		if item.draw then item:draw() end
	end
end

return Container
