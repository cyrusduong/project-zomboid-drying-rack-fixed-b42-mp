-- Leather Drying Rack Context Menu Implementation
-- Strictly matches item size to rack size (No cascading)

require("DryingRackUtils")
require("DryingRackData_Leather")
require("TimedActions/ISDryItemAction")

ISDryingRackMenu_Leather = {}

---@param player IsoPlayer
---@return table
function ISDryingRackMenu_Leather.getWetLeatherItems(player)
	local items = {}
	local inventory = player:getInventory()
	local allItems = inventory:getItems()
	print("[ISDryingRackMenu_Leather] getWetLeatherItems - total items: " .. (allItems and allItems:size() or 0))
	for i = 0, (allItems and allItems:size() or 1) - 1 do
		local item = allItems:get(i)
		if item then
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
	end
	print("[ISDryingRackMenu_Leather] Returning " .. #items .. " wet leather items")
	return items
end

---@param player IsoPlayer
---@param wetLeatherData table
---@param rack IsoObject
function ISDryingRackMenu_Leather.dryLeather(player, wetLeatherData, rack)
	print("[ISDryingRackMenu_Leather] dryLeather called for: " .. tostring(wetLeatherData.inputType))
	if luautils.walkToAdjacentTile(player, rack:getSquare()) then
		ISTimedActionQueue.add(ISDryItemAction:new(player, wetLeatherData.item, wetLeatherData.outputType, rack, 100))
	end
end

---@param player IsoPlayer
---@param compatibleLeathers table
---@param rack IsoObject
function ISDryingRackMenu_Leather.dryAll(player, compatibleLeathers, rack)
	print("[ISDryingRackMenu_Leather] dryAll called for " .. #compatibleLeathers .. " items")
	for _, leatherData in ipairs(compatibleLeathers) do
		if luautils.walkToAdjacentTile(player, rack:getSquare()) then
			ISTimedActionQueue.add(ISDryItemAction:new(player, leatherData.item, leatherData.outputType, rack, 100))
		end
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

			local rackOption = context:addOptionOnTop("Dry Leather", worldobjects, nil)
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
				subMenu:addOption(label, rack, ISDryingRackMenu_Leather.dryLeather, playerObj, leather, rack)
			end

			for _, leather in ipairs(incompatibleLeathers) do
				local label = leather.item:getName()
				local rackTooSmall = leather.size < rackSize
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

if Events and Events.OnFillWorldObjectContextMenu then
	Events.OnFillWorldObjectContextMenu.Add(ISDryingRackMenu_Leather.OnFillWorldObjectContextMenu)
	print("[ISDryingRackMenu_Leather] Event handler registered")
else
	print("[ISDryingRackMenu_Leather] WARNING: Events.OnFillWorldObjectContextMenu not available!")
end
