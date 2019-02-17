local camera = {}

function camera.new()
	local cam =
		setmetatable(
		{
			x = 0,
			y = 0,
			tx = 0,
			ty = 0,
			ts = 0,
			s = 0.2
		},
		{__index = camera}
	)
	return cam
end

function camera:push()
	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
	love.graphics.scale(self.s, self.s)
	love.graphics.translate(-self.x, self.y)
	love.graphics.scale(1, -1)
end

function camera:pop()
	love.graphics.pop()
end

function camera:update(dt)
	if math.abs(self.tx - self.x) > 300 then
		self.x = self.x + (self.tx - self.x) * dt * 5
	end
	if math.abs(self.ty - self.y) > 200 then
		self.y = self.y + (self.ty - self.y) * dt * 5
	end
	self.s = self.s + (self.ts - self.s) * dt
end

function camera:set(x, y)
	self.x, self.tx = x
	self.y, self.ty = y
end

function camera:target(x, y, s)
	self.tx, self.ty, self.ts = x, y, s
end

return camera
