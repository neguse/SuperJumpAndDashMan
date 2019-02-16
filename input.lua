
local input = {}

function input.new()
    local inp = setmetatable({
    }, {__index = input})
    return inp
end

function input:getAxis()
    local x = 0
    local y = 0
    if love.keyboard.isDown('left') then
        x = x - 1
    end
    if love.keyboard.isDown('right') then
        x = x + 1
    end
    if love.keyboard.isDown('up') then
        y = y - 1
    end
    if love.keyboard.isDown('down') then
        y = y + 1
    end
    return x, y
end

return input
