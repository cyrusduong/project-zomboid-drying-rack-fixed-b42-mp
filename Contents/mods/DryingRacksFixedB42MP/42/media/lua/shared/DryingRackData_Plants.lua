-- Plant/Herb type mappings for drying racks

require("DryingRackUtils")

DryingRackData_Plants = {
	small = {
		inputs = {
			"Base.Tobacco",
			"Base.Basil",
			"Base.Oregano",
			"Base.Rosemary",
			"Base.Sage",
			"Base.Thyme",
			"Base.MintHerb",
			"Base.BlackSage",
			"Base.Plantain",
			-- New for B42
			"Base.Chamomile",
			"Base.Chives",
			"Base.Cilantro",
			"Base.Marigold",
			"Base.Parsley",
			"Base.Comfrey",
			"Base.CommonMallow",
			"Base.WildGarlic2",
			"Base.PepperJalapeno",
			"Base.PepperHabanero",
			"Base.Greenpeas",
			"Base.Soybeans",
			"Base.Roses",
			"Base.Lavender",
			"Base.PoppyPods",
			"Base.Hops",
			"Base.GrassTuft",
		},
		outputs = {
			"Base.TobaccoDried",
			"Base.BasilDried",
			"Base.OreganoDried",
			"Base.RosemaryDried",
			"Base.SageDried",
			"Base.ThymeDried",
			"Base.MintHerbDried",
			"Base.BlackSageDried",
			"Base.PlantainDried",
			-- New for B42
			"Base.ChamomileDried",
			"Base.ChivesDried",
			"Base.CilantroDried",
			"Base.MarigoldDried",
			"Base.ParsleyDried",
			"Base.ComfreyDried",
			"Base.CommonMallowDried",
			"Base.WildGarlicDried",
			"Base.PepperJalapenoDried",
			"Base.PepperHabaneroDried",
			"Base.GreenpeasSeed",
			"Base.SoybeansSeed",
			"Base.RosePetalsDried",
			"Base.LavenderPetalsDried",
			"Base.PoppyPodsDried",
			"Base.HopsDried",
			"Base.HayTuft",
		},
	},
	large = {
		inputs = {
			"Base.WheatSheaf",
			"Base.BarleySheaf",
			"Base.RyeSheaf",
			"Base.OatsSheaf",
			"Base.GrassTuft",
			-- New for B42
			"Base.Corn",
			"Base.SunflowerHead",
			"Base.Flax",
			"Base.HempBundle",
		},
		outputs = {
			"Base.WheatSheafDried",
			"Base.BarleySheafDried",
			"Base.RyeSheafDried",
			"Base.OatsSheafDried",
			"Base.HayTuft",
			-- New for B42
			"Base.CornSeed",
			"Base.SunflowerHeadDried",
			"Base.FlaxDried",
			"Base.HempBundleDried",
		},
	},
}

---@type table<string, DryingRackMapping[]>
DryingRackMapping_Plants = {}
for size, data in pairs(DryingRackData_Plants) do
	for i, input in ipairs(data.inputs) do
		local output = data.outputs[i]
		if output then
			if not DryingRackMapping_Plants[input] then
				DryingRackMapping_Plants[input] = {}
			end
			table.insert(DryingRackMapping_Plants[input], {
				output = output,
				size = size,
			})
		end
	end
end
