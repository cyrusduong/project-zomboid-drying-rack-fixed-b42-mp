-- Shared leather drying rack data and utilities
-- This file provides common functionality used by both client and server

LeatherDryingRackUtils = {}

-- Leather type mappings by size category
LeatherDryingRackData = {
    small = {
        inputs = {
            "Base.Leather_Crude_Small_Tan_Wet",
            "Base.CalfLeather_Angus_Fur_Tan_Wet",
            "Base.CalfLeather_Holstein_Fur_Tan_Wet",
            "Base.CalfLeather_Simmental_Fur_Tan_Wet",
            "Base.FawnLeather_Fur_Tan_Wet",
            "Base.LambLeather_Fur_Tan_Wet",
            "Base.PigletLeather_Landrace_Fur_Tan_Wet",
            "Base.PigletLeather_Black_Fur_Tan_Wet",
            "Base.RabbitLeather_Fur_Tan_Wet",
            "Base.RabbitLeather_Grey_Fur_Tan_Wet",
            "Base.RaccoonLeather_Grey_Fur_Tan_Wet"
        },
        outputs = {
            "Base.Leather_Crude_Small_Tan",
            "Base.CalfLeather_Angus_Fur_Tan",
            "Base.CalfLeather_Holstein_Fur_Tan",
            "Base.CalfLeather_Simmental_Fur_Tan",
            "Base.FawnLeather_Fur_Tan",
            "Base.LambLeather_Fur_Tan",
            "Base.PigletLeather_Landrace_Fur_Tan",
            "Base.PigletLeather_Black_Fur_Tan",
            "Base.RabbitLeather_Fur_Tan",
            "Base.RabbitLeather_Grey_Fur_Tan",
            "Base.RaccoonLeather_Grey_Fur_Tan"
        }
    },
    medium = {
        inputs = {
            "Base.Leather_Crude_Medium_Tan_Wet",
            "Base.SheepLeather_Fur_Tan_Wet",
            "Base.PigLeather_Landrace_Fur_Tan_Wet",
            "Base.PigLeather_Black_Fur_Tan_Wet"
        },
        outputs = {
            "Base.Leather_Crude_Medium_Tan",
            "Base.SheepLeather_Fur_Tan",
            "Base.PigLeather_Landrace_Fur_Tan",
            "Base.PigLeather_Black_Fur_Tan"
        }
    },
    large = {
        inputs = {
            "Base.Leather_Crude_Large_Tan_Wet",
            "Base.CowLeather_Angus_Fur_Tan_Wet",
            "Base.CowLeather_Holstein_Fur_Tan_Wet",
            "Base.CowLeather_Simmental_Fur_Tan_Wet",
            "Base.DeerLeather_Fur_Tan_Wet"
        },
        outputs = {
            "Base.Leather_Crude_Large_Tan",
            "Base.CowLeather_Angus_Fur_Tan",
            "Base.CowLeather_Holstein_Fur_Tan",
            "Base.CowLeather_Simmental_Fur_Tan",
            "Base.DeerLeather_Fur_Tan"
        }
    }
}

-- Create input/output mapping for easy lookup
LeatherDryingRackMapping = {}
for size, data in pairs(LeatherDryingRackData) do
    for i, input in ipairs(data.inputs) do
        LeatherDryingRackMapping[input] = {
            output = data.outputs[i],
            size = size
        }
    end
end

-- Utility functions
function LeatherDryingRackUtils.getRackType(entity)
    -- Check for B42 Entity names
    local entityObj = entity.getEntity and entity:getEntity()
    local entityName = entityObj and entityObj:getDefinitionName()
    
    if entityName == "Base.ES_DryingRackSmall" then
        return "small"
    elseif entityName == "Base.ES_DryingRackMedium" then
        return "medium"
    elseif entityName == "Base.ES_DryingRackLarge" then
        return "large"
    end

    -- Fallback to name check for older versions or modded racks
    local name = entity:getName() or ""
    if string.find(name, "Simple_Drying_Rack") or string.find(name, "Herb_Drying_Rack") or string.find(name, "Small") then
        return "small"
    elseif string.find(name, "Large") then
        return "large"
    end
    return "medium" -- default
end

function LeatherDryingRackUtils.getCompatibleSizes(rackType)
    if rackType == "small" then
        return {small = true}
    elseif rackType == "medium" then
        return {small = true, medium = true}
    elseif rackType == "large" then
        return {small = true, medium = true, large = true}
    end
    return {small = true, medium = true} -- fallback default
end

function LeatherDryingRackUtils.isPlayerNearRack(player, rack)
    if not player or not rack then return false end
    
    local playerSquare = player:getCurrentSquare()
    local rackSquare = rack:getSquare()
    
    if not playerSquare or not rackSquare then return false end
    
    -- Using the game's native distance check for better accuracy
    local dist = IsoUtils.DistanceTo(playerSquare:getX(), playerSquare:getY(), rackSquare:getX() + 0.5, rackSquare:getY() + 0.5)
    
    return dist <= 3.0 -- Increased to 3 tiles for easier interaction
end

function LeatherDryingRackUtils.getWetLeatherItems(player)
    local items = {}
    local inventory = player:getInventory()
    
    -- Use a list of all items to find matches, as getFirstTypeRecurse only gets one
    local allItems = inventory:getItems()
    for i=0, allItems:size()-1 do
        local item = allItems:get(i)
        local fullType = item:getFullType()
        local mapping = LeatherDryingRackMapping[fullType]
        if mapping then
            table.insert(items, {
                item = item,
                outputType = mapping.output,
                size = mapping.size,
                inputType = fullType
            })
        end
    end
    
    return items
end
