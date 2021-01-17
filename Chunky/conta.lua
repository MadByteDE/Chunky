

-- conta.lua : Object management library by MadByte


-- Locals --
local function matchType(item, type)
  if string.lower(item._settings.type) == string.lower(type) then return true end
end


-- Constructor --
local Conta = {}
Conta.__index = Conta
setmetatable(Conta, {__call = function(cls, ...) return cls.new(...) end})


function Conta.new()
  return setmetatable({items={}}, Conta)
end


-- Methods --
function Conta:iterate(f)
  for k=#self.items, 1, -1 do
    f(k, self.items[k])
  end
end


function Conta:add(item, settings)
  self.items[#self.items+1] = item
  item._settings = {update=true, draw=true, removed=false, priority=0, type=item.type or "item"}
  self:set(item, settings)
  return item
end


function Conta:remove(item)
  local item = self:get(item)
  item._settings.removed = true
end


function Conta:set(item, settings)
  if not settings then return end
  local item = self:get(item)
  for k, v in pairs(settings) do
    item._settings[k] = v
  end
  if settings.priority and item._settings.priority ~= settings.priority then self:sort() end
end


function Conta:get(item)
  if type(item) == "number" then
    return self.items[item]
  elseif type(item) == "string" then
    local res = {}
    self:iterate(function(k,v)
      if matchType(v, item) then
        res[#res+1] = v end
      end)
    return res

  elseif type(item) == "table" then
    if item._settings then
      return item
    else
      local types = {}
      for i=1, #item do types[item[i]] = {} end
      self:iterate(function(k,v)
        local newtype = types[v._settings.type]
        if newtype then newtype[#newtype+1] = v end
      end)
      return types
    end
  else
    return self.items
  end
end


function Conta:sort(f)
  local f = f or function(a, b) return a._settings.priority < b._settings.priority end
  table.sort(self.items, f)
end


function Conta:clear()
  self.items = {}
end


function Conta:update(dt, type)
  self:iterate(function(k,v)
    if type and not matchType(v, type) then return end
    if v._settings.removed then table.remove(self.items, k)
    else
      if v.update and v._settings.update then v:update(dt) end
    end
  end)
end


function Conta:draw(type)
  for k,v in ipairs(self.items) do
    if type and not matchType(v, type) then return end
    if v.draw and v._settings.draw then v:draw() end
  end
end


return Conta
