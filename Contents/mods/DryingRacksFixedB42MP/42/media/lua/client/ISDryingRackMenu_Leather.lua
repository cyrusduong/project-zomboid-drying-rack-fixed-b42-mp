-- Leather Drying Rack Context Menu Implementation
-- Strictly matches item size to rack size (No cascading)

require('utl')
require("DryingRackUtils")
require("DryingRackData_Leather")
require("TimedActions/ISDryItemAction")

ISDryingRackMenu_Leather = {}

---@param player IsoPlayer
---@return table<string, InventoryItem>
function ISDryingRackMenu_Leather.getAllAccessibleItems(player)
	local allItems = {}

	local function processItemList(itemList)
		for i = 0, (itemList and itemList:size() or 1) - 1 do
			local item = itemList:get(i)
			if item then
				allItems[item] = true
			end
		end
	end

	print("[ISDryingRackMenu_Leather.getAllAccessibleItems] Scanning main inventory...")
	processItemList(player:getInventory():getItems())

	print("[ISDryingRackMenu_Leather.getAllAccessibleItems] Scanning primary hand...")
	local primaryHand = player:getPrimaryHandItem()
	if primaryHand then
		print("[ISDryingRackMenu_Leather.getAllAccessibleItems]   Primary hand: " .. tostring(primaryHand:getFullType()))
		allItems[primaryHand] = true
		local container = nil
		if primaryHand.getItemContainer then
			container = primaryHand:getItemContainer()
		end
		if not container and primaryHand.getInventory then
			container = primaryHand:getInventory()
		end
		if container then
			print("[ISDryingRackMenu_Leather.getAllAccessibleItems]   Primary hand has container, scanning...")
			processItemList(container:getItems())
		else
			print("[ISDryingRackMenu_Leather.getAllAccessibleItems]   Primary hand has NO container")
		end
	end

	print("[ISDryingRackMenu_Leather.getAllAccessibleItems] Scanning secondary hand...")
	local secondaryHand = player:getSecondaryHandItem()
	if secondaryHand then
		print("[ISDryingRackMenu_Leather.getAllAccessibleItems]   Secondary hand: " .. tostring(secondaryHand:getFullType()))
		allItems[secondaryHand] = true
		local container = nil
		if secondaryHand.getItemContainer then
			container = secondaryHand:getItemContainer()
		end
		if not container and secondaryHand.getInventory then
			container = secondaryHand:getInventory()
		end
		if container then
			print("[ISDryingRackMenu_Leather.getAllAccessibleItems]   Secondary hand has container, scanning...")
			processItemList(container:getItems())
		else
			print("[ISDryingRackMenu_Leather.getAllAccessibleItems]   Secondary hand has NO container")
		end
	end

	print("[ISDryingRackMenu_Leather.getAllAccessibleItems] Scanning worn items...")
	local wornItems = player:getWornItems()
	if wornItems then
		print("[ISDryingRackMenu_Leather.getAllAccessibleItems]   Worn items size: " .. tostring(wornItems:size()))
		for i = 0, wornItems:size() - 1 do
			local wornItem = wornItems:get(i)
			if wornItem then
				local item = wornItem:getItem()
				if item then
					local fullType = item:getFullType()
					allItems[item] = true
					print("[ISDryingRackMenu_Leather.getAllAccessibleItems]   Worn item: " .. tostring(fullType))
					local container = nil
					if item.getItemContainer then
						container = item:getItemContainer()
					end
					if not container and item.getInventory then
						container = item:getInventory()
					end
					if container then
						local containerItems = container:getItems()
						print("[ISDryingRackMenu_Leather.getAllAccessibleItems]     Has container with " .. tostring(containerItems:size()) .. " items")
						processItemList(containerItems)
						for j = 0, containerItems:size() - 1 do
							local contItem = containerItems:get(j)
							if contItem then
								print("[ISDryingRackMenu_Leather.getAllAccessibleItems]       Container item: " .. tostring(contItem:getFullType()))
							end
						end
					else
						print("[ISDryingRackMenu_Leather.getAllAccessibleItems]     NO container")
					end
				end
			end
		end
	end

	return allItems
end

---@param player IsoPlayer
---@return table
function ISDryingRackMenu_Leather.getWetLeatherItems(player)
	local items = {}
	local allAccessibleItems = ISDryingRackMenu_Leather.getAllAccessibleItems(player)
	local count = 0
	for _ in pairs(allAccessibleItems) do count = count + 1 end
	print("[ISDryingRackMenu_Leather] getWetLeatherItems - total accessible items: " .. count)
	for item, _ in pairs(allAccessibleItems) do
		local fullType = item:getFullType()
		print("[ISDryingRackMenu_Leather] Checking item: " .. tostring(fullType))
		local mapping = DryingRackMapping_Leather[fullType]
		if mapping then
			print("[ISDryingRackMenu_Leather] Found mapping for " .. fullType .. " -> " .. mapping.output)
			table.insert(items, {
				item = item,
				outputType = mapping.output,
				size = mapping.size,
				inputType = fullType,
			})
		end
	end
	print("[ISDryingRackMenu_Leather] Returning " .. #items .. " wet leather items")
	return items
end

---@param player IsoPlayer
---@param wetLeatherData table
---@param rack IsoObject
function ISDryingRackMenu_Leather.dryLeather(player, wetLeatherData, rack)
	print("[ISDryingRackMenu_Leather] dryLeather called for: " .. tostring(wetLeatherData.inputType))
	if luautils.walkAdj(player, rack:getSquare()) then
		ISTimedActionQueue.add(ISDryItemAction:new(player, wetLeatherData.item, wetLeatherData.outputType, rack, 100))
	end
end

---@param player IsoPlayer
---@param compatibleLeathers table
---@param rack IsoObject
function ISDryingRackMenu_Leather.dryAll(player, compatibleLeathers, rack)
	print("[ISDryingRackMenu_Leather] dryAll called for " .. #compatibleLeathers .. " items")
	if not luautils.walkAdj(player, rack:getSquare(), true) then return end
	for _, leatherData in ipairs(compatibleLeathers) do
		ISTimedActionQueue.add(ISDryItemAction:new(player, leatherData.item, leatherData.outputType, rack, 100))
	end
end

---@param player integer
---@param context ISContextMenu
---@param worldobjects IsoObject[]
---@param test boolean
function ISDryingRackMenu_Leather.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
	print("[ISDryingRackMenu_Leather] ===== OnFillWorldObjectContextMenu START =====")
	print("[ISDryingRackMenu_Leather] player: " .. tostring(player) .. ", test: " .. tostring(test))
	print("[ISDryingRackMenu_Leather] worldobjects count: " .. (worldobjects and #worldobjects or 0))
	print("[ISDryingRackMenu_Leather] context: " .. tostring(context))

	if test and ISWorldObjectContextMenu.Test then
		print("[ISDryingRackMenu_Leather] Returning early due to test mode")
		return
	end

	local playerObj = getSpecificPlayer(player)
	if not playerObj then
		print("[ISDryingRackMenu_Leather] No player object, returning")
		return
	end

	if playerObj:getVehicle() then
		print("[ISDryingRackMenu_Leather] Player in vehicle, returning")
		return
	end

	print("[ISDryingRackMenu_Leather] Scanning for leather drying racks...")

	local dryingRacks = {}
	local seenSizes = {}

	if not worldobjects then
		print("[ISDryingRackMenu_Leather] worldobjects is nil, returning")
		return
	end

	-- Find drying rack objects
	-- We start at i = 1 (the Floor) to ensure the menu works even if clicking empty space inside the rack.
	-- Sometimes cursor is in a weird spot, IE. inbetween two drying racks, we can get both
	-- with the getSquare -> getObjects then loop thru objects. However this may cause duplicate values.
	--
	-- INVARIANT: We know we can only have 1 rack per coordinate, so if we already put an object
	-- in the drying rack table for a certain coordinate then we don't need to put it again.
	-- INVARIANT: If we have multiple of the same size drying rack next to each other, it doesn't
	-- make sense to list all of them, simply list the first one in the loop.
	-- IE. At maximum there can be 3 options for each rack size, otherwise maximum of 1 per rack size displayed
	-- in the context menu
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
							print(
								"[ISDryingRackMenu_Leather] Checking obj "
									.. tostring(obj)
									.. " - category: "
									.. tostring(category)
									.. ", size: "
									.. tostring(size)
							)
							if category == "leather" then
								if not seenSizes[size] then
									print(
										"[ISDryingRackMenu_Leather] Found unique leather rack size: " .. tostring(size)
									)
									seenSizes[size] = true
									table.insert(dryingRacks, obj)
								else
									print("[ISDryingRackMenu_Leather] Skipping duplicate rack size: " .. tostring(size))
								end
							end
						end
					end
				end
			end
		end
	end

	print("[ISDryingRackMenu_Leather] Found " .. #dryingRacks .. " unique drying racks")

	if #dryingRacks == 0 then
		print("[ISDryingRackMenu_Leather] No drying racks found, returning")
		return
	end

	local wetLeathers = ISDryingRackMenu_Leather.getWetLeatherItems(playerObj)
	print("[ISDryingRackMenu_Leather] Player has " .. #wetLeathers .. " wet leather items")

	if #wetLeathers == 0 then
		print("[ISDryingRackMenu_Leather] No wet leather in inventory, returning")
		return
	end

	for _, rack in ipairs(dryingRacks) do
		local category, rackSize = DryingRackUtils.getRackInfo(rack)
		print("[ISDryingRackMenu_Leather] Processing rack - size: " .. tostring(rackSize))

		local compatibleLeathers = {}
		local incompatibleLeathers = {}

		for _, leather in ipairs(wetLeathers) do
			print(
				"[ISDryingRackMenu_Leather]   Checking leather "
					.. tostring(leather.inputType)
					.. " size: "
					.. tostring(leather.size)
					.. " vs rack size: "
					.. tostring(rackSize)
			)
			if leather.size == rackSize then
				table.insert(compatibleLeathers, leather)
				print("[ISDryingRackMenu_Leather]   -> Compatible!")
			else
				table.insert(incompatibleLeathers, leather)
				print("[ISDryingRackMenu_Leather]   -> Not compatible (wrong size)")
			end
		end

		print("[ISDryingRackMenu_Leather] Compatible items for this rack: " .. #compatibleLeathers)
		print("[ISDryingRackMenu_Leather] Incompatible items for this rack: " .. #incompatibleLeathers)

		if #compatibleLeathers > 0 or #incompatibleLeathers > 0 then
			local rackName = DryingRackUtils.getDisplayName(category, rackSize)
			print("[ISDryingRackMenu_Leather] Creating submenu for: " .. rackName)

			local rackOption = context:addOptionOnTop("Dry Leather on " .. rackSize:gsub("^%l", string.upper) .. " Rack", worldobjects, nil)
			print("[ISDryingRackMenu_Leather] rackOption created: " .. tostring(rackOption))

			local subMenu = ISContextMenu:getNew(context)
			context:addSubMenu(rackOption, subMenu)
			print("[ISDryingRackMenu_Leather] subMenu created and attached")

			if #compatibleLeathers > 1 then
				print("[ISDryingRackMenu_Leather] Adding Dry All option for " .. #compatibleLeathers .. " items")
				subMenu:addOption(
					"Dry All (" .. #compatibleLeathers .. ")",
					playerObj,
					ISDryingRackMenu_Leather.dryAll,
					compatibleLeathers,
					rack
				)
			end

			for _, leather in ipairs(compatibleLeathers) do
				local label = leather.item:getName()
				print("[ISDryingRackMenu_Leather] Adding individual option: " .. label)
				subMenu:addOption(label, playerObj, ISDryingRackMenu_Leather.dryLeather, leather, rack)
			end

			for _, leather in ipairs(incompatibleLeathers) do
				local label = leather.item:getName()
				local weights = { small = 1, medium = 2, large = 3 }
				local leatherWeight = weights[leather.size] or 0
				local rackWeight = weights[rackSize] or 0
				local rackTooSmall = leatherWeight > rackWeight
				local statusText = rackTooSmall and " (Rack too small)" or " (Rack too large)"
				local toolTipName = rackTooSmall and "Rack Too Small" or "Rack Too Large"
				print("[ISDryingRackMenu_Leather] Adding disabled option: " .. label .. statusText)
				local option = subMenu:addOption(label .. statusText, rack, nil)
				option.notAvailable = true
				option.toolTip = ISWorldObjectContextMenu.addToolTip()
				option.toolTip:setName(toolTipName)
				option.toolTip.description = "This leather requires a "
					.. leather.size
					.. " drying rack, but this is a "
					.. rackSize
					.. " rack."
			end
		end
	end

	print("[ISDryingRackMenu_Leather] ===== OnFillWorldObjectContextMenu END =====")
end

Events.OnFillWorldObjectContextMenu.Add(ISDryingRackMenu_Leather.OnFillWorldObjectContextMenu)
print("[ISDryingRackMenu_Leather] Event handler registered")
