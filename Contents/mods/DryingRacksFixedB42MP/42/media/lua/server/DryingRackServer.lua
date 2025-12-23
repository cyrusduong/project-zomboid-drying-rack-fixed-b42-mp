if isClient() then return end

DryingRackServer = {}
DryingRackServer.Commands = {}

---@param player IsoPlayer
---@param args table
function DryingRackServer.Commands.dryItem(player, args)
	local itemID = args.itemID
	local outputType = args.outputType
	
	print("[DryingRackServer] dryItem - player: " .. tostring(player:getUsername()) .. ", itemID: " .. tostring(itemID) .. ", outputType: " .. tostring(outputType))
	
	local inventory = player:getInventory()
	
	-- In B42, we try multiple ways to find the item
	local item = inventory:getItemWithID(itemID)
	
	if not item then
		-- Fallback: iterate all items to see if ID matches (ID types can be inconsistent)
		local items = inventory:getItems()
		for i=0, items:size()-1 do
			local it = items:get(i)
			if it:getID() == itemID then
				item = it
				print("[DryingRackServer] found item via iteration fallback")
				break
			end
		end
	end
	
	if item then
		print("[DryingRackServer] removing: " .. tostring(item:getFullType()) .. " (ID: " .. tostring(item:getID()) .. ")")
		inventory:Remove(item)
		
		print("[DryingRackServer] adding: " .. tostring(outputType))
		local newItem = inventory:AddItem(outputType)
		
		if newItem then
			print("[DryingRackServer] successfully added: " .. tostring(newItem:getFullType()) .. " (New ID: " .. tostring(newItem:getID()) .. ")")
			-- Explicitly send back to client to ensure immediate UI update
			sendAddItemToContainer(inventory, newItem)
		else
			print("[DryingRackServer] ERROR: Failed to add item " .. tostring(outputType))
		end
	else
		print("[DryingRackServer] ERROR: Item with ID " .. tostring(itemID) .. " not found in player inventory.")
	end
end

local function OnClientCommand(module, command, player, args)
	if module == "DryingRack" then
		if DryingRackServer.Commands[command] then
			DryingRackServer.Commands[command](player, args)
		end
	end
end

Events.OnClientCommand.Add(OnClientCommand)
print("[DryingRackServer] Loaded and registered OnClientCommand")
