-- Shared utilities for all drying racks

DryingRackUtils = {}

---@param entity IsoObject
---@return string category, string size
function DryingRackUtils.getRackInfo(entity)
	local entityObj = entity.getEntity and entity:getEntity()
	local entityFullType = ""
	if entityObj then
		if entityObj.getFullType then
			entityFullType = entityObj:getFullType()
		elseif entityObj.getEntityFullTypeDebug then
			entityFullType = entityObj:getEntityFullTypeDebug()
		end
	end

	local name = entity:getName() or ""

	-- Leather Racks
	if
		entityFullType == "Base.ES_DryingRackSmall"
		or entityFullType == "Base.DryingRackSmall"
		or name == "DryingRackSmall"
	then
		return "leather", "small"
	elseif
		entityFullType == "Base.ES_DryingRackMedium"
		or entityFullType == "Base.DryingRackMedium"
		or name == "DryingRackMedium"
	then
		return "leather", "medium"
	elseif
		entityFullType == "Base.ES_DryingRackLarge"
		or entityFullType == "Base.DryingRackLarge"
		or name == "DryingRackLarge"
	then
		return "leather", "large"
	end

	-- Herb/Plant Racks
	if
		entityFullType == "Base.ES_HerbDryingRack"
		or entityFullType == "Base.HerbDryingRack"
		or name == "HerbDryingRack"
		or string.find(name, "Herb_Drying_Rack")
	then
		return "plant", "small"
	end

	-- Fallback/Modded detection
	if string.find(name, "Simple_Drying_Rack") then
		return "leather", "small"
	end

	return "unknown", "unknown"
end

---@param category string
---@param size string
---@return string
function DryingRackUtils.getDisplayName(category, size)
	local sizeStr = size:gsub("^%l", string.upper)
	if category == "leather" then
		return sizeStr .. " Drying Rack"
	elseif category == "plant" then
		return "Herb Drying Rack"
	end
	return "Drying Rack"
end

---@param player IsoPlayer
---@param rack IsoObject
---@return boolean
function DryingRackUtils.isPlayerNearRack(player, rack)
	if not player or not rack then
		return false
	end
	local playerSquare = player:getCurrentSquare()
	local rackSquare = rack:getSquare()
	if not playerSquare or not rackSquare then
		return false
	end

	local dist =
		IsoUtils.DistanceTo(playerSquare:getX(), playerSquare:getY(), rackSquare:getX() + 0.5, rackSquare:getY() + 0.5)
	return dist <= 3.0
end
