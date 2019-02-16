local player = {}

function player.new(world, input, draw)
    local body = love.physics.newBody(world, 0, 10, "dynamic")
    body:setFixedRotation(true)
    local shape = love.physics.newRectangleShape(10, 10)
    local fixture = love.physics.newFixture(body, shape, 1)
    local pl =
        setmetatable(
        {
            world = world,
            input = input,
            draw = draw,
            body = body,
            shape = shape,
            fixture = fixture,
            x = 0,
            y = 0,
            w = 10,
            h = 10,
            vx = 0,
            vy = 0,
            state = "stand"
        },
        {__index = player}
    )
    return pl
end

function player:update(dt)
    ix, iy = self.input.getAxis()
    if self.state == "stand" then
        self.body:applyForce(ix, iy)
        if self.input:getJump() then
            self.state = "jump"
            self.vy = 1
        end
    elseif self.state == "jump" then
        self.vy = self.vy - 0.01
    end
    self.x = self.x + self.vx
    self.y = self.y + self.vy
    if self.y < 0 then
        self.y = 0
        self.vy = 0
        self.state = "stand"
    end
end

function player:render()
    self.draw:polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
    -- self.draw:rect("fill", self.x, self.y, self.w, self.h)
end

return player
