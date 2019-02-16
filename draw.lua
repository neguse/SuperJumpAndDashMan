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

function draw:grid()
    local s = 100
    local n = 30
    for ix = -n, n do
        love.graphics.line(ix * s, -s * n, ix * s, s * n)
    end
    for iy = -n, n do
        love.graphics.line(-s * n, iy * s, s * n, iy * s)
    end
end

return draw
