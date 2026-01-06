-- Generic Timed Action for drying items on racks

require("TimedActions/ISBaseTimedAction")

---@class ISDryItemAction : ISBaseTimedAction
---@field item InventoryItem
---@field outputType InventoryItem
---@field rack IsoObject
---@field time number
ISDryItemAction = ISBaseTimedAction:derive("ISDryItemAction")

function ISDryItemAction:isValid()
	if not self.item or not self.character or not self.rack then
		return false
	end
	local itemContainer = self.item.getContainer and self.item:getContainer()
	local inMainInventory = self.character:getInventory():contains(self.item)
	return (inMainInventory or itemContainer ~= nil) and self.rack:getSquare() ~= nil
end

function ISDryItemAction:waitToStart()
	self.character:faceThisObject(self.rack)
	return self.character:shouldBeTurning()
end

function ISDryItemAction:update()
	self.item:setJobDelta(self:getJobDelta())
	self.character:faceThisObject(self.rack)
end

function ISDryItemAction:start()
	self.item:setJobType("Drying")
	self.item:setJobDelta(0.0)
	self:setActionAnim("Loot")
	self:setAnimVariable("LootPosition", "Medium")
end

function ISDryItemAction:stop()
	ISBaseTimedAction.stop(self)
	self.item:setJobDelta(0.0)
end

function ISDryItemAction:perform()
	self.item:setJobDelta(0.0)

	local itemContainer = self.item.getContainer and self.item:getContainer()

	-- In multiplayer (client mode), always use server commands for authoritative handling
	if isClient() then
		local itemCount = self.item:getCount()
		local args = { itemID = self.item:getID(), outputType = self.outputType, count = itemCount }
		sendClientCommand(self.character, "DryingRack", "dryItem", args)
		
		-- Optimistically remove the wet item locally for responsive UI
		-- The server will authoritatively add the dried item and sync it back
		local originalContainer = itemContainer or self.character:getInventory()
		originalContainer:Remove(self.item)
	else
		-- Single player only - handle locally
		local originalContainer = itemContainer or self.character:getInventory()
		local itemCount = self.item:getCount()
		
		originalContainer:Remove(self.item)
		
		local newItem = originalContainer:AddItem(self.outputType)
		
		if newItem then
			if itemCount and itemCount > 1 then
				newItem:setCount(itemCount)
			end
		else
			print("[ISDryItemAction] ERROR: Failed to add item!")
		end
	end

	-- Feedback
	if self.character:isLocalPlayer() then
		local itemName = "Dried Item"
		local item = instanceItem(self.outputType)
		if item then
			itemName = item:getName()
		end
		HaloTextHelper.addGoodText(self.character, itemName .. " dried")
	end

	-- Part of the action queue
	ISBaseTimedAction.perform(self)
end

--- @param character IsoPlayer
--- @param item InventoryItem
--- @param outputType InventoryItem
--- @param rack IsoObject
--- @param time number
--- @return self
function ISDryItemAction:new(character, item, outputType, rack, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.item = item
	o.outputType = outputType
	o.rack = rack
	o.stopOnWalk = true
	o.stopOnRun = true
	o.maxTime = time or 50
	return o
end
