 -- Shared utilities for all drying racks
 
 DryingRackUtils = {}
 
 ---@param entity IsoObject
 ---@return string category, string size
 function DryingRackUtils.getRackInfo(entity)
 	local entityFullType = ""
 	if entity.getEntity and entity:getEntity() then
 		local entityObj = entity:getEntity()
 		if entityObj.getFullType then
 			entityFullType = entityObj:getFullType()
 		elseif entityObj.getEntityFullTypeDebug then
 			entityFullType = entityObj:getEntityFullTypeDebug()
 		end
 	end
 
 	local name = ""
 	if entity.getName then
 		name = entity:getName() or ""
 	end
 
 	print("[DryingRackUtils.getRackInfo] entityFullType=" .. entityFullType .. ", name=" .. name)
 
 	-- Match on entity types first (most reliable) - normalizing by removing spaces
 	local typeNormalized = entityFullType:gsub("%s+", "")
 	local nameNormalized = name:gsub("%s+", "")
 
 	-- Leather Racks
 	if
 		typeNormalized == "Base.ES_DryingRackSmall"
 		or typeNormalized == "Base.DryingRackSmall"
 		or nameNormalized == "DryingRackSmall"
 		then
 		return "leather", "small"
 	elseif
 		typeNormalized == "Base.ES_DryingRackMedium"
 		or typeNormalized == "Base.DryingRackMedium"
 		or nameNormalized == "DryingRackMedium"
 		then
 		return "leather", "medium"
 	elseif
 		typeNormalized == "Base.ES_DryingRackLarge"
 		or typeNormalized == "Base.DryingRackLarge"
 		or nameNormalized == "DryingRackLarge"
 		then
 		return "leather", "large"
 	end
 
 	-- Plant Racks based on exact entity name
 	if typeNormalized == "Base.Simple_Herb_Drying_Rack" then
 		return "plant", "small"
 	elseif typeNormalized == "Base.Herb_Drying_Rack" then
 		return "plant", "small"
 	elseif typeNormalized == "Base.Simple_Drying_Rack" then
 		return "plant", "large"
 	elseif typeNormalized == "Base.Drying_Rack" then
 		return "plant", "large"
 	end
 
 	-- Fallback: Match on display name prefix (not tile number)
 	-- Tile numbers (21, 22, 236, etc.) change based on world position,
 	-- so we only match to prefix that identifies rack type.
 	--
 	-- Tile patterns found in console:
 	-- vegetation_drying_01_236 = Small Plant (herbs)
 	-- vegetation_drying_01_21, vegetation_drying_01_224 = Large Plant (wheat/barley/rye)
 	local prefix = ""
 	if nameNormalized:find("vegetation_drying_01_") then
 		prefix = nameNormalized:match("vegetation_drying_01_(%d+)")
 	end

 	print("[DryingRackUtils.getRackInfo] prefix=" .. tostring(prefix))
 	-- Match based on name patterns first
 	if nameNormalized:find("Simple_Herb_Drying_Rack") then
 		return "plant", "small"
 	elseif nameNormalized:find("Herb_Drying_Rack") then
 		return "plant", "small"
 	elseif nameNormalized:find("Simple_Drying_Rack") then
 		return "plant", "large"
 	elseif nameNormalized:find("^Drying_Rack:") then
 		return "plant", "large"
 	elseif nameNormalized:find("Drying_Rack") and nameNormalized:find("vegetation_drying") then
 		-- Vanilla plant racks: match based on prefix only
 		if prefix == "236" or prefix == "225" then
 			return "plant", "small"
 		else
 			return "plant", "large"
 		end
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
 		if size == "large" then
 			return "Large Herb Drying Rack"
 		else
 			return "Herb Drying Rack"
 		end
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
 