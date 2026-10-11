local nav = require("navigation")
local inventory = require("inventory")
local mineQuad = require("mineQuad")
local args = { ... }
local depth = tonumber(args[1]) or 300
local minedDepth = 0

inventory.refuel(10000)
nav.init()

print("Starting miner for depth: ", depth)

local function startMine20()
	local startMinedDepth = minedDepth
	for i = 1, 20 do
		mineQuad.run()

		minedDepth = minedDepth + 1
		print("mined quad.. current mined depth:", minedDepth)

		if inventory.isFull() then
			print("inventory full.. lets go home")
			return false
		end
		if minedDepth >= depth then
			return true
		end
		if minedDepth >= startMinedDepth + 20 then
			return false
		end
		turtle.digDown()
		nav.down(1)
	end
	return false
end

local miningStartPosition = nav.getPosition()
local miningStartFacing = nav.getFacing()

local reachedBottom = startMine20()
while reachedBottom == false do
	print("not at bottom yet. going for unload and coming back!")
	local tempPos = nav.getPosition()
	local tempFacing = nav.getFacing()

	nav.goTo(miningStartPosition.x, miningStartPosition.y, miningStartPosition.z)
	-- nav.turnTo(miningStartFacing)
	nav.goHome()
	inventory.refuel(10000)
	inventory.unload("front", true)

	nav.goTo(miningStartPosition.x, miningStartPosition.y, miningStartPosition.z)
	nav.goTo(tempPos.x, tempPos.y, tempPos.z)
	nav.turnTo(tempFacing)

	reachedBottom = startMine20()
end
print("reached bottom.. lets go home")

nav.goTo(miningStartPosition.x, miningStartPosition.y, miningStartPosition.z)
nav.goHome()
inventory.refuel(10000)
inventory.unload("front", false)
nav.goTo(miningStartPosition.x, miningStartPosition.y, miningStartPosition.z)
nav.turnTo(miningStartFacing)

print("program finished")
