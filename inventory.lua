local inventory = {}

function inventory.isFull()
	for slot = 1, 16 do
		if turtle.getItemCount(slot) == 0 then
			return false
		end
	end

	return true
end

function inventory.refuel(targetFuel)
	targetFuel = targetFuel or 1000

	-- Fuel consumption might be disabled
	if turtle.getFuelLevel() == "unlimited" then
		return true
	end

	if turtle.getFuelLevel() >= targetFuel then
		return true
	end

	local previousSlot = turtle.getSelectedSlot()

	for slot = 1, 16 do
		turtle.select(slot)

		-- Check if selected item is valid fuel
		if turtle.refuel(0) then
			while turtle.getItemCount(slot) > 0
				and turtle.getFuelLevel() < targetFuel do
				if not turtle.refuel(1) then
					break
				end
			end
		end

		if turtle.getFuelLevel() >= targetFuel then
			break
		end
	end

	turtle.select(previousSlot)

	return turtle.getFuelLevel() >= targetFuel
end

function inventory.unload(direction, keepFuel)
	direction = direction or "front"

	local dropFunctions = {
		front = turtle.drop,
		up = turtle.dropUp,
		down = turtle.dropDown
	}

	local drop = dropFunctions[direction]
	assert(drop, "Invalid direction: " .. direction)

	local previousSlot = turtle.getSelectedSlot()
	local unloaded = 0

	for slot = 1, 16 do
		local item = turtle.getItemDetail(slot)

		if item then
			local isFuel =
				item.name == "minecraft:coal"
				or item.name == "minecraft:charcoal"

			if not (keepFuel and isFuel) then
				turtle.select(slot)

				local count = turtle.getItemCount(slot)

				if not drop() then
					error("Could not unload slot " .. slot ..
						". Is the chest full?")
				end

				unloaded = unloaded + count
			end
		end
	end

	turtle.select(previousSlot)

	print("Unloaded " .. unloaded .. " items")
	return unloaded
end

return inventory
