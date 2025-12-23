-- Leather type mappings by size category for strict compatibility

require("DryingRackUtils")

DryingRackData_Leather = {
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
			"Base.RaccoonLeather_Grey_Fur_Tan_Wet",
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
			"Base.RaccoonLeather_Grey_Fur_Tan",
		},
	},
	medium = {
		inputs = {
			"Base.Leather_Crude_Medium_Tan_Wet",
			"Base.SheepLeather_Fur_Tan_Wet",
			"Base.PigLeather_Landrace_Fur_Tan_Wet",
			"Base.PigLeather_Black_Fur_Tan_Wet",
		},
		outputs = {
			"Base.Leather_Crude_Medium_Tan",
			"Base.SheepLeather_Fur_Tan",
			"Base.PigLeather_Landrace_Fur_Tan",
			"Base.PigLeather_Black_Fur_Tan",
		},
	},
	large = {
		inputs = {
			"Base.Leather_Crude_Large_Tan_Wet",
			"Base.CowLeather_Angus_Fur_Tan_Wet",
			"Base.CowLeather_Holstein_Fur_Tan_Wet",
			"Base.CowLeather_Simmental_Fur_Tan_Wet",
			"Base.DeerLeather_Fur_Tan_Wet",
		},
		outputs = {
			"Base.Leather_Crude_Large_Tan",
			"Base.CowLeather_Angus_Fur_Tan",
			"Base.CowLeather_Holstein_Fur_Tan",
			"Base.CowLeather_Simmental_Fur_Tan",
			"Base.DeerLeather_Fur_Tan",
		},
	},
}

DryingRackMapping_Leather = {}
for size, data in pairs(DryingRackData_Leather) do
	for i, input in ipairs(data.inputs) do
		DryingRackMapping_Leather[input] = {
			output = data.outputs[i],
			size = size,
		}
	end
end
