-- Plant/Herb Drying Rack Context Menu Implementation
-- Strictly matches item size to rack size (Plants can be "small" or "large")

require("DryingRackUtils")
require("DryingRackData_Plants")
require("TimedActions/ISDryItemAction")

ISDryingRackMenu_Plants = {}

---@param player IsoPlayer
---@return table<string, InventoryItem>
function ISDryingRackMenu_Plants.getAllAccessibleItems(player)
	local allItems = {}

	local function processItemList(itemList)
		for i = 0, (itemList and itemList:size() or 1) - 1 do
			local item = itemList:get(i)
			if item then
				allItems[item] = true
			end
		end
	end

	processItemList(player:getInventory():getItems())

	local primaryHand = player:getPrimaryHandItem()
	if primaryHand then
		allItems[primaryHand] = true
		local container = nil
		if primaryHand.getItemContainer then
			container = primaryHand:getItemContainer()
		end
		if not container and primaryHand.getInventory then
			container = primaryHand:getInventory()
		end
		if container then
			processItemList(container:getItems())
		else
		end
	end

	local secondaryHand = player:getSecondaryHandItem()
	if secondaryHand then
		allItems[secondaryHand] = true
		local container = nil
		if secondaryHand.getItemContainer then
			container = secondaryHand:getItemContainer()
		end
		if not container and secondaryHand.getInventory then
			container = secondaryHand:getInventory()
		end
		if container then
			processItemList(container:getItems())
		else
		end
	end

	local wornItems = player:getWornItems()
	if wornItems then
		for i = 0, wornItems:size() - 1 do
			local wornItem = wornItems:get(i)
			if wornItem then
				local item = wornItem:getItem()
				if item then
					local fullType = item:getFullType()
					allItems[item] = true
					local container = nil
					if item.getItemContainer then
						container = item:getItemContainer()
					end
					if not container and item.getInventory then
						container = item:getInventory()
					end
					if container then
						local containerItems = container:getItems()
						processItemList(containerItems)
						for j = 0, containerItems:size() - 1 do
							local contItem = containerItems:get(j)
							if contItem then
							end
						end
					else
					end
				end
			end
		end
	end

	return allItems
end

---@param player IsoPlayer
---@return table
function ISDryingRackMenu_Plants.getDryablePlantItems(player)
	local items = {}
	local allAccessibleItems = ISDryingRackMenu_Plants.getAllAccessibleItems(player)
	local count = 0
	for _ in pairs(allAccessibleItems) do count = count + 1 end
	for item, _ in pairs(allAccessibleItems) do
		local fullType = item:getFullType()
		local mappings = DryingRackMapping_Plants[fullType]
		if mappings then
			for _, mapping in ipairs(mappings) do
				table.insert(items, {
					item = item,
					outputType = mapping.output,
					size = mapping.size,
					inputType = fullType,
				})
			end
		end
	end
	return items
end

---@param player IsoPlayer
---@param plantData table
---@param rack IsoObject
function ISDryingRackMenu_Plants.dryPlant(player, plantData, rack)
	if luautils.walkAdj(player, rack:getSquare()) then
		ISTimedActionQueue.add(ISDryItemAction:new(player, plantData.item, plantData.outputType, rack, 100))
	end
end

---@param player IsoPlayer
---@param compatiblePlants table
---@param rack IsoObject
function ISDryingRackMenu_Plants.dryAll(player, compatiblePlants, rack)
	if not luautils.walkAdj(player, rack:getSquare(), true) then return end
	for _, plantData in ipairs(compatiblePlants) do
		ISTimedActionQueue.add(ISDryItemAction:new(player, plantData.item, plantData.outputType, rack, 100))
	end
end

---@param player integer
---@param context ISContextMenu
---@param worldobjects IsoObject[]
---@param test boolean
function ISDryingRackMenu_Plants.OnFillWorldObjectContextMenu(player, context, worldobjects, test)

	if test and ISWorldObjectContextMenu.Test then
		return
	end

	local playerObj = getSpecificPlayer(player)
	if not playerObj then
		return
	end

	if playerObj:getVehicle() then
		return
	end


	local dryingRacks = {}
	local seenSizes = {}

	if not worldobjects then
		return
	end

	-- Find drying rack objects
	for i = 1, #worldobjects do
		local rootObj = worldobjects[i]
		if rootObj and rootObj.getSquare then
			local square = rootObj:getSquare()
			if square then
				local sqObjs = square:getObjects()
				if sqObjs then
					for j = 0, sqObjs:size() - 1 do
						local obj = sqObjs:get(j)
						if obj then
							local category, size = DryingRackUtils.getRackInfo(obj)
							if category == "plant" then
								if not seenSizes[size] then
									seenSizes[size] = true
									table.insert(dryingRacks, obj)
								else
								end
							end
						end
					end
				end
			end
		end
	end


	if #dryingRacks == 0 then
		return
	end

	local dryablePlants = ISDryingRackMenu_Plants.getDryablePlantItems(playerObj)

	if #dryablePlants == 0 then
		return
	end

	for _, rack in ipairs(dryingRacks) do
		local category, rackSize = DryingRackUtils.getRackInfo(rack)

		local compatiblePlants = {}
		local incompatiblePlants = {}
		local seenInputsForThisRack = {}

		for _, plant in ipairs(dryablePlants) do
			if plant.size == rackSize then
				table.insert(compatiblePlants, plant)
				seenInputsForThisRack[plant.item] = true
			end
		end

		-- Second pass for incompatible items
		for _, plant in ipairs(dryablePlants) do
			if not seenInputsForThisRack[plant.item] then
				local alreadyInIncompatible = false
				for _, p in ipairs(incompatiblePlants) do
					if p.item == plant.item then alreadyInIncompatible = true; break end
				end

				if not alreadyInIncompatible then
					table.insert(incompatiblePlants, plant)
				end
			end
		end


		if #compatiblePlants > 0 or #incompatiblePlants > 0 then
			local rackOption = context:addOptionOnTop("Dry Herbs on " .. rackSize:gsub("^%l", string.upper) .. " Rack", worldobjects, nil)
			local subMenu = ISContextMenu:getNew(context)
			context:addSubMenu(rackOption, subMenu)

			if #compatiblePlants > 1 then
				subMenu:addOption(
					"Dry All (" .. #compatiblePlants .. ")",
					playerObj,
					ISDryingRackMenu_Plants.dryAll,
					compatiblePlants,
					rack
				)
			end

			for _, plant in ipairs(compatiblePlants) do
				local label = plant.item:getName()
				subMenu:addOption(label, playerObj, ISDryingRackMenu_Plants.dryPlant, plant, rack)
			end

			for _, plant in ipairs(incompatiblePlants) do
				local label = plant.item:getName()
				local weights = { small = 1, large = 3 }
				local plantWeight = weights[plant.size] or 0
				local rackWeight = weights[rackSize] or 0
				local rackTooSmall = plantWeight > rackWeight
				local statusText = rackTooSmall and " (Rack too small)" or " (Rack too large)"
				local toolTipName = rackTooSmall and "Rack Too Small" or "Rack Too Large"
				local option = subMenu:addOption(label .. statusText, rack, nil)
				option.notAvailable = true
				option.toolTip = ISWorldObjectContextMenu.addToolTip()
				option.toolTip:setName(toolTipName)
				option.toolTip.description = "This plant requires a "
					.. plant.size
					.. " drying rack, but this is a "
					.. rackSize
					.. " rack."
			end
		end
	end

end

Events.OnFillWorldObjectContextMenu.Add(ISDryingRackMenu_Plants.OnFillWorldObjectContextMenu)
