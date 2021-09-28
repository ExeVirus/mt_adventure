local fmt, insert = string.format, table.insert

local wood_types = {
	"acacia_wood", "aspen_wood", "junglewood", "pine_wood",
}

local material_armor = {
	"bronze", "diamond", "mese", "stone", "wood", "cactus", "gold", "mithril"
}

local material_stairs = {
	"acacia_wood", "aspen_wood", "brick", "bronzeblock", "cobble", "copperblock",
	"desert_cobble", "desert_sandstone", "desert_sandstone_block", "desert_sandstone_brick",
	"desert_stone", "desert_stone_block", "desert_stonebrick",
	"glass", "goldblock", "ice", "junglewood", "mossycobble", "obsidian",
	"obsidian_block", "obsidian_glass", "obsidianbrick", "pine_wood",
	"sandstone", "sandstone_block", "sandstonebrick",
	"silver_sandstone", "silver_sandstone_block", "silver_sandstone_brick",
	"snowblock", "steelblock", "stone", "stone_block", "stonebrick",
	"straw", "tinblock",
}

local colors = {
	"black", "blue", "brown", "cyan", "dark_green", "dark_grey", "green",
	"grey", "magenta", "orange", "pink", "red", "violet", "yellow", "darkgray", "gray",
}

local mese_colors = {
	"black", "blue", "brown", "cyan", "dark_green", "dark_grey", "green",
	"gray", "magenta", "orange", "pink", "red", "violet", "yellow", "darkgray",
}

local to_compress = {
	["default:wood"] = {
		replace = "wood",
		by = wood_types,
	},

	["default:leaves"] = {
		replace = "leaves",
		by = {
			"acacia_leaves",
			"acacia_bush_leaves",
			"aspen_leaves",
			"blueberry_bush_leaves",
			"blueberry_bush_leaves_with_berries",
			"bush_leaves",
			"jungle_leaves",
			"pine_needles",
			"pine_bush_needles",
		},
	},
	
	["default:tree"] = {
		replace = "tree",
		by = {
			"acacia_tree",
			"aspen_tree",
			"jungle_tree",
			"pine_tree",
		},
	},
	
	["default:sapling"] = {
		replace = "sapling",
		by = {
			"acacia_sapling",
			"aspen_sapling",
			"junglesapling",
			"emergent_jungle_sapling",
			"pine_sapling",
			"bush_sapling",
			"acacia_bush_sapling",
			"blueberry_bush_sapling",
			"pine_bush_sapling",
		},
	},

	["default:bush_stem"] = {
		replace = "bush",
		by = {
			"acacia_bush",
			"pine_bush",
		},
	},

	["default:clay_lump"] = {
		replace = "default:clay",
		by = {
			"default:coal",
			"default:copper",
			"default:iron",
			"default:gold",
			"default:tin",
			"moreores:silver_lump",
			"moreores:mithril_lump",
			"nether:nether_lump",
		},
	},

	["default:steel_ingot"] = {
		replace = "default:steel",
		by = {
			"default:copper",
			"default:gold",
			"default:tin",
			"default:bronze",
			"moreores:silver",
			"moreores:mithril",
			"nether:nether",
			"basic_materials:brass",
		},
	},
	
	["default:steelblock"] = {
		replace = "default:steel",
		by = {
			"default:copper",
			"default:gold",
			"default:tin",
			"default:bronze",
			"default:diamond",
			"moreores:silver",
			"moreores:mithril",
			"basic_materials:brass_",
		},
	},

	["basic_materials:chain_brass"] = {
		replace = "basic_materials:chain_brass",
		by = {
			"basic_materials:chain",
			"basic_materials:chainlink_brass",
			"basic_materials:chainlink_steel",
			"basic_materials:chain_steel",
			"basic_materials:chain_brass_top",
			"homedecor:chains",
			"homedecor:chain_steel_top",
		}
	},	
	
	["basic_materials:copper_wire"] = {
		replace = "copper_wire",
		by = {
			"empty_spool",
			"gold_wire",
			"silver_wire",
			"steel_wire",
		}
	},

	["basic_materials:gear_steel"] = {
		replace = "gear_steel",
		by = {
			"cement_block",
			"concrete_block",
			"copper_strip",
			"energy_crystal",
			"heating_element",
			"ic",
			"motor",
			"padlock",
			"paraffin",
			"plastic_sheet",
			"plastic_strip",
			"silicon",
			"steel_bar",
			"steel_strip",
			"energy_crystal_simple",
		},
	},

	["bell:bell"] = {
		replace = ":bell",
		by = {":bell_small"},
	},

	["bike:bike"] = {
		replace = ":bike",
		by = { 
			":handles",
			":wheel",
		},
	},

	["beds:bed_bottom"] = {
		replace = "beds:bed_bottom",
		by = {
			"beds:bed_bottom",
			"homedecor:bed_kingsize",
			"homedecor:bed_regular",
		}
	},

	["homedecor:fence_picket"] = {
		replace = "fence_picket",
		by = {
			"fence_picket_corner",
			"gate_picket_closed",
			"fence_picket_white",
			"fence_picket_corner_white",
			"gate_picket_white_closed",
			"fence_chainlink",
			"fence_chainlink_corner",
			"gate_chainlink_closed",
			"fence_barbed_wire",
			"fence_barbed_wire_corner",
			"gate_barbed_wire_closed",
			"fence_privacy",
			"fence_privacy_corner",
			"fence_wrought_iron_2",
			"fence_wrought_iron_2_corner",
			"fence_wrought_iron",
			"fence_wrought_iron",
			"fence_brass",
		}
	},

	["default:stone_with_coal"] = {
		replace = "coal",
		by = {
			"copper",
			"iron",
			"tin",
			"gold",
			"mese",
			"diamond",
		},
	},

	["default:dirt"] = {
		replace = "dirt",
		by = {
			"dirt_with_grass",
			"dirt_with_dry_grass",
			"dirt_with_coniferous_litter",
			"dirt_with_rainforest_litter",
			"dirt_with_snow",
		},
	},

	["default:grass_1"] = {
		replace = "grass_1",
		by = {
			"jungle_grass",
			"dry_grass_1",
			"marram_grass_1",
		},
	},

	["default:ladder_wood"] = {
		replace = "default:ladder_wood",
		by = {
			"default:ladder_steel",
			"ropes:ladder_wood",
			"ropes:ladder_steel",
			"ropes:ropeladder_top",
		},
	},

	["defuault:coral_brown"] = {
		replace = "brown",
		by = {
			"cyan",
			"green",
			"orange",
			"pink",
		},
	},

	["default:permafrost"] = {
		replace = "frost",
		by = {
			"frost_with_moss",
			"frost_with_stones",
		},
	},

	["default:fence_wood"] = {
		replace = "wood",
		by = wood_types,
	},

	["default:fence_rail_wood"] = {
		replace = "wood",
		by = wood_types,
	},

	["default:mese_post_light"] = {
		replace = "mese_post_light",
		by = {
			"mese_post_light_acacia_wood",
			"mese_post_light_aspen_wood",
			"mese_post_light_junglewood",
			"mese_post_light_pine_wood",
		},
	},

	["doors:gate_wood_closed"] = {
		replace = "wood",
		by = wood_types,
	},

	["doors:door_wood"] = {
		replace = "doors:door_wood",
		by = {
			"doors:door_glass",
			"doors:door_steel",
			"doors:door_obsidian_glass",
			"doors:homedecor_basic_panel",
			"doors:homedecor_carolina",
			"doors:homedecor_closet_mahogany",
			"doors:homedecor_closet_oak",
			"doors:homedecor_exterior_fancy",
			"doors:homedecor_french_mahogany",
			"doors:homedecor_french_oak",
			"doors:homedecor_french_white",
			"doors:homedecor_woodglass",
			"doors:homedecor_wood_plain",
			"doors:homedecor_wrought_iron",
			"homedecor:door_japanese_closed",
			"travelnet:elevator_door_glass_closed",
			"travelnet:elevator_door_steel_closed",
			"travelnet:elevator_door_tin_closed",
			"homedecor:gate_healf_door_closed",
			"homedecor:gate_healf_door_white_closed",
			"castle_gates:oak_door",
			"castle_gates:jail_door",
			"xpanes:door_steel_bar",
		},
	},

	["doors:trapdoor"] = {
		replace = "doors:trapdoor",
		by = {
			"doors:trapdoor_steel",
			"xpanes:trapdoor_steel_bar",
		},
	},

	["drawers:wood1"] = {
		replace = "wood",
		by = {
			"pine_wood",
			"junglewood",
			"aspen_wood",
			"acacia_wood",
		},
	},

	["drawers:wood2"] = {
		replace = "wood",
		by = {
			"pine_wood",
			"junglewood",
			"aspen_wood",
			"acacia_wood",
		},
	},

	["drawers:wood4"] = {
		replace = "wood",
		by = {
			"pine_wood",
			"junglewood",
			"aspen_wood",
			"acacia_wood",
		},
	},

	["drawers:upgrade_template"] = {
		replace = "template",
		by = {
			"steel",
			"gold",
			"obsidian",
			"diamond",
		},
	},

	["dmobs:badger"] = {
		replace = "badger",
		by = {
			"dragon",
			"dragon1",
			"dragon2",
			"dragon3",
			"dragon4",
			"dragon_black",
			"dragon_blue",
			"dragon_green",
			"dragon_red",
			"dragon_egg_great",
			"dragon_great",
			"dragon_great_tame",
			"waterdragon",
			"egg",
			"elephant",
			"fox",
			"gnorm",
			"golem",
			"golem_friendly",
			"hedgehog",
			"ogre",
			"orc",
			"orc2",
			"owl",
			"panda",
			"pig",
			"pig_evil",
			"rat",
			"skeleton",
			"tortoise",
			"treeman",
			"wasp",
			"wasp_leader",
			"whale",
			"wyvern",
		},
	},

	["wool:white"] = {
		replace = "white",
		by = colors
	},

	["dye:white"] = {
		replace = "white",
		by = colors
	},

	["default:axe_steel"] = {
		replace = "default:axe_steel",
		by = {
			"default:axe_bronze",
			"default:axe_diamond",
			"default:axe_mese",
			"default:axe_stone",
			"default:axe_wood",
			"moreores:axe_silver",
			"moreores:axe_mithril",
			"nether:axe_nether",
		}
	},

	["default:pick_steel"] = {
		replace = "default:pick_steel",
		by = {
			"default:pick_bronze",
			"default:pick_diamond",
			"default:pick_mese",
			"default:pick_stone",
			"default:pick_wood",
			"moreores:pick_silver",
			"moreores:pick_mithril",
			"nether:pick_nether",
		}
	},

	["default:shovel_steel"] = {
		replace = "default:shovel_steel",
		by = {
			"default:shovel_bronze",
			"default:shovel_diamond",
			"default:shovel_mese",
			"default:shovel_stone",
			"default:shovel_wood",
			"moreores:shovel_silver",
			"moreores:shovel_mithril",
			"nether:shovel_nether",
		}
	},

	["default:sword_steel"] = {
		replace = "default:sword_steel",
		by = {
			"default:sword_bronze",
			"default:sword_diamond",
			"default:sword_mese",
			"default:sword_stone",
			"default:sword_wood",
			"moreores:sword_silver",
			"moreores:sword_mithril",
			"nether:sword_nether",
		}
	},

	["farming:hoe_steel"] = {
		replace = "farming:hoe_steel",
		by = {
			"farming:hoe_bronze",
			"farming:hoe_diamond",
			"farming:hoe_mese",
			"farming:hoe_stone",
			"farming:hoe_wood",
			"moreores:hoe_silver",
			"moreores:hoe_mithril",
			"nether:hoe_nether",
		}
	},

	["flowers:chrysanthemum_green"] = {
		replace = "chrysanthemum_green",
		by = {
			"dandelion_white",
			"dandelion_yellow",
			"germanium",
			"rose",
			"tulip",
			"tulip_black",
			"viola",
			"waterlily",
			"mushroom_brown",
			"mushroom_red",
		},
	},

	["stairs:slab_wood"] = {
		replace = "wood",
		by = material_stairs
	},

	["stairs:stair_wood"] = {
		replace = "wood",
		by = material_stairs
	},

	["stairs:stair_inner_wood"] = {
		replace = "wood",
		by = material_stairs
	},

	["stairs:stair_outer_wood"] = {
		replace = "wood",
		by = material_stairs
	},

	["walls:cobble"] = {
		replace = "cobble",
		by = {"desertcobble", "mossycobble"}
	},

	["homedecor:painting_1"] = {
		replace = "1",
		by = {"2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"}
	},

	["mesecons_lightstone:lightstone_white_off"] = {
		replace = "white",
		by = mese_colors,
	},

	["mobs_animal:sheep_white"] = {
		replace = "white",
		by = colors,
	},

	["ropes:wood1rope_block"] = {
		replace = "1",
		by = {"2"},
	},

	["ropes:copper1rope_block"] = {
		replace = "1",
		by = {"2","3","4","5"},
	},

	["ropes:steel1rope_block"] = {
		replace = "1",
		by = {"2","3","4","5","6","7","8","9"},
	},

	["3d_armor:boots_steel"] = {
		replace = "steel",
		by = material_armor
	},

	["3d_armor:chestplate_steel"] = {
		replace = "steel",
		by = material_armor
	},

	["3d_armor:helmet_steel"] = {
		replace = "steel",
		by = material_armor
	},

	["3d_armor:leggings_steel"] = {
		replace = "steel",
		by = material_armor
	},

	["carts:rail"] = {
		replace = "carts:rail",
		by = {
			"carts:brakerail",
			"carts:copperrail",
			"carts:powerrail",
			"boost_cart:detectorrail",
			"boost_cart:startstoprail",
		}
	},

	["airtanks:steel_tank"] = {
		replace = "steel_tank",
		by = {
			"steel_tank_2",
			"steel_tank_3",
			"bronze_tank",
			"bronze_tank_2",
			"bronze_tank_3",
			"copper_tank",
			"copper_tank_2",
			"copper_tank_3",
			"empty_steel_tank",
			"empty_steel_tank_2",
			"empty_steel_tank_3",
			"empty_bronze_tank",
			"empty_bronze_tank_2",
			"empty_bronze_tank_3",
			"empty_copper_tank",
			"empty_copper_tank_2",
			"empty_copper_tank_3",
		}
	},

	["butterflies:butterfly_red"] = {
		replace = "red",
		by = {"violet","white"}
	},

	["algae:algae_thin"] = {
		replace = "thin",
		by = {"medium","thick"}
	},

	["bows:arrow"] = {
		replace = "arrow",
		by = {"arrow_mese", "arrow_diamond", "arrow_steel"}
	},

	["bows:bow_wood"] = {
		replace = "wood",
		by = {"steel", "bronze", "bowie"}
	},

	["bucket:bucket_empty"] = {
		replace = "empty",
		by = {"water", "lava", "river_water"}
	},

	["bucket_wooden:bucket_empty"] = {
		replace = "empty",
		by = {"water", "river_water"}
	},

	["bonemeal:bonemeal"] = {
		replace = ":bonemeal",
		by = {":fertiliser",":mulch"},
	},

	["cartographer:simple_table"] = {
		replace = "simple",
		by = {"standard","advanced"},
	},

	["cartographer:simple_table"] = {
		replace = "simple",
		by = {"standard","advanced"},
	},

	["castle_gates:steel_gate_panel"] = {
		replace = "steel_gate_panel",
		by = {
			"steel_gate_hinge",
			"steel_gate_edge_handle",
			"steel_gate_edge_handle",
			"steel_gate_edge",
			"steel_portcullis_bars",
			"steel_portcullis_bars_bottom",
			"wood_gate_panel",
			"wood_gate_hinge",
			"wood_gate_edge_handle",
			"wood_gate_edge_handle",
			"wood_gate_edge",
			"wood_portcullis_bars",
			"wood_portcullis_bars_bottom",
		},
	},
	
	["caverealms:glow_mese"] = {
		replace = "mese",
		by = {
			"amethyst",
			"crystal",
			"emerald",
			"ruby",
		},
	},

	["caverealms:glow_emerald_ore"] = {
		replace = "emerald_ore",
		by = {
			"amethyst_ore",
			"ore", --crystal
			"ruby_ore",
		},
	},

	["caverealms:stone_with_algae"] = {
		replace = "algae",
		by = {
			"moss",
			"lichen",
		},
	},

	["caverealms:glow_worm"] = {
		replace = "worm",
		by = {
			"worm_green",
		},
	},

	["dmobs:dragon_gem"] = {
		replace = "gem",
		by = {
			"gem_fire",
			"gem_ice",
			"gem_lightning",
			"gem_poison",
		}
	},

	["falls:basin"] = {
		replace = "basin",
		by = {
			"lava_basin",
			"basin_inv",
			"lava_basin_inv",
		}
	},

	["falls:basin"] = {
		replace = "basin",
		by = {
			"lava_basin",
			"basin_inv",
			"lava_basin_inv",
		}
	},

	["falls:bucket_turbulent"] = {
		replace = "bucket",
		by = {
			"lava",
		}
	},

	["falls:fountain"] = {
		replace = "fountain",
		by = {
			"lava_fountain",
		}
	},

	["falls:waterfall_block"] = {
		replace = "waterfall_block",
		by = {
			"lavafall_block",
			"waterfall_block_inv",
			"lavafall_block_inv",
		}
	},

	--Bricks and blocks
	["caverealms:glow_obsidian"] = {
		replace = "an",
		by = {
			"an_brick",
		}
	},

	["caverealms:glow_obsidian2"] = {
		replace = "2",
		by = {
			"2_brick",
		}
	},

	["default:obsidian"] = {
		replace = "ne",
		by = {
			"an_block",
			"an_brick",
		}
	},
	
	["default:desert_sandstone"] = {
		replace = "ne",
		by = {
			"ne_block",
			"ne_brick",
		}
	},
	
	["default:silver_sandstone"] = {
		replace = "ne",
		by = {
			"ne_block",
			"ne_brick",
		}
	},

	["default:sandstone"] = {
		replace = "ne",
		by = {
			"ne_block",
			"ne_brick",
		}
	},

	["default:desert_stone"] = {
		replace = "ne",
		by = {
			"ne_block",
			"nebrick",
		}
	},
	
	["default:coal_stone"] = {
		replace = "ne",
		by = {
			"ne_brick",
		}
	},

	["default:iron_stone"] = {
		replace = "ne",
		by = {
			"ne_brick",
		}
	},
}

local circular_saw_names = {
	{"micro", "_1"},
	{"panel", "_1"},
	{"micro", "_2"},
	{"panel", "_2"},
	{"micro", "_4"},
	{"panel", "_4"},
	{"micro", ""},
	{"panel", ""},

	{"micro", "_12"},
	{"panel", "_12"},
	{"micro", "_14"},
	{"panel", "_14"},
	{"micro", "_15"},
	{"panel", "_15"},
	{"stair", "_outer"},
	{"stair", ""},

	{"stair", "_inner"},
	{"slab", "_1"},
	{"slab", "_2"},
	{"slab", "_quarter"},
	{"slab", ""},
	{"slab", "_three_quarter"},
	{"slab", "_14"},
	{"slab", "_15"},

	{"slab", "_two_sides"},
	{"slab", "_three_sides"},
	{"slab", "_three_sides_u"},
	{"stair", "_half"},
	{"stair", "_alt_1"},
	{"stair", "_alt_2"},
	{"stair", "_alt_4"},
	{"stair", "_alt"},
	{"stair", "_right_half"},

	{"slope", ""},
	{"slope", "_half"},
	{"slope", "_half_raised"},
	{"slope", "_inner"},
	{"slope", "_inner_half"},
	{"slope", "_inner_half_raised"},
	{"slope", "_inner_cut"},
	{"slope", "_inner_cut_half"},

	{"slope", "_inner_cut_half_raised"},
	{"slope", "_outer"},
	{"slope", "_outer_half"},
	{"slope", "_outer_half_raised"},
	{"slope", "_outer_cut"},
	{"slope", "_outer_cut_half"},
	{"slope", "_outer_cut_half_raised"},
	{"slope", "_cut"},
}

local moreblocks_nodes = {
	"coal_stone",
	"wood_tile",
	"iron_checker",
	"circle_stone_bricks",
	"cobble_compressed",
	"plankstone",
	"clean_glass",
	"split_stone_tile",
	"all_faces_tree",
	"dirt_compressed",
	"coal_checker",
	"clean_glow_glass",
	"tar",
	"clean_super_glow_glass",
	"stone_tile",
	"cactus_brick",
	"super_glow_glass",
	"desert_cobble_compressed",
	"copperpatina",
	"coal_stone_bricks",
	"glow_glass",
	"cactus_checker",
	"all_faces_pine_tree",
	"all_faces_aspen_tree",
	"all_faces_acacia_tree",
	"all_faces_jungle_tree",
	"iron_stone",
	"grey_bricks",
	"wood_tile_left",
	"wood_tile_down",
	"wood_tile_center",
	"wood_tile_right",
	"wood_tile_full",
	"checker_stone_tile",
	"iron_glass",
	"iron_stone_bricks",
	"wood_tile_flipped",
	"wood_tile_offset",
	"coal_glass",

	"straw",

	"stone",
	"stone_block",
	"cobble",
	"mossycobble",
	"brick",
	"sandstone",
	"steelblock",
	"goldblock",
	"copperblock",
	"bronzeblock",
	"diamondblock",
	"tinblock",
	"desert_stone",
	"desert_stone_block",
	"desert_cobble",
	"meselamp",
	"glass",
	"tree",
	"wood",
	"jungletree",
	"junglewood",
	"pine_tree",
	"pine_wood",
	"acacia_tree",
	"acacia_wood",
	"aspen_tree",
	"aspen_wood",
	"obsidian",
	"obsidian_block",
	"obsidianbrick",
	"obsidian_glass",
	"stonebrick",
	"desert_stonebrick",
	"sandstonebrick",
	"silver_sandstone",
	"silver_sandstone_brick",
	"silver_sandstone_block",
	"desert_sandstone",
	"desert_sandstone_brick",
	"desert_sandstone_block",
	"sandstone_block",
	"coral_skeleton",
	"ice",
}

local nether_nodes = {
	"brick",
}

local building_blocks_nodes = {
	"Adobe",
	"fakegrass",
	"grate",
	"hardwood",
	"Marble",
	"Tar",
	"woodglass",
	"smoothglass",
	"Roofing",
}

local colors_moreblocks = table.copy(colors)
insert(colors_moreblocks, "white")

local moreblocks_mods = {
	wool = colors_moreblocks,
	moreblocks = moreblocks_nodes,
	nether = nether_nodes,
	building_blocks = building_blocks_nodes,
}

local t = {}

for mod, v in pairs(moreblocks_mods) do
for _, nodename in ipairs(v) do
	t[nodename] = {}

	for _, shape in ipairs(circular_saw_names) do
		local to_add = true

		if shape[1] == "slope" and shape[2] == "" then
			to_add = nil
		end

		if to_add then
			insert(t[nodename], fmt("%s_%s%s", shape[1], nodename, shape[2]))
		end
	end

	local slope_name = fmt("slope_%s", nodename)
	to_compress[fmt("%s:%s", mod, slope_name)] = {
		replace = slope_name,
		by = t[nodename]
	}
end
end

local compressed = {}

for k, v in pairs(to_compress) do
	compressed[k] = compressed[k] or {}

	for _, str in ipairs(v.by) do
		local it = k:gsub(v.replace, str)
		insert(compressed[k], it)
	end
end

local _compressed = {}

for _, v in pairs(compressed) do
for _, v2 in ipairs(v) do
	_compressed[v2] = true
end
end

return compressed, _compressed
