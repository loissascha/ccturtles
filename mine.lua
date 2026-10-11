local nav = require("navigation")
local inventory = require("inventory")
local args = { ... }
local depth = tonumber(args[1]) or 300
local minedDepth = 0

nav.init()

print("Starting miner...")

local function startMine20()
	local startMinedDepth = minedDepth
	for i = 1, 20 do
		shell.run("mineQuad.lua")

		minedDepth = minedDepth + 1

		if minedDepth >= depth then
			return true
		end
		if minedDepth > startMinedDepth + 20 then
			return false
		end
		turtle.digDown()
		nav.down(1)
	end
end

local miningStartPosition = nav.getPosition()
local miningStartFacing = nav.getFacing()

inventory.refuel(1000)
local reachedBottom = startMine20()
while reachedBottom == false do
	local tempPos = nav.getPosition()
	local tempFacing = nav.getFacing()

	nav.goTo(miningStartPosition.x, miningStartPosition.y, miningStartPosition.z)
	-- nav.turnTo(miningStartFacing)
	nav.goHome()
	inventory.refuel(1000)
	inventory.unload("front", false)
	sleep(3)

	nav.goTo(miningStartPosition.x, miningStartPosition.y, miningStartPosition.z)
	nav.goTo(tempPos.x, tempPos.y, tempPos.z)
	nav.turnTo(tempFacing)

	reachedBottom = startMine20()
end

nav.goTo(miningStartPosition.x, miningStartPosition.y, miningStartPosition.z)
nav.goHome()
inventory.refuel(1000)
inventory.unload("front", false)
sleep(3)
nav.goTo(miningStartPosition.x, miningStartPosition.y, miningStartPosition.z)
nav.turnTo(miningStartFacing)
