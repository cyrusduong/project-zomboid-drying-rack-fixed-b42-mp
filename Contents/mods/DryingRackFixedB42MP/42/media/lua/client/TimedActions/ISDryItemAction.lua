-- Generic Timed Action for drying items on racks

require("TimedActions/ISBaseTimedAction")

---@class ISDryItemAction : ISBaseTimedAction
ISDryItemAction = ISBaseTimedAction:derive("ISDryItemAction")

function ISDryItemAction:isValid()
	return self.character:getInventory():contains(self.item) and self.rack:getSquare() ~= nil
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

	local inventory = self.character:getInventory()
	local outputItem = inventory:AddItem(self.outputType)

	if outputItem then
		-- Sync item state if necessary (e.g. condition, weight)
		inventory:Remove(self.item)

		-- Feedback
		if self.character:isLocalPlayer() then
			HaloTextHelper.addText(self.character, "Dried Item Created", HaloTextHelper.getColorGreen())
		end
	end

	-- Part of the action queue
	ISBaseTimedAction.perform(self)
end

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
