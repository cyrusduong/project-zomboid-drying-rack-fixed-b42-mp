-- Plant/Herb Drying Rack Context Menu Implementation
-- Strictly matches item size to rack size (Plants are currently all "small")

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
	for i = 0, allItems:size() - 1 do
		local item = allItems:get(i)
		local fullType = item:getFullType()
		local mapping = DryingRackMapping_Plants[fullType]
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
---@param plantData table
---@param rack IsoObject
function ISDryingRackMenu_Plants.dryPlant(player, plantData, rack)
	if luautils.walkToAdjacentTile(player, rack:getSquare()) then
		ISTimedActionQueue.add(ISDryItemAction:new(player, plantData.item, plantData.outputType, rack, 100))
	end
end

---@param player IsoPlayer
---@param compatiblePlants table
---@param rack IsoObject
function ISDryingRackMenu_Plants.dryAll(player, compatiblePlants, rack)
	for _, plantData in ipairs(compatiblePlants) do
		if luautils.walkToAdjacentTile(player, rack:getSquare()) then
			ISTimedActionQueue.add(ISDryItemAction:new(player, plantData.item, plantData.outputType, rack, 100))
		end
	end
end

---@param player integer
---@param context ISContextMenu
---@param worldobjects IsoObject[]
function ISDryingRackMenu_Plants.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
	if test and ISWorldObjectContextMenu.Test then
		return
	end
	local playerObj = getSpecificPlayer(player)

	local rack = nil
	local rackCategory = nil
	local rackSize = nil

	for _, obj in ipairs(worldobjects) do
		local category, size = DryingRackUtils.getRackInfo(obj)
		if category == "plant" then
			rack = obj
			rackCategory = category
			rackSize = size
			break
		end
	end

	if not rack then
		return
	end

	local dryablePlants = ISDryingRackMenu_Plants.getDryablePlantItems(playerObj)
	if #dryablePlants == 0 then
		return
	end

	-- Filter plants for STRICT compatibility (though plants currently only have 'small')
	local compatiblePlants = {}
	for _, plant in ipairs(dryablePlants) do
		if plant.size == rackSize then
			table.insert(compatiblePlants, plant)
		end
	end

	if #compatiblePlants > 0 then
		local rackName = DryingRackUtils.getDisplayName(rackCategory, rackSize)
		local option = context:addOption("Dry Herbs on " .. rackName, playerObj, nil)
		local subMenu = context:getNew(context)
		context:setSubMenu(option, subMenu)

		-- "Dry All" option
		if #compatiblePlants > 1 then
			subMenu:addOption(
				"Dry All (" .. #compatiblePlants .. ")",
				playerObj,
				ISDryingRackMenu_Plants.dryAll,
				compatiblePlants,
				rack
			)
		end

		-- Individual options
		for _, plant in ipairs(compatiblePlants) do
			local label = plant.item:getName()
			subMenu:addOption(label, playerObj, ISDryingRackMenu_Plants.dryPlant, plant, rack)
		end
	end
end

if Events and Events.OnFillWorldObjectContextMenu then
	Events.OnFillWorldObjectContextMenu.Add(ISDryingRackMenu_Plants.OnFillWorldObjectContextMenu)
end
