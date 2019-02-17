local item = {}

local radius = 50

function item.new(world, x, y, type)
	local body = love.physics.newBody(world, x, y, "dynamic")
	local shape = love.physics.newCircleShape(radius)
	local fixture = love.physics.newFixture(body, shape, 1)

	local it =
		setmetatable(
		{
			type = type,
			body = body,
			shape = shape,
			fixture = fixture,
			consumed = false
		},
		{__index = item}
	)
	fixture:setUserData(it)

	return it
end

function item:destroy()
	self.fixture:destroy()
end

function item:getType()
	return self.type
end

function item:isConsumed()
	return self.consumed
end

function item:consume()
	if self.consumed then
		return false
	end
	self.consumed = true
	return true
end

function item:render()
	x, y = self.body:getPosition()
	r = self.shape:getRadius()
	love.graphics.circle("line", x, y, r)
	love.graphics.print(self.type, x - radius / 2, y + radius, 0, 5, -5, 0, 0)
end

return item
