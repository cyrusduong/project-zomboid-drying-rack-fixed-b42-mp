if not isServer() then return end

DryingRackServer = {}
DryingRackServer.Commands = {}

---@param player IsoPlayer
---@param args table
function DryingRackServer.Commands.dryItem(player, args)
	local itemID = args.itemID
	local outputType = args.outputType
	local count = args.count
	
	print("[DryingRackServer] dryItem - player: " .. tostring(player:getUsername()) .. ", itemID: " .. tostring(itemID) .. ", outputType: " .. tostring(outputType) .. ", count: " .. tostring(count))
	
	-- Find the item - search main inventory first
	local inventory = player:getInventory()
	local item = inventory:getItemWithID(itemID)
	
	-- Also search all containers the player has access to
	local itemContainer = nil
	if not item then
		print("[DryingRackServer] Searching in all containers...")
		-- Check main inventory
		local mainItems = inventory:getItems()
		for i = 0, mainItems:size() - 1 do
			local it = mainItems:get(i)
			if it and it:getID() == itemID then
				item = it
				itemContainer = inventory
				print("[DryingRackServer] Found item in main inventory")
				break
			end
		end
		
		-- If not found, check worn item containers (bags, etc.)
		if not item then
			local wornItems = player:getWornItems()
			if wornItems then
				for i = 0, wornItems:size() - 1 do
					local wornItem = wornItems:get(i)
					if wornItem then
						local wornObj = wornItem:getItem()
						if wornObj and wornObj.getItemContainer then
							local cont = wornObj:getItemContainer()
							if cont and cont.getItems then
								local contItems = cont:getItems()
								for j = 0, contItems:size() - 1 do
									local it = contItems:get(j)
									if it and it:getID() == itemID then
										item = it
										itemContainer = cont
										print("[DryingRackServer] Found item in worn container: " .. tostring(wornObj:getFullType()))
										break
									end
								end
							end
						end
						if item then break end
					end
				end
			end
		end
	end
	
	if item then
		-- Get count from original item if not provided in args
		if not count or count <= 0 then
			count = item:getCount()
		end
		
		-- Remove from wherever it is
		print("[DryingRackServer] removing: " .. tostring(item:getFullType()) .. " (ID: " .. tostring(item:getID()) .. ")")
		if itemContainer then
			itemContainer:Remove(item)
		else
			inventory:Remove(item)
		end
		
		-- Add new item to the same container (or main inventory if no container)
		print("[DryingRackServer] adding: " .. tostring(outputType))
		local newItem = nil
		if itemContainer then
			newItem = itemContainer:AddItem(outputType)
			print("[DryingRackServer] Added to original container")
		else
			newItem = inventory:AddItem(outputType)
			print("[DryingRackServer] Added to main inventory")
		end
		
		if newItem then
			if count and count > 1 then
				newItem:setCount(count)
				print("[DryingRackServer] set quantity to: " .. tostring(count))
			end
			print("[DryingRackServer] successfully added: " .. tostring(newItem:getFullType()) .. " (New ID: " .. tostring(newItem:getID()) .. ")")
			
			-- Sync the container to the client so they see the update immediately
			if itemContainer then
				sendAddItemToContainer(itemContainer, newItem)
				print("[DryingRackServer] Synced container to client")
			else
				sendAddItemToContainer(inventory, newItem)
				print("[DryingRackServer] Synced main inventory to client")
			end
		else
			print("[DryingRackServer] ERROR: Failed to add item " .. tostring(outputType))
		end
	else
		print("[DryingRackServer] ERROR: Item with ID " .. tostring(itemID) .. " not found in player inventory or containers.")
	end
end

local function OnClientCommand(module, command, player, args)
	print("[DryingRackServer] OnClientCommand - module: " .. tostring(module) .. ", command: " .. tostring(command))
	if module == "DryingRack" then
		if DryingRackServer.Commands[command] then
			DryingRackServer.Commands[command](player, args)
		end
	end
end

Events.OnClientCommand.Add(OnClientCommand)
print("[DryingRackServer] Loaded and registered OnClientCommand")
