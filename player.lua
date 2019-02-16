local player = {}

function player.new(world, input, draw, camera)
    local body = love.physics.newBody(world, 0, 10, "dynamic")
    local shape = love.physics.newRectangleShape(50, 50)
    local fixture = love.physics.newFixture(body, shape, 1)
    body:setFixedRotation(true)
    -- body:setMass(0.1)
    local pl =
        setmetatable(
        {
            world = world,
            input = input,
            draw = draw,
            camera = camera,
            body = body,
            shape = shape,
            fixture = fixture,
            state = "stand"
        },
        {__index = player}
    )
    return pl
end

function player:update(dt)
    local ix, iy = self.input.getAxis()
    local contacts = self.body:getContacts()
    local touchNum = 0
    for i, contact in ipairs(contacts) do
        if contact:isTouching() then
            touchNum = touchNum + 1
        end
    end
    if touchNum > 0 then
        self.state = "stand"
    else
        self.state = "jump"
    end

    -- move x
    local force = 10
    local velocity = 250
    local vx, vy = self.body:getLinearVelocity()
    self.body:applyForce(ix * force * math.max(velocity - math.abs(vx), 0), 0)

    -- jump
    if self.state == "stand" then
        if self.input:getJump() then
            local xx, yy = 0, 0
            for i, contact in ipairs(contacts) do
                local x, y = contact:getNormal()
                print(i, x, y)
                xx, yy = xx + x, yy + y
            end
            local a = -math.atan2(xx, yy) - math.pi * 0.5
            local jumpUpForce = 0.8 * 2000
            local jumpNormalForce = 0.2 * 2000
            print(a)
            self.body:applyLinearImpulse(math.cos(a) * jumpNormalForce, math.sin(a) * jumpNormalForce + jumpUpForce)
        end
    end
    self.camera:target(self.body:getPosition())
end

function player:renderui()
    love.graphics.print("state:" .. self.state)
end

function player:render()
    self.draw:polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
    -- self.draw:rect("fill", self.x, self.y, self.w, self.h)
end

return player
