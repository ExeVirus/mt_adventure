-- Biomes
-- Icesheet
cartographer.biomes.add("icesheet", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_snow",
});
cartographer.biomes.add("icesheet_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
});
cartographer.biomes.add("icesheet_ocean", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_snow",
}, 1);

-- Tundra
cartographer.biomes.add("tundra", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_snow",
    "ctg_mtg_colored_snow",
    "ctg_mtg_tundra",
});
cartographer.biomes.add("tundra_highland", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_snow",
    "ctg_mtg_colored_snow",
    "ctg_mtg_tundra",
});
cartographer.biomes.add("tundra_beach", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
    "ctg_mtg_tundra",
});
cartographer.biomes.add("tundra_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
});

-- Taiga
cartographer.biomes.add("taiga", {
    "ctg_mtg_simple_forest",
    "ctg_mtg_snowy_forest",
    "ctg_mtg_coniferous_snowy",
});
cartographer.biomes.add("taiga_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
}, nil, 0);
cartographer.biomes.add("taiga_ocean", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_snow",
}, 1);

-- Snowy Grassland
cartographer.biomes.add("snowy_grassland", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_snow",
});
cartographer.biomes.add("snowy_grassland_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
}, nil, 0);
cartographer.biomes.add("snowy_grassland_ocean", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_snow",
}, 1);


-- Grassland
cartographer.biomes.add("grassland", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_land",
});
cartographer.biomes.add("grassland_dunes", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
});
cartographer.biomes.add("grassland_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
}, nil, 0);
cartographer.biomes.add("grassland_ocean", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
}, 1);

-- Coniferous Forest
cartographer.biomes.add("coniferous_forest", {
    "ctg_mtg_simple_forest",
    "ctg_mtg_colored_forest",
    "ctg_mtg_coniferous_forest",
});
cartographer.biomes.add("coniferous_forest_dunes", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
});
cartographer.biomes.add("coniferous_forest_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
}, nil, 0);
cartographer.biomes.add("coniferous_forest_ocean", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
}, 1);

-- Deciduous Forest
cartographer.biomes.add("deciduous_forest", {
    "ctg_mtg_simple_forest",
    "ctg_mtg_colored_forest",
    "ctg_mtg_deciduous_forest",
});
cartographer.biomes.add("deciduous_forest_shore", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
});
cartographer.biomes.add("deciduous_forest_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
}, nil, 0);
cartographer.biomes.add("deciduous_forest_ocean", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
}, 1);

-- Desert
cartographer.biomes.add("desert", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
    "ctg_mtg_colored_sand",
    "ctg_mtg_desert_sand",
});
cartographer.biomes.add("desert_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
}, nil, 0);
cartographer.biomes.add("desert_ocean", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
}, 1);

-- Sandstone Desert
cartographer.biomes.add("sandstone_desert", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
});
cartographer.biomes.add("sandstone_desert_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
}, nil, 0);
cartographer.biomes.add("sandstone_desert_ocean", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
}, 1);

-- Cold Desert
cartographer.biomes.add("cold_desert", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
    "ctg_mtg_colored_sand",
    "ctg_mtg_silver_sand",
});
cartographer.biomes.add("cold_desert_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
}, nil, 0);
cartographer.biomes.add("cold_desert_ocean", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
}, 1);

-- Savanna
cartographer.biomes.add("savanna", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_land",
    "ctg_mtg_colored_land",
    "ctg_mtg_savanna",
});
cartographer.biomes.add("savanna_shore", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
});
cartographer.biomes.add("savanna_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
}, nil, 0);
cartographer.biomes.add("savanna_ocean", {
    "ctg_mtg_simple_land",
    "ctg_mtg_colored_sand",
}, 1);

-- Rainforest
cartographer.biomes.add("rainforest", {
    "ctg_mtg_simple_forest",
    "ctg_mtg_colored_forest",
    "ctg_mtg_rainforest",
});
cartographer.biomes.add("rainforest_swamp", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
    "ctg_mtg_swamp",
});
cartographer.biomes.add("rainforest_ocean", {
    "ctg_mtg_simple_water",
    "ctg_mtg_colored_water",
});

-- Markers
-- General markers
cartographer.markers.add("ctg_mtg:house", "House", {
    "ctg_mtg_marker_house",
    "ctg_mtg_marker_house_2",
});
cartographer.markers.add("ctg_mtg:skull", "Skull", {
    "ctg_mtg_marker_skull",
});
cartographer.markers.add("ctg_mtg:diamond", "diamond", {
    "ctg_mtg_marker_diamond",
    "ctg_mtg_marker_diamond_2",
});
cartographer.markers.add("ctg_mtg:mese", "mese", {
    "ctg_mtg_marker_mese",
    "ctg_mtg_marker_mese_2",
});
cartographer.markers.add("ctg_mtg:x", "X", {
    "ctg_mtg_marker_x",
    "ctg_mtg_marker_x_2",
});
cartographer.markers.add("ctg_mtg:flag", "Flag", {
    "ctg_mtg_marker_flag",
    "ctg_mtg_marker_flag_2",
});

-- Line drawing markers
cartographer.markers.add("ctg_mtg:line_h", "Line (Horizontal)", {
    "ctg_mtg_marker_line_h",
});
cartographer.markers.add("ctg_mtg:line_v", "Line (Vertical)", {
    "ctg_mtg_marker_line_v",
});
cartographer.markers.add("ctg_mtg:line_c_ne", "Line (North-East Corner)", {
    "ctg_mtg_marker_line_c_ne",
});
cartographer.markers.add("ctg_mtg:line_c_se", "Line (South-East Corner)", {
    "ctg_mtg_marker_line_c_se",
});
cartographer.markers.add("ctg_mtg:line_c_nw", "Line (North-West Corner)", {
    "ctg_mtg_marker_line_c_nw",
});
cartographer.markers.add("ctg_mtg:line_c_sw", "Line (South-West Corner)", {
    "ctg_mtg_marker_line_c_sw",
});
cartographer.markers.add("ctg_mtg:line_t_n", "Line (North T-Intersection)", {
    "ctg_mtg_marker_line_t_n",
});
cartographer.markers.add("ctg_mtg:line_t_s", "Line (South T-Intersection)", {
    "ctg_mtg_marker_line_t_s",
});
cartographer.markers.add("ctg_mtg:line_t_e", "Line (East T-Intersection)", {
    "ctg_mtg_marker_line_t_e",
});
cartographer.markers.add("ctg_mtg:line_t_w", "Line (West T-Intersection)", {
    "ctg_mtg_marker_line_t_w",
});
cartographer.markers.add("ctg_mtg:line_cross", "Line (Crossing)", {
    "ctg_mtg_marker_line_cross",
});

-- Arrow markers
cartographer.markers.add("ctg_mtg:arrow_n", "Arrow (North)", {
    "ctg_mtg_marker_arrow_n",
});
cartographer.markers.add("ctg_mtg:arrow_s", "Arrow (South)", {
    "ctg_mtg_marker_arrow_s",
});
cartographer.markers.add("ctg_mtg:arrow_e", "Arrow (East)", {
    "ctg_mtg_marker_arrow_e",
});
cartographer.markers.add("ctg_mtg:arrow_w", "Arrow (West)", {
    "ctg_mtg_marker_arrow_w",
});
cartographer.markers.add("ctg_mtg:arrow_ne", "Arrow (North-East)", {
    "ctg_mtg_marker_arrow_ne",
});
cartographer.markers.add("ctg_mtg:arrow_se", "Arrow (South-East)", {
    "ctg_mtg_marker_arrow_se",
});
cartographer.markers.add("ctg_mtg:arrow_nw", "Arrow (North-West)", {
    "ctg_mtg_marker_arrow_nw",
});
cartographer.markers.add("ctg_mtg:arrow_sw", "Arrow (South-West)", {
    "ctg_mtg_marker_arrow_sw",
});

-- Materials
cartographer.materials.register_by_name("default:paper", "paper");
cartographer.materials.register_by_name("default:coal_lump", "pigment");
cartographer.materials.register_by_name("default:coalblock", "pigment", 9);
cartographer.materials.register_by_name("dye:black", "pigment");

-- Crafting Recipes
minetest.register_craft({
	output = "cartographer:simple_table",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:stick", "", "group:stick"},
		{"group:stick", "group:stick", "group:stick"},
	}
});
minetest.register_craft({
	output = "cartographer:standard_table",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "cartographer:simple_table", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	}
});
minetest.register_craft({
	output = "cartographer:advanced_table",
	recipe = {
		{"default:mese_crystal_fragment", "default:mese_crystal_fragment", "default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment", "cartographer:simple_table", "default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment", "default:mese_crystal_fragment", "default:mese_crystal_fragment"},
	}
});

-- Skin
for _,skin in pairs(cartographer.skin.table_skins) do
    skin.paper_texture = "default_paper";
    skin.pigment_texture = "dye_black";
end

cartographer.skin.table_skins.advanced_table.background.texture = "ctg_mtg_advanced_table_bg";

-- Overrides
minetest.override_item("cartographer:simple_table", {
    tiles = { "ctg_mtg_simple_table.png" };
});
minetest.override_item("cartographer:standard_table", {
    tiles = { "ctg_mtg_standard_table.png" };
});
minetest.override_item("cartographer:advanced_table", {
    tiles = { "ctg_mtg_advanced_table.png" };
	light_source = 5,
});
