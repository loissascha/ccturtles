local function digLine()
	for i = 1, 4 do
		turtle.dig()
		turtle.forward()
	end
end

local function digQuad()
	digLine()
	turtle.turnRight()
	turtle.dig()
	turtle.forward()
	turtle.turnRight()
	digLine()
	turtle.turnLeft()
	turtle.dig()
	turtle.forward()
	turtle.turnLeft()
	digLine()
	turtle.turnRight()
	turtle.dig()
	turtle.forward()
	turtle.turnRight()
	digLine()
end

local args = { ... }
local depth = tonumber(args[1]) or 30

for i = 1, depth do
	digQuad()
	turtle.turnRight()
	turtle.forward()
	turtle.forward()
	turtle.forward()
	turtle.turnRight()
	turtle.digDown()
	turtle.down()
	turtle.select(1)
	turtle.refuel()
end
for i = 1, depth do
	turtle.up()
end
