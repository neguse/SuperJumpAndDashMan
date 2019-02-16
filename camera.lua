local camera = {}

function camera.new()
    local cam =
        setmetatable(
        {
            x = 0,
            y = 0,
            tx = 0,
            ty = 0,
            scale = 1
        },
        {__index = camera}
    )
    return cam
end

function camera:push()
    love.graphics.push()
    love.graphics.translate(-self.x + love.graphics.getWidth() / 2, self.y + love.graphics.getHeight() / 2)
    love.graphics.scale(self.scale, -self.scale)
end

function camera:pop()
    love.graphics.pop()
end

function camera:update(dt)
    if math.abs(self.tx - self.x) > 300 then
        self.x = self.x + (self.tx - self.x) * dt * 1
    end
    if math.abs(self.ty - self.y) > 200 then
        self.y = self.y + (self.ty - self.y) * dt * 1
    end
end

function camera:set(x, y)
    self.x, self.tx = x
    self.y, self.ty = y
end

function camera:target(x, y)
    self.tx, self.ty = x, y
end

return camera
