 -- Shared utilities for all drying racks
 
 DryingRackUtils = {}
 
 ---@param entity IsoObject
 ---@return string category, string size
function DryingRackUtils.getRackInfo(entity)
	local entityFullType = ""
	local displayName = ""
	if entity.getEntity and entity:getEntity() then
		local entityObj = entity:getEntity()
		if entityObj.getEntityFullTypeDebug then
			entityFullType = entityObj:getEntityFullTypeDebug()
		elseif entityObj.getFullType then
			entityFullType = entityObj:getFullType()
		end
		if entityObj.getDisplayName then
			displayName = entityObj:getDisplayName() or ""
		end
	end

	local name = ""
	if entity.getName then
		name = entity:getName() or ""
	end

	local spriteName = ""
	if entity.getSpriteName then
		spriteName = entity:getSpriteName() or ""
	elseif entity.getSprite then
		local sprite = entity:getSprite()
		if sprite and sprite.getName then
			spriteName = sprite:getName() or ""
		end
	end

	print("[DryingRackUtils.getRackInfo] entityFullType=" .. entityFullType .. ", displayName=" .. displayName .. ", name=" .. name .. ", spriteName=" .. spriteName)

	-- Match on entity types first (most reliable) - normalizing by removing spaces
	-- NOTE: In Build 42, world objects often lack full type metadata. We check multiple sources.
	local typeNormalized = entityFullType:gsub("%s+", "")
	local nameNormalized = name:gsub("%s+", "")
	local displayNameNormalized = displayName:gsub("%s+", "")
	local spriteNormalized = spriteName:gsub("%s+", "")

	-- Leather Racks
	-- These are custom mod entities, usually more reliable than vanilla vegetation sprites.
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

	-- Plant Racks based on entity type or display name
	-- Vanilla B42 plant racks are notoriously inconsistent with their metadata.
	if typeNormalized == "Base.Simple_Herb_Drying_Rack" or displayNameNormalized:find("SimpleSmallPlantDryingRack") then
		return "plant", "small"
	elseif typeNormalized == "Base.Herb_Drying_Rack" or displayNameNormalized:find("SmallPlantDryingRack") then
		return "plant", "small"
	elseif typeNormalized == "Base.Simple_Drying_Rack" or displayNameNormalized:find("SimpleLargePlantDryingRack") then
		return "plant", "large"
	elseif typeNormalized == "Base.Drying_Rack" or displayNameNormalized:find("LargePlantDryingRack") then
		return "plant", "large"
	end

	-- Fallback: Match on sprite atlas index in ANY of the metadata strings
	-- B42 often leaves 'entityFullType' and 'displayName' empty for vanilla world objects.
	-- We parse the sprite name (e.g., vegetation_drying_01_239) which is almost always present.
	-- Indices mapping for 'vegetation_drying_01' sheet:
	-- Small racks (herbs): 8, 9, 224, 225
	-- Large racks (wheat/barley/rye): 20, 21, 22, 23, 236, 237, 238, 239
	local allStrings = { typeNormalized, nameNormalized, displayNameNormalized, spriteNormalized }
	for _, s in ipairs(allStrings) do
		if s:find("vegetation_drying_01_") then
			local prefix = s:match("vegetation_drying_01_(%d+)")
			print("[DryingRackUtils.getRackInfo] matched pattern in string: " .. s .. " -> prefix=" .. tostring(prefix))
			local tileNum = tonumber(prefix)
			if tileNum then
				-- Categorization based on visual size in the sprite sheet
				if tileNum == 8 or tileNum == 9 or tileNum == 224 or tileNum == 225 then
					return "plant", "small"
				elseif tileNum == 236 or tileNum == 237 or tileNum == 238 or tileNum == 239 or tileNum == 20 or tileNum == 21 or tileNum == 22 or tileNum == 23 then
					-- Index 236 is the "Simple Large Plant Drying Rack" which looks identical to 239
					return "plant", "large"
				else
					-- Default to large for any other index in this sheet to ensure visibility
					return "plant", "large"
				end
			end
		end
	end

	-- Final fallback for objects named "Drying_Rack" or "DryingRack" but without specific index
	-- This handles cases where the game might have normalized the name but lost the sprite info.
	if nameNormalized == "Drying_Rack" or nameNormalized == "DryingRack" or displayNameNormalized:find("DryingRack") then
		return "plant", "large"
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
 