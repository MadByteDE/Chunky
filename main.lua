

local Chunky = require("Chunky")
local map


function love.load()
	math.randomseed(os.time()*love.timer.getDelta())
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setBackgroundColor(.1, .3, .2)
	map = Chunky()
end



function love.update(dt)
	local dt = math.min(dt, 0.066)
	map:update(dt)
end



function love.draw()
	map:draw()
	love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
end



function love.keypressed(key, scancode, isrepeat)
	if key == "r" then love.load() end
	if key == "escape" then love.event.quit() end
end



function love.wheelmoved(x, y)
	map:wheelmoved(x, y)
end
