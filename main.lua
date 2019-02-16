local camera = require 'camera'
local player = require 'player'
local input = require 'input'

local pl = player.new()
local cam = camera.new()
local inp = input.new()

function love.load()
end

function love.update()
    x, y = inp.getAxis()
    pl:addPos(x, y)
end

function love.draw()
    cam:push()

    pl:render()
    love.graphics.rectangle('fill', 10, 10, 30, 30)
    love.graphics.print("Hello World こんにちは！！！", 400, 300)
    
    cam:pop()
end
