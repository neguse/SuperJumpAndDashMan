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
	self.nowJump = love.keyboard.isDown("x") or love.keyboard.isDown("space")
	local joysticks = love.joystick.getJoysticks()
	if #joysticks > 0 then
		self.nowJump = self.nowJump or joysticks[1]:isDown(1)
	end
end

function normalizeCoord(x, y)
	local a = math.atan2(x, y)
	local l = math.sqrt(x * x + y * y)
	return l * math.cos(a), l * math.sin(a)
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
	joysticks = love.joystick.getJoysticks()
	if #joysticks > 0 then
		dir1, dir2 = joysticks[1]:getAxes()
		x = x - dir2
		y = y + dir1
	end
	return normalizeCoord(x, y)
end

function input:getJump()
	return self.nowJump and not self.prevJump
end

return input
