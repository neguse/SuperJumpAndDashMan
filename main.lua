local camera = require "camera"
local player = require "player"
local input = require "input"
local draw = require "draw"
local map = require "map"

local dr = draw.new()
local cam = camera.new()
local world = love.physics.newWorld(0, -1000, true)
local map = map.new(world)
local inp = input.new()
local pl = player.new(world, inp, dr, cam)

function love.load()
	pl:warpTo(map:getStartPoint())
end

function love.update(dt)
	world:update(dt)
	inp:update()
	pl:update(dt)
	cam:update(dt)
end

function love.draw()
	cam:push()

	dr:grid()

	pl:render()
	map:render()
	love.graphics.print("Hello World こんにちは！！！", 400, 300)

	cam:pop()
	pl:renderui()
end
