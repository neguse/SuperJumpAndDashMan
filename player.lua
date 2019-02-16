
local player = {}

function player.new()
    local pl = setmetatable({
        x = 0,
        y = 0,
        w = 100,
        h = 100,
    }, {__index = player})
    return pl
end

function player:addPos(x, y)
    self.x = self.x + x
    self.y = self.y + y
end

function player:render()
    love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.h, self.w, self.h)
end

return player