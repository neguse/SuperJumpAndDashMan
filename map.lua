local mapdata = require "mapdata"

local map = {}

-- newPolygonShape expects 3~8 vertices
function polylineToShape(polylines)
	local vertices = {}
	for _, polyline in ipairs(polylines) do
		table.insert(vertices, polyline.x)
		table.insert(vertices, -polyline.y)
	end
	return love.physics.newChainShape(false, vertices)
end

function rotated(x, y, angle)
	local nx = x * math.cos(angle) - y * math.sin(angle)
	local ny = x * math.sin(angle) + y * math.cos(angle)
	return nx, ny
end

function map.new(world)
	local platform = nil
	local startPoint = nil
	for i, layer in ipairs(mapdata.layers) do
		if layer.name == "platform" then
			local bodies = {}
			for i2, obj in ipairs(layer.objects) do
				if obj.shape == "rectangle" then
					local angle = -math.rad(obj.rotation)
					local offx, offy = rotated(obj.width / 2, -obj.height / 2, angle)
					local body = love.physics.newBody(world, obj.x + offx, -obj.y + offy, "static")
					local shape = love.physics.newRectangleShape(0, 0, obj.width, obj.height, angle)
					love.physics.newFixture(body, shape, 1)
					table.insert(bodies, body)
				elseif obj.shape == "point" and obj.type == "entry" then
					startPoint = {x = obj.x, y = -obj.y}
				end
			end
			platform = {
				bodies = bodies
			}
		end
	end

	return setmetatable(
		{
			platform = platform,
			startPoint = startPoint
		},
		{__index = map}
	)
end

function map:getStartPoint()
	return self.startPoint.x, self.startPoint.y
end

function map:render()
	for _, body in ipairs(self.platform.bodies) do
		for _, fixture in ipairs(body:getFixtures()) do
			love.graphics.polygon("fill", body:getWorldPoints(fixture:getShape():getPoints()))
		end
	end
end

return map
