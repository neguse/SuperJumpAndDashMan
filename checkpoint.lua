local checkpoint = {}

local radius = 150

function checkpoint.new(world, x, y)
	local body = love.physics.newBody(world, x, y, "static")
	local shape = love.physics.newCircleShape(radius)
	local fixture = love.physics.newFixture(body, shape, 1)
	fixture:setSensor(true)
	local cp =
		setmetatable(
		{
			body = body,
			shape = shape,
			fixture = fixture
		},
		{__index = checkpoint}
	)
	fixture:setUserData(cp)

	return cp
end

function checkpoint:getType()
	return "C"
end

function checkpoint:getPosition()
	return self.body:getPosition()
end

function checkpoint:render()
	x, y = self.body:getPosition()
	r = self.shape:getRadius()
	love.graphics.circle("line", x, y, r)
	love.graphics.print("checkpoint", x - r, y + r + 80, 0, 4, -4, 0, 0)
end

return checkpoint
