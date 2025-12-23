require("DryingRackUtils")
require("DryingRackData_Leather")
require("DryingRackData_Plants")

-- Test harness for Drying Rack Fix (Build 42 MP)
DryingRackTests = {}

-- Mock data structures for testing
DryingRackTests.mockPlayer = {
	inventory = {
		items = {
			size = function(self)
				return #self.items_list
			end,
			get = function(self, i)
				return self.items_list[i + 1]
			end,
			getItems = function(self)
				return self
			end, -- Mocking getItems() returning self for simplicity in test loops
			Remove = function(self, item)
				for i, existingItem in ipairs(self.items_list) do
					if existingItem == item then
						table.remove(self.items_list, i)
						return
					end
				end
			end,
			AddItem = function(self, itemType)
				local newItem = {
					fullType = itemType,
					getFullType = function(self)
						return self.fullType
					end,
					getName = function(self)
						return itemType
					end,
				}
				table.insert(self.items_list, newItem)
				return newItem
			end,
		},
		items_list = {},
	},
	getInventory = function(self)
		return self.inventory
	end,
	getCurrentSquare = function(self)
		return {
			getX = function()
				return 0
			end,
			getY = function()
				return 0
			end,
		}
	end,
	Say = function(self, message)
		print("PLAYER SAYS: " .. message)
	end,
}

DryingRackTests.mockRack = {
	name = "DryingRackSmall",
	fullType = "Base.DryingRackSmall",
	getName = function(self)
		return self.name
	end,
	getEntity = function(self)
		return self
	end,
	getFullType = function(self)
		return self.fullType
	end,
	getSquare = function(self)
		return {
			getX = function()
				return 1
			end,
			getY = function()
				return 1
			end,
		}
	end,
}

-- Test 1: Rack Info Detection
function DryingRackTests.testRackInfoDetection()
	print("=== Test 1: Rack Info Detection ===")
	local testCases = {
		{ name = "DryingRackSmall", expectedCat = "leather", expectedSize = "small" },
		{ name = "DryingRackMedium", expectedCat = "leather", expectedSize = "medium" },
		{ name = "DryingRackLarge", expectedCat = "leather", expectedSize = "large" },
		{ name = "HerbDryingRack", expectedCat = "plant", expectedSize = "small" },
	}

	for _, tc in ipairs(testCases) do
		local mock = {
			getName = function()
				return tc.name
			end,
			getEntity = function()
				return nil
			end,
		}
		local cat, size = DryingRackUtils.getRackInfo(mock)
		if cat == tc.expectedCat and size == tc.expectedSize then
			print("PASS: " .. tc.name .. " -> " .. cat .. "/" .. size)
		else
			print(
				"FAIL: "
					.. tc.name
					.. " -> expected "
					.. tc.expectedCat
					.. "/"
					.. tc.expectedSize
					.. ", got "
					.. cat
					.. "/"
					.. size
			)
		end
	end
end

-- Test 2: Leather Size Matching (Strict)
function DryingRackTests.testLeatherSizeMatching()
	print("\n=== Test 2: Leather Size Matching (Strict) ===")
	-- Rabbit = Small, Pig = Medium, Deer = Large
	local rabbitWet = "Base.RabbitLeather_Fur_Tan_Wet"
	local pigWet = "Base.PigLeather_Landrace_Fur_Tan_Wet"

	local smallRack = {
		getName = function()
			return "DryingRackSmall"
		end,
		getEntity = function()
			return nil
		end,
	}
	local mediumRack = {
		getName = function()
			return "DryingRackMedium"
		end,
		getEntity = function()
			return nil
		end,
	}

	-- Mock mapping lookups
	local rabbitMapping = DryingRackMapping_Leather[rabbitWet]
	local pigMapping = DryingRackMapping_Leather[pigWet]

	-- Small rack should ONLY accept small leather
	local _, smallRackSize = DryingRackUtils.getRackInfo(smallRack)
	print("Small Rack accepting Rabbit (Small): " .. tostring(rabbitMapping.size == smallRackSize))
	print("Small Rack accepting Pig (Medium): " .. tostring(pigMapping.size == smallRackSize))

	-- Medium rack should ONLY accept medium leather
	local _, mediumRackSize = DryingRackUtils.getRackInfo(mediumRack)
	print("Medium Rack accepting Rabbit (Small): " .. tostring(rabbitMapping.size == mediumRackSize))
	print("Medium Rack accepting Pig (Medium): " .. tostring(pigMapping.size == mediumRackSize))
end

-- Test 3: Plant Mapping
function DryingRackTests.testPlantMapping()
	print("\n=== Test 3: Plant Mapping ===")
	local tobacco = "Base.Tobacco"
	local mapping = DryingRackMapping_Plants[tobacco]

	if mapping and mapping.output == "Base.TobaccoDried" and mapping.size == "small" then
		print("PASS: Tobacco mapping correct")
	else
		print("FAIL: Tobacco mapping incorrect or missing")
	end
end

function DryingRackTests.runAllTests()
	print("Running Drying Rack Fix Tests...")
	DryingRackTests.testRackInfoDetection()
	DryingRackTests.testLeatherSizeMatching()
	DryingRackTests.testPlantMapping()
end

-- Auto-run if debug
if _G.getDebug and _G.getDebug() then
	DryingRackTests.runAllTests()
end
