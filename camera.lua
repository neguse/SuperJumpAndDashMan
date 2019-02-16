local camera = {}

function camera.new()
    local cam =
        setmetatable(
        {
            x = 0,
            y = 0,
            scale = 2
        },
        {__index = camera}
    )
    return cam
end

function camera:push()
    love.graphics.push()
    love.graphics.translate(self.x + love.graphics.getWidth() / 2, self.y + love.graphics.getHeight())
    love.graphics.scale(self.scale, -self.scale)
end

function camera:pop()
    love.graphics.pop()
end

function camera:setPos(x, y)
    self.x = x
    self.y = y
end

return camera
