
if minetest.get_modpath("lucky_block") then

	lucky_block:add_blocks({
		{"dro", {"bows:bow_wood"}},
		{"dro", {"bows:bow_steel"}},
		{"dro", {"bows:bow_bronze"}},
		{"dro", {"bows:arrow"}, 5},
		{"dro", {"bows:arrow_steel"}, 5},
		{"dro", {"bows:arrow_mese"}, 5},
		{"dro", {"bows:arrow_diamond"}, 5},
		{"nod", "default:chest", 0, {
			{name = "default:stick", max = 5},
			{name = "default:flint", max = 3},
			{name = "default:steel_ingot", max = 3},
			{name = "default:bronze_ingot", max = 3},
			{name = "default:mese_crystal_fragment", max = 3},
			{name = "farming:string", max = 5},
			{name = bows.feather, max = 4},
			{name = "bows:bow_bowie", max = 1}
		}},
	})
end