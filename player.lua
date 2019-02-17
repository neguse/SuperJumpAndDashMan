local player = {}

local width = 25
local height = 50
local killY = -3000

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
			jumpMax = 0,
			dashMax = 0,
			jumpNum = 0,
			dashNum = 0,
			jumpRepair = 0,
			dashRepair = 0,
			dashTime = 0,
			dead = false,
			shadows = {},
			respawnPoint = nil,
			groundConsequent = 0,
			state = "ground"
		},
		{__index = player}
	)
	fixture:setUserData(pl)
	return pl
end

function player:getType()
	return "P"
end

function player:setRespawnPoint(x, y)
	self.respawnPoint = {x = x, y = y}
end

function player:respawn()
	local point = self.respawnPoint
	self:warpTo(point.x, point.y)
	self.camera:set(point.x, point.y)
	self.dead = false
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
	return self.jumpNum > 0
end

function player:dashable()
	return self.dashNum > 0 and not (self.dashTime > 0)
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
	else
		self.state = "air"
	end

	if self.state == "ground" then
		if self.dashNum < self.dashMax then
			self.dashRepair = self.dashRepair - 1
			if self.dashRepair <= 0 then
				self.dashRepair = 2
				self.dashNum = self.dashMax
			end
		end
		if self.jumpNum < self.jumpMax then
			self.jumpRepair = self.jumpRepair - 1
			if self.jumpRepair <= 0 then
				self.jumpRepair = 2
				self.jumpNum = self.jumpMax
			end
		end
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
		self.dashNum = self.dashNum - 1
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
		self.jumpNum = self.jumpNum - 1
	end

	local x, y = self:getPosition()
	if y < killY then
		self.dead = true
	end

	if self.dead then
		self:respawn()
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
	love.graphics.print(string.format("jump: %d %d %d", self.jumpNum, self.jumpMax, self.jumpRepair), 0, 60)
	love.graphics.print(string.format("dash: %d %d %d", self.dashNum, self.dashMax, self.dashRepair), 0, 80)
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

function player:onContact(o)
	local t = o:getType()
	if o.type == "K" then
		self.dead = true
		return
	end
	if o:consume() then
		if t == "J" then
			self.jumpMax = self.jumpMax + 1
		elseif t == "D" then
			self.dashMax = self.dashMax + 1
		end
	end
end

return player
