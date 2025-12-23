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
	for i = 0, allItems:size() - 1 do
		local item = allItems:get(i)
		local fullType = item:getFullType()
		local mapping = DryingRackMapping_Leather[fullType]
		if mapping then
			table.insert(items, {
				item = item,
				outputType = mapping.output,
				size = mapping.size,
				inputType = fullType,
			})
		end
	end
	return items
end

---@param player IsoPlayer
---@param wetLeatherData table
---@param rack IsoObject
function ISDryingRackMenu_Leather.dryLeather(player, wetLeatherData, rack)
	if luautils.walkToAdjacentTile(player, rack:getSquare()) then
		ISTimedActionQueue.add(ISDryItemAction:new(player, wetLeatherData.item, wetLeatherData.outputType, rack, 100))
	end
end

---@param player IsoPlayer
---@param compatibleLeathers table
---@param rack IsoObject
function ISDryingRackMenu_Leather.dryAll(player, compatibleLeathers, rack)
	for _, leatherData in ipairs(compatibleLeathers) do
		if luautils.walkToAdjacentTile(player, rack:getSquare()) then
			ISTimedActionQueue.add(ISDryItemAction:new(player, leatherData.item, leatherData.outputType, rack, 100))
		end
	end
end

---@param player integer
---@param context ISContextMenu
---@param worldobjects IsoObject[]
function ISDryingRackMenu_Leather.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
	if test and ISWorldObjectContextMenu.Test then
		return
	end
	local playerObj = getSpecificPlayer(player)

	local rack = nil
	local rackCategory = nil
	local rackSize = nil

	for _, obj in ipairs(worldobjects) do
		local category, size = DryingRackUtils.getRackInfo(obj)
		if category == "leather" then
			rack = obj
			rackCategory = category
			rackSize = size
			break
		end
	end

	if not rack then
		return
	end

	local wetLeathers = ISDryingRackMenu_Leather.getWetLeatherItems(playerObj)
	if #wetLeathers == 0 then
		return
	end

	-- Filter leathers for STRICT compatibility (size must match exactly)
	local compatibleLeathers = {}
	for _, leather in ipairs(wetLeathers) do
		if leather.size == rackSize then
			table.insert(compatibleLeathers, leather)
		end
	end

	if #compatibleLeathers > 0 then
		local rackName = DryingRackUtils.getDisplayName(rackCategory, rackSize)
		local option = context:addOption("Dry Leather on " .. rackName, playerObj, nil)
		local subMenu = context:getNew(context)
		context:setSubMenu(option, subMenu)

		-- "Dry All" option
		if #compatibleLeathers > 1 then
			subMenu:addOption(
				"Dry All (" .. #compatibleLeathers .. ")",
				playerObj,
				ISDryingRackMenu_Leather.dryAll,
				compatibleLeathers,
				rack
			)
		end

		-- Individual options
		for _, leather in ipairs(compatibleLeathers) do
			local label = leather.item:getName()
			subMenu:addOption(label, playerObj, ISDryingRackMenu_Leather.dryLeather, leather, rack)
		end
	else
		-- Show feedback if player has leather but none fits this specific rack size
		local rackName = DryingRackUtils.getDisplayName(rackCategory, rackSize)
		local option = context:addOption("Dry Leather on " .. rackName, nil, nil)
		option.notAvailable = true
		local toolTip = ISWorldObjectContextMenu.addToolTip()
		toolTip:setName("Size Mismatch")
		toolTip.description = "This "
			.. rackName
			.. " is not suitable for the leather in your inventory. <LINE> Strict size matching is required."
		option.toolTip = toolTip
	end
end

if Events and Events.OnFillWorldObjectContextMenu then
	Events.OnFillWorldObjectContextMenu.Add(ISDryingRackMenu_Leather.OnFillWorldObjectContextMenu)
end
