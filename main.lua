local camera = require "camera"
local player = require "player"
local input = require "input"
local draw = require "draw"

local dr = draw.new()
local world = love.physics.newWorld(0, -0.1, true)
local ground = {}
local inp = input.new()
local pl = player.new(world, inp, dr)
local cam = camera.new()

function love.load()
    ground.b = love.physics.newBody(world, 0, 0, "static")
    ground.s = love.physics.newRectangleShape(100, 10)
    ground.f = love.physics.newFixture(ground.b, ground.s, 1)
end

function love.update(dt)
    world:update(dt)
    inp:update()
    pl:update(dt)
end

function love.draw()
    cam:push()

    pl:render()
    dr:polygon("fill", ground.b:getWorldPoints(ground.s:getPoints()))
    -- love.graphics.rectangle("fill", 10, 10, 30, 30)
    love.graphics.print("Hello World こんにちは！！！", 400, 300)

    cam:pop()
end
