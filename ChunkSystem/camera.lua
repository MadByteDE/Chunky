

local Camera = {}
Camera.__index = Camera
setmetatable(Camera, {__call = function(cls, ...) return cls.new(...) end})


function Camera.new(x, y, scale)
	local self = setmetatable({}, Camera)

	self:setScale(scale)
	self:setPosition(x, y)
	self:setSpeed()

	return self
end



function Camera:move(dx, dy, dt)
	local dt = dt or love.timer.getDelta()
	if dx > 0 then self.x = self.x + self.speed * dt
	elseif dx < 0 then self.x = self.x - self.speed * dt end
	if dy > 0 then self.y = self.y + self.speed * dt
	elseif dy < 0 then self.y = self.y - self.speed * dt end
end



function Camera:setSpeed(speed)
	self.speed = speed or self.speed or 200
end



function Camera:setPosition(x, y)
	self.x = math.floor(-(x or self.x or 0))
	self.y = math.floor(-(y or self.y or 0))
end



function Camera:rescale(step)
	self.scale = self.scale + step
end



function Camera:setScale(scale)
	self.scale = scale or self.scale or 1
end



function Camera:getScale()
	return self.scale
end



function Camera:getVisibleArea()
	local sw, sh = love.graphics.getDimensions()
	return self.x/self.scale, self.y/self.scale, sw/self.scale, sh/self.scale
end



function Camera:isVisible(x, y, width, height)
	local vx, vy, vw, vh = self:getVisibleArea()
	return x+width>vx and y+width>vy and x<vx+vw and y<vy+vh
end



function Camera:set()
	love.graphics.push()
	love.graphics.origin()
	love.graphics.translate(math.floor(-self.x), math.floor(-self.y))
	love.graphics.scale(self.scale, self.scale)
end



function Camera:unset()
	love.graphics.pop()
end

return Camera
