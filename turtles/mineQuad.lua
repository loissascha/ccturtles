local nav = require("navigation")

local mineQuad = {}

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

function mineQuad.run()
	digQuad()
	nav.turnRight()
	nav.forward(3)
	nav.turnRight()
end

function mineQuad.runCustomSize(rows, cols)
	local startPos = nav.getPosition()
	local startFacing = nav.getFacing()

	local turnRight = true
	for row = 1, rows do
		for col = 1, cols do
			turtle.dig()
			nav.forward(1)
		end
		if row < rows then
			if turnRight then
				nav.turnRight()
				turtle.dig()
				nav.forward(1)
				nav.turnRight()
				turnRight = false
			else
				nav.turnLeft()
				turtle.dig()
				nav.forward(1)
				nav.turnLeft()
				turnRight = true
			end
		end
	end

	nav.goTo(startPos.x, startPos.y, startPos.z)
	nav.turnTo(startFacing)
end

return mineQuad
