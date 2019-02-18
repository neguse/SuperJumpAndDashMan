local input = {}

function input.new()
	local inp =
		setmetatable(
		{
			nowJump = false,
			prevJump = false,
			nowDash = false,
			prevDash = false
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
		self.nowJump = self.nowJump or joysticks[1]:isDown(2)
	end

	self.prevDash = self.nowDash
	self.nowDash = love.keyboard.isDown("z")
	local joysticks = love.joystick.getJoysticks()
	if #joysticks > 0 then
		self.nowDash = self.nowDash or joysticks[1]:isDown(1)
	end
end

function normalizeCoord(x, y)
	local a = math.atan2(x, y) - math.pi * 0.5
	local l = math.min(math.sqrt(x * x + y * y), 1)
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
		local joystick = joysticks[1]
		-- axes
		dir1, dir2 = joystick:getAxes()
		x = x + math.min(math.max(dir1 * 1.2, -1), 1)
		-- hat
		local h1 = joystick:getHat(1)
		if string.find(h1, "l") then
			x = x - 1
		end
		if string.find(h1, "r") then
			x = x + 1
		end
	end
	return normalizeCoord(x, y)
end

function input:getJump()
	return self.nowJump and not self.prevJump
end

function input:getDash()
	return self.nowDash and not self.prevDash
end

return input
