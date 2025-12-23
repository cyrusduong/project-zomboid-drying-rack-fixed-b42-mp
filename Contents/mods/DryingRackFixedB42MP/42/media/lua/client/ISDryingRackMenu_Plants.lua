 -- Plant/Herb Drying Rack Context Menu Implementation
 -- Strictly matches item size to rack size (Plants can be "small" or "large")
 
require("DryingRackUtils")
require("DryingRackData_Plants")
require("TimedActions/ISDryItemAction")
 
ISDryingRackMenu_Plants = {}

 ---@param player IsoPlayer
 ---@return table
function ISDryingRackMenu_Plants.getDryablePlantItems(player)
 	local items = {}
 	local inventory = player:getInventory()
 	local allItems = inventory:getItems()
 	print("[ISDryingRackMenu_Plants] getDryablePlantItems - total items: " .. (allItems and allItems:size() or 0))
 	for i = 0, (allItems and allItems:size() or 1) - 1 do
 		local item = allItems:get(i)
 		if item then
			local fullType = item:getFullType()
			print("[ISDryingRackMenu_Plants] Checking item: " .. tostring(fullType))
			local mapping = DryingRackMapping_Plants[fullType]
			if mapping then
				print("[ISDryingRackMenu_Plants] Found mapping for " .. fullType .. " -> " .. mapping.output)
				table.insert(items, {
 					item = item,
 					outputType = mapping.output,
 					size = mapping.size,
 					inputType = fullType,
				})
			end
 		end
 	end
 	print("[ISDryingRackMenu_Plants] Returning " .. #items .. " dryable plant items")
 	return items
end

 ---@param player IsoPlayer
 ---@param plantData table
 ---@param rack IsoObject
function ISDryingRackMenu_Plants.dryPlant(player, plantData, rack)
 	print("[ISDryingRackMenu_Plants] dryPlant called for: " .. tostring(plantData.inputType))
 	if luautils.walkToAdjacentTile(player, rack:getSquare()) then
 		ISTimedActionQueue.add(ISDryItemAction:new(player, plantData.item, plantData.outputType, rack, 100))
 	end
 end

 ---@param player IsoPlayer
 ---@param compatiblePlants table
 ---@param rack IsoObject
function ISDryingRackMenu_Plants.dryAll(player, compatiblePlants, rack)
 	print("[ISDryingRackMenu_Plants] dryAll called for " .. #compatiblePlants .. " items")
 	for _, plantData in ipairs(compatiblePlants) do
 		if luautils.walkToAdjacentTile(player, rack:getSquare()) then
 			ISTimedActionQueue.add(ISDryItemAction:new(player, plantData.item, plantData.outputType, rack, 100))
 		end
 	end
 end

 ---@param player integer
 ---@param context ISContextMenu
 ---@param worldobjects IsoObject[]
 ---@param test boolean
function ISDryingRackMenu_Plants.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
 	print("[ISDryingRackMenu_Plants] ===== OnFillWorldObjectContextMenu START =====")
 	print("[ISDryingRackMenu_Plants] player: " .. tostring(player) .. ", test: " .. tostring(test))
 	print("[ISDryingRackMenu_Plants] worldobjects count: " .. (worldobjects and #worldobjects or 0))
 	print("[ISDryingRackMenu_Plants] context: " .. tostring(context))

 	if test and ISWorldObjectContextMenu.Test then
 		print("[ISDryingRackMenu_Plants] Returning early due to test mode")
 		return
 	end

 	local playerObj = getSpecificPlayer(player)
 	if not playerObj then
 		print("[ISDryingRackMenu_Plants] No player object, returning")
 		return
 	end

 	if playerObj:getVehicle() then
 		print("[ISDryingRackMenu_Plants] Player in vehicle, returning")
 		return
 	end

 	print("[ISDryingRackMenu_Plants] Scanning for plant drying racks...")

 	local dryingRacks = {}
 	local seenSizes = {}

 	if not worldobjects then
 		print("[ISDryingRackMenu_Plants] worldobjects is nil, returning")
 		return
 	end

 	for i = 2, #worldobjects do
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
 							print("[ISDryingRackMenu_Plants] Checking obj " .. tostring(obj) .. " - category: " .. tostring(category) .. ", size: " .. tostring(size))
 							if category == "plant" then
 								if not seenSizes[size] then
 									print("[ISDryingRackMenu_Plants] Found unique plant rack size: " .. tostring(size))
 									seenSizes[size] = true
 									table.insert(dryingRacks, obj)
 								else
 									print("[ISDryingRackMenu_Plants] Skipping duplicate rack size: " .. tostring(size))
 								end
 							end
 						end
 					end
 				end
 			end
 		end
 	end

 	print("[ISDryingRackMenu_Plants] Found " .. #dryingRacks .. " unique drying racks")

 	if #dryingRacks == 0 then
 		print("[ISDryingRackMenu_Plants] No drying racks found, returning")
 		return
 	end

 	local dryablePlants = ISDryingRackMenu_Plants.getDryablePlantItems(playerObj)
 	print("[ISDryingRackMenu_Plants] Player has " .. #dryablePlants .. " dryable plant items")

 	if #dryablePlants == 0 then
 		print("[ISDryingRackMenu_Plants] No dryable plants in inventory, returning")
 		return
 	end

 	for _, rack in ipairs(dryingRacks) do
 		local category, rackSize = DryingRackUtils.getRackInfo(rack)
 		print("[ISDryingRackMenu_Plants] Processing rack - size: " .. tostring(rackSize))

 		local compatiblePlants = {}
 		local incompatiblePlants = {}

 		for _, plant in ipairs(dryablePlants) do
 			print("[ISDryingRackMenu_Plants]   Checking plant " .. tostring(plant.inputType) .. " size: " .. tostring(plant.size) .. " vs rack size: " .. tostring(rackSize))
 			if plant.size == rackSize then
 				table.insert(compatiblePlants, plant)
 				print("[ISDryingRackMenu_Plants]   -> Compatible!")
 			else
 				table.insert(incompatiblePlants, plant)
 				print("[ISDryingRackMenu_Plants]   -> Not compatible (wrong size)")
 			end
 		end

 		print("[ISDryingRackMenu_Plants] Compatible items for this rack: " .. #compatiblePlants)
 		print("[ISDryingRackMenu_Plants] Incompatible items for this rack: " .. #incompatiblePlants)

 		if #compatiblePlants > 0 or #incompatiblePlants > 0 then
 			local rackName = DryingRackUtils.getDisplayName(category, rackSize)
 			print("[ISDryingRackMenu_Plants] Creating submenu for: " .. rackName)

 			local rackOption = context:addOptionOnTop("Dry Herbs", worldobjects, nil)
 			print("[ISDryingRackMenu_Plants] rackOption created: " .. tostring(rackOption))

 			local subMenu = ISContextMenu:getNew(context)
 			context:addSubMenu(rackOption, subMenu)
 			print("[ISDryingRackMenu_Plants] subMenu created and attached")

 			if #compatiblePlants > 1 then
 				print("[ISDryingRackMenu_Plants] Adding Dry All option for " .. #compatiblePlants .. " items")
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
 				print("[ISDryingRackMenu_Plants] Adding individual option: " .. label)
 				subMenu:addOption(label, rack, ISDryingRackMenu_Plants.dryPlant, playerObj, plant, rack)
 			end

 			for _, plant in ipairs(incompatiblePlants) do
 				local label = plant.item:getName()
 				print("[ISDryingRackMenu_Plants] Adding disabled option: " .. label .. " (Rack too small)")
 				local option = subMenu:addOption(label .. " (Rack too small)", rack, nil)
 				option.notAvailable = true
 				option.toolTip = ISWorldObjectContextMenu.addToolTip()
 				option.toolTip:setName("Rack Too Small")
 				option.toolTip.description = "This plant requires a " .. plant.size .. " drying rack, but this is a " .. rackSize .. " rack."
 			end
 		end
 	end

 	print("[ISDryingRackMenu_Plants] ===== OnFillWorldObjectContextMenu END =====")
end

if Events and Events.OnFillWorldObjectContextMenu then
 	Events.OnFillWorldObjectContextMenu.Add(ISDryingRackMenu_Plants.OnFillWorldObjectContextMenu)
 	print("[ISDryingRackMenu_Plants] Event handler registered")
else
 	print("[ISDryingRackMenu_Plants] WARNING: Events.OnFillWorldObjectContextMenu not available!")
end
