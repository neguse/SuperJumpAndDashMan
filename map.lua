local mapdata = require "mapdata"
local item = require "item"

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

local kill = {}
function kill:getType()
	return self.type
end

function map.new(world)
	local platform = nil
	local startPoint = nil
	local items = {}
	for i, layer in ipairs(mapdata.layers) do
		if layer.name == "platform" then
			local bodies = {}
			kills = {}
			for i2, obj in ipairs(layer.objects) do
				if obj.shape == "rectangle" then
					local angle = -math.rad(obj.rotation)
					local offx, offy = rotated(obj.width / 2, -obj.height / 2, angle)
					local body = love.physics.newBody(world, obj.x + offx, -obj.y + offy, "static")
					local shape = love.physics.newRectangleShape(0, 0, obj.width, obj.height, angle)
					local fixture = love.physics.newFixture(body, shape, 1)
					if obj.type == "kill" then
						ud = setmetatable({type = "K"}, {__index = kill})
						fixture:setUserData(ud)
						table.insert(kills, body)
					else
						table.insert(bodies, body)
					end
				elseif obj.shape == "point" and obj.type == "entry" then
					startPoint = {x = obj.x, y = -obj.y}
				elseif obj.shape == "point" and obj.type == "itemJump" then
					table.insert(items, item.new(world, obj.x, obj.y, "J"))
				elseif obj.shape == "point" and obj.type == "itemDash" then
					table.insert(items, item.new(world, obj.x, obj.y, "D"))
				end
			end
			platform = {
				bodies = bodies,
				kills = kills,
				items = items
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

function map:update()
	local i = 1
	while i <= #self.platform.items do
		local item = self.platform.items[i]
		if item:isConsumed() then
			item:destroy()
			table.remove(self.platform.items, i)
		else
			i = i + 1
		end
	end
end

function map:render()
	for _, body in ipairs(self.platform.bodies) do
		for _, fixture in ipairs(body:getFixtures()) do
			love.graphics.polygon("fill", body:getWorldPoints(fixture:getShape():getPoints()))
		end
	end
	love.graphics.setColor(0xff, 0x00, 0x00, 0xff)
	for _, body in ipairs(self.platform.kills) do
		for _, fixture in ipairs(body:getFixtures()) do
			love.graphics.polygon("fill", body:getWorldPoints(fixture:getShape():getPoints()))
		end
	end
	love.graphics.setColor(0xff, 0xff, 0xff, 0xff)

	for _, item in ipairs(self.platform.items) do
		item:render()
	end
end

return map
