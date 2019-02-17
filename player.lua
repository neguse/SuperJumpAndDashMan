local player = {}

local width = 25
local height = 50

function player.new(world, input, draw, camera)
	local body = love.physics.newBody(world, 0, 10, "dynamic")
	local shape = love.physics.newRectangleShape(width, height)
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
			dashInAir = 1,
			jumpInAir = 1,
			shadows = {},
			state = "ground"
		},
		{__index = player}
	)
	return pl
end

function player:warpTo(x, y)
	self.body:setPosition(x, y)
end

function player:getPosition()
	return self.body:getPosition()
end

function player:dashing()
	return self.dashTime > 0
end

function player:getVelocity()
	return self.body:getLinearVelocity()
end

function player:jumpable()
	return self.state == "ground" or (self.state == "air" and self.jumpInAir > 0)
end

function player:dashable()
	return not (self.dashTime > 0) and (self.state == "ground" or (self.state == "air" and self.dashInAir > 0))
end

function player:addShadow()
	x, y = self:getPosition()
	table.insert(self.shadows, {x = x, y = y})
end

function player:consumeShadow()
	table.remove(self.shadows, 1)
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
		self.state = "ground"
		self.dashInAir = 1
		self.jumpInAir = 1
	else
		self.state = "air"
	end

	self:addShadow()
	if self:dashing() then
		self.dashTime = self.dashTime - dt
	end
	if #self.shadows > 16 then
		self:consumeShadow()
	end

	-- move x
	local force = 10
	local velocity = 250
	if self:dashing() then
		velocity = 700
	end
	local vx, vy = self:getVelocity()
	self.body:applyForce(force * (ix * velocity - vx), 0)

	-- dash x
	if self.input:getDash() and self:dashable() then
		local force = 10
		local velocity = 300
		local vx, vy = self.body:getLinearVelocity()
		self.body:applyLinearImpulse(ix * force * math.max(velocity - math.abs(vx), 0), 0)
		self.dashTime = 0.5
		if self.state == "air" then
			self.dashInAir = self.dashInAir - 1
		end
	end

	-- jump
	if self.input:getJump() and self:jumpable() then
		local xx, yy = 0, 0
		for i, contact in ipairs(contacts) do
			local x, y = contact:getNormal()
			xx, yy = xx + x, yy + y
		end
		local a = -math.atan2(xx, yy) + math.pi * 0.5 -- angle of normal
		local vx, vy = self:getVelocity()
		local jumpUpVelo = 500
		local jumpNormalVelo = 200
		local nvx, nvy = 0, jumpUpVelo
		nvx = nvx + math.cos(a) * jumpNormalVelo
		nvy = nvy + math.sin(a) * jumpNormalVelo
		local dvx, dvy = nvx - vx, nvy - vy
		local mass = self.body:getMass()
		local fx, fy = dvx * mass, dvy * mass
		self.body:applyLinearImpulse(fx, fy)
		if self.state == "air" then
			self.jumpInAir = self.jumpInAir - 1
		end
	end

	-- camera
	local vl = math.sqrt(vx * vx, vy * vy)
	local ts = 0.5 - 0.25 * math.min(vl * 0.002, 1)
	local x, y = self.body:getPosition()
	self.camera:target(x, y, ts)
end

function player:renderui()
	love.graphics.print(string.format("state: %8s %8s", self.state, self.dashTime > 0 and "dash" or "nodash"))
	local x, y = self.body:getPosition()
	love.graphics.print(string.format("pos: %6.1f %6.1f", x, y), 0, 20)
	local vx, vy = self.body:getLinearVelocity()
	love.graphics.print(string.format("velo: %6.1f %6.1f", vx, vy), 0, 40)

	-- love.graphics.print("velo:" .. self.state)
end

function pack(...)
	return {n = select("#", ...), ...}
end

function player:renderShadow()
	local points = pack(self.shape:getPoints())
	for i, shadow in ipairs(self.shadows) do
		local newPoints = {}
		for pi = 1, #points, 2 do
			local px, py = points[pi] + shadow.x, points[pi + 1] + shadow.y
			table.insert(newPoints, px)
			table.insert(newPoints, py)
		end
		self.draw:polygon("line", newPoints)
	end
end

function player:render()
	self.draw:polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
	if not self:dashable() then
		self:renderShadow()
	end
	if self:jumpable() then
		local x, y = self.body:getPosition()
		love.graphics.ellipse("line", x, y - height / 2, 30, 10)
	end
end

return player
