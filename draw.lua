local draw = {}

function draw.new()
    local dr = setmetatable({}, {__index = draw})
    return dr
end

function draw:rect(mode, x, y, w, h)
    love.graphics.rectangle(mode, x - w / 2, y - h / 2, w, h)
end

function draw:polygon(mode, ...)
    love.graphics.polygon(mode, ...)
end

return draw
