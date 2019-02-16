local camera = require "camera"
local player = require "player"
local input = require "input"
local draw = require "draw"

local dr = draw.new()
local cam = camera.new()
local world = love.physics.newWorld(0, -1000.0, true)
local ground1 = {}
local ground2 = {}
local ground3 = {}
local inp = input.new()
local pl = player.new(world, inp, dr, cam)

function love.load()
    ground1.b = love.physics.newBody(world, 0, 0, "static")
    ground1.s = love.physics.newRectangleShape(1200, 10)
    ground1.f = love.physics.newFixture(ground1.b, ground1.s, 1)

    ground2.b = love.physics.newBody(world, 600, 0, "static")
    ground2.s = love.physics.newRectangleShape(10, 1000)
    ground2.f = love.physics.newFixture(ground2.b, ground2.s, 1)

    ground3.b = love.physics.newBody(world, -600, 0, "static")
    ground3.s = love.physics.newRectangleShape(10, 1000)
    ground3.f = love.physics.newFixture(ground3.b, ground3.s, 1)
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
    dr:polygon("fill", ground1.b:getWorldPoints(ground1.s:getPoints()))
    dr:polygon("fill", ground2.b:getWorldPoints(ground2.s:getPoints()))
    dr:polygon("fill", ground3.b:getWorldPoints(ground3.s:getPoints()))
    -- love.graphics.rectangle("fill", 10, 10, 30, 30)
    love.graphics.print("Hello World こんにちは！！！", 400, 300)

    cam:pop()
    pl:renderui()
end
