local input = {}

function input.new()
    local inp =
        setmetatable(
        {
            nowJump = false,
            prevJump = false
        },
        {__index = input}
    )
    return inp
end

function input:update()
    self.prevJump = self.nowJump
    self.nowJump = love.keyboard.isDown("x")
end

function input:getAxis()
    local x = 0
    local y = 0
    if love.keyboard.isDown("left") then
        x = x - 1
    end
    if love.keyboard.isDown("right") then
        x = x + 1
    end
    if love.keyboard.isDown("up") then
        y = y + 1
    end
    if love.keyboard.isDown("down") then
        y = y - 1
    end
    return x, y
end

function input:getJump()
    return self.nowJump and not self.prevJump
end

return input
