local nav = {}

local HOME_FILE = "/nav_home.json"

local directions = {
	"north", "east", "south", "west"
}

local facing = nil
local home = nil

-- INTERNAL HELPERS -----------------------

local function locate()
	local x, y, z = gps.locate(3)

	assert(x, "GPS unavailable")

	return { x = x, y = y, z = z }
end

local function saveHome()
	local file = assert(fs.open(HOME_FILE, "w"))

	file.write(textutils.serializeJSON(home))
	file.close()
end

local function loadHome()
	if not fs.exists(HOME_FILE) then
		return nil
	end

	local file = assert(fs.open(HOME_FILE, "r"))
	local data = file.readAll()
	file.close()

	local result = textutils.unserializeJSON(data)
	assert(
		type(result) == "table"
		and type(result.x) == "number"
		and type(result.y) == "number"
		and type(result.z) == "number"
		and type(result.facing) == "string",
		"Invalid saved home"
	)

	return result
end

local function directionFromPositions(a, b)
	local dx = b.x - a.x
	local dz = b.z - a.z

	if dx == 1 and dz == 0 then
		return "east"
	elseif dx == -1 and dz == 0 then
		return "west"
	elseif dz == 1 and dx == 0 then
		return "south"
	elseif dz == -1 and dx == 0 then
		return "north"
	end

	error("Unexpected GPS movement")
end

local function opposite(direction)
	local opposites = {
		north = "south",
		south = "north",
		east = "west",
		west = "east"
	}

	return opposites[direction]
end

-- GPS DIRECTION DETECTION ----------------

function nav.detectFacing()
	local before = locate()

	-- First attempt: move forward and back
	if turtle.forward() then
		local after = locate()

		assert(
			turtle.back(),
			"Failed to return after GPS probe"
		)

		facing = directionFromPositions(before, after)
		return facing
	end

	-- Fallback: move backward and forward
	if turtle.back() then
		local after = locate()

		assert(
			turtle.forward(),
			"Failed to return after GPS probe"
		)

		local backwards = directionFromPositions(
			before, after
		)

		facing = opposite(backwards)
		return facing
	end

	error("Cannot detect facing: forward/back blocked")
end

-- INITIALIZATION -------------------------

function nav.init()
	print("Initializing navigation...")

	local position = locate()
	facing = nav.detectFacing()

	home = loadHome()

	if not home then
		home = {
			x = position.x,
			y = position.y,
			z = position.z,
			facing = facing
		}

		saveHome()
		print("New home location saved!")
	else
		print("Existing home location loaded.")
	end

	print("Facing:", facing)

	return true
end

-- PUBLIC STATE ---------------------------

local function ensureReady()
	assert(facing, "Call nav.init() first")
end

function nav.getPosition()
	ensureReady()
	return locate()
end

function nav.getFacing()
	ensureReady()
	return facing
end

function nav.getHome()
	ensureReady()

	return {
		x = home.x,
		y = home.y,
		z = home.z,
		facing = home.facing
	}
end

function nav.setHome()
	ensureReady()

	local position = locate()

	home = {
		x = position.x,
		y = position.y,
		z = position.z,
		facing = facing
	}

	saveHome()
	print("Home updated!")
end

-- MOVEMENT -------------------------------

local function move(action, steps)
	ensureReady()

	steps = steps or 1
	assert(
		type(steps) == "number"
		and steps >= 0
		and steps % 1 == 0,
		"Steps must be a non-negative integer"
	)

	for i = 1, steps do
		local ok, err = action()

		if not ok then
			error(
				"Movement failed: " ..
				tostring(err)
			)
		end
	end
end

function nav.forward(steps)
	print("forward", steps)
	move(turtle.forward, steps)
end

function nav.back(steps)
	print("back", steps)
	move(turtle.back, steps)
end

function nav.up(steps)
	print("up", steps)
	move(turtle.up, steps)
end

function nav.down(steps)
	print("down", steps)
	move(turtle.down, steps)
end

-- ROTATION -------------------------------

local function facingIndex(direction)
	for i, value in ipairs(directions) do
		if value == direction then
			return i
		end
	end

	error("Invalid direction: " .. tostring(direction))
end

function nav.turnRight()
	ensureReady()
	print("turnRight")
	assert(turtle.turnRight())

	local index = facingIndex(facing)
	facing = directions[(index % 4) + 1]
end

function nav.turnLeft()
	ensureReady()
	print("turnLeft")
	assert(turtle.turnLeft())

	local index = facingIndex(facing)
	facing = directions[((index + 2) % 4) + 1]
end

function nav.turnTo(direction)
	ensureReady()

	local current = facingIndex(facing)
	local target = facingIndex(direction)

	local diff = (target - current) % 4

	if diff == 1 then
		nav.turnRight()
	elseif diff == 2 then
		nav.turnRight()
		nav.turnRight()
	elseif diff == 3 then
		nav.turnLeft()
	end
end

-- NAVIGATION -----------------------------

function nav.goTo(x, y, z)
	ensureReady()

	assert(
		type(x) == "number"
		and type(y) == "number"
		and type(z) == "number",
		"goTo requires numeric x, y, z"
	)

	local current = locate()

	-- Y axis
	local dy = y - current.y

	if dy > 0 then
		nav.up(dy)
	elseif dy < 0 then
		nav.down(math.abs(dy))
	end

	-- X axis
	local dx = x - current.x

	if dx ~= 0 then
		nav.turnTo(dx > 0 and "east" or "west")
		nav.forward(math.abs(dx))
	end

	-- Z axis
	local dz = z - current.z

	if dz ~= 0 then
		nav.turnTo(dz > 0 and "south" or "north")
		nav.forward(math.abs(dz))
	end


	local final = locate()

	assert(
		final.x == x
		and final.y == y
		and final.z == z,
		"Destination verification failed"
	)

	return final
end

function nav.goHome()
	ensureReady()

	nav.goTo(home.x, home.y, home.z)
	nav.turnTo(home.facing)

	print("Arrived home!")
end

return nav
