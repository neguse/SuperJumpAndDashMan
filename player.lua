local player = {}

function player.new(world, input, draw, camera)
	local body = love.physics.newBody(world, 0, 10, "dynamic")
	local shape = love.physics.newRectangleShape(25, 50)
	local fixture = love.physics.newFixture(body, shape, 1)
	body:setFixedRotation(true)
	-- print(body:getMass())
	body:setMass(2.77)
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
			dashTime = 0,
			state = "stand"
		},
		{__index = player}
	)
	return pl
end

function player:warpTo(x, y)
	self.body:setPosition(x, y)
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

	self.dashTime = self.dashTime - dt

	-- move x
	local force = 10
	local velocity = 250
	if self.dashTime > 0 then
		velocity = 500
	end
	local vx, vy = self.body:getLinearVelocity()
	self.body:applyForce(force * (ix * velocity - vx), 0)

	-- dash x
	if self.input:getDash() then
		local force = 10
		local velocity = 300
		local vx, vy = self.body:getLinearVelocity()
		self.body:applyLinearImpulse(ix * force * math.max(velocity - math.abs(vx), 0), 0)
		self.dashTime = 0.5
	end

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
			local jumpUpForce = 0.7 * 2000
			local jumpNormalForce = -0.1 * 2000
			print(a)
			self.body:applyLinearImpulse(math.cos(a) * jumpNormalForce, math.sin(a) * jumpNormalForce + jumpUpForce)
		end
	end

	-- camera
	local vl = math.sqrt(vx * vx, vy * vy)
	local ts = 0.5 - 0.25 * math.min(vl * 0.002, 1)
	local x, y = self.body:getPosition()
	self.camera:target(x, y, ts)
end

function player:renderui()
	love.graphics.print("state:" .. self.state)
	local x, y = self.body:getPosition()
	love.graphics.print(string.format("pos: %6.1f %6.1f", x, y), 0, 20)
	local vx, vy = self.body:getLinearVelocity()
	love.graphics.print(string.format("velo: %6.1f %6.1f", vx, vy), 0, 40)

	-- love.graphics.print("velo:" .. self.state)
end

function player:render()
	self.draw:polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	-- self.draw:rect("fill", self.x, self.y, self.w, self.h)
end

return player
