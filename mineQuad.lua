local nav = require("navigation")

local function digLine()
	for i = 1, 3 do
		turtle.dig()
		nav.forward(1)
	end
end

local function digQuad()
	digLine()
	nav.turnRight()
	turtle.dig()
	nav.forward(1)
	nav.turnRight()
	digLine()
	nav.turnLeft()
	turtle.dig()
	nav.forward(1)
	nav.turnLeft()
	digLine()
	nav.turnRight()
	turtle.dig()
	nav.forward(1)
	nav.turnRight()
	digLine()
end

digQuad()
nav.turnRight()
nav.forward(3)
nav.turnRight()
