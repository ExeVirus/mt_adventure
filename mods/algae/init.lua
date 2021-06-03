-- Translation support
local S = minetest.get_translator("algae")

--
-- Algae
--

-----Load documentation via doc_helper------------------------
local MP = minetest.get_modpath(minetest.get_current_modname())
local docpath = MP .. DIR_DELIM .. "doc"
doc.add_category("_aglae",
{
	name = "_algae",
	description = "Algae Mod Documentation",
	build_formspec = doc.entry_builders.text_and_square_gallery,
})
doc.build_entries(docpath, "_algae")

------Registrations--------

local algae_thin_def = {
	description = S("Thin algae"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"algae_thin_1.png", "algae_thin_1.png"},
	inventory_image = "algae_thin_1.png",
	wield_image = "algae_thin_1.png",
    --use_texture_alpha = true,
	liquids_pointable = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	groups = {snappy = 3, flower = 1, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -31 / 64, -0.5, 0.5, -15 / 32, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-7 / 16, -0.5, -7 / 16, 7 / 16, -15 / 32, 7 / 16}
	},

	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		local node = minetest.get_node(pointed_thing.under)
		local def = minetest.registered_nodes[node.name]

		if def and def.on_rightclick then
			return def.on_rightclick(pointed_thing.under, node, placer, itemstack,
					pointed_thing)
		end

		if def and def.liquidtype == "source" and
				minetest.get_item_group(node.name, "water") > 0 then
			local player_name = placer and placer:get_player_name() or ""
			if not minetest.is_protected(pos, player_name) then
				minetest.set_node(pos, {name = "algae:algae_thin",
					param2 = math.random(0, 3)})
				if not (creative and creative.is_enabled_for
						and creative.is_enabled_for(player_name)) then
					itemstack:take_item()
				end
			else
				minetest.chat_send_player(player_name, S("Node is protected."))
				minetest.record_protection_violation(pos, player_name)
			end
		end

		return itemstack
	end
}

local algae_medium_def = {
	description = S("Medium algae"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"algae_medium_1.png", "algae_medium_1.png"},
	inventory_image = "algae_medium_1.png",
	wield_image = "algae_medium_1.png",
    --use_texture_alpha = true,
	liquids_pointable = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	groups = {snappy = 3, flower = 1, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -31 / 64, -0.5, 0.5, -15 / 32, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-7 / 16, -0.5, -7 / 16, 7 / 16, -15 / 32, 7 / 16}
	},

	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		local node = minetest.get_node(pointed_thing.under)
		local def = minetest.registered_nodes[node.name]

		if def and def.on_rightclick then
			return def.on_rightclick(pointed_thing.under, node, placer, itemstack,
					pointed_thing)
		end

		if def and def.liquidtype == "source" and
				minetest.get_item_group(node.name, "water") > 0 then
			local player_name = placer and placer:get_player_name() or ""
			if not minetest.is_protected(pos, player_name) then
				minetest.set_node(pos, {name = "algae:algae_medium",
					param2 = math.random(0, 3)})
				if not (creative and creative.is_enabled_for
						and creative.is_enabled_for(player_name)) then
					itemstack:take_item()
				end
			else
				minetest.chat_send_player(player_name, S("Node is protected."))
				minetest.record_protection_violation(pos, player_name)
			end
		end

		return itemstack
	end
}

local algae_thick_def = {
	description = S("Thick algae"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"algae_thick_1.png", "algae_thick_1.png"},
	inventory_image = "algae_thick_1.png",
	wield_image = "algae_thick_1.png",
    --use_texture_alpha = true,
	liquids_pointable = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	groups = {snappy = 3, flower = 1, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
	node_placement_prediction = "",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -31 / 64, -0.5, 0.5, -15 / 32, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-7 / 16, -0.5, -7 / 16, 7 / 16, -15 / 32, 7 / 16}
	},

	on_place = function(itemstack, placer, pointed_thing)
        if placer == nil then
            minetest.log("decorations have no placer")
        end
		local pos = pointed_thing.above
		local node = minetest.get_node(pointed_thing.under)
		local def = minetest.registered_nodes[node.name]

		if def and def.on_rightclick then
			return def.on_rightclick(pointed_thing.under, node, placer, itemstack,
					pointed_thing)
		end

		if def and def.liquidtype == "source" and
				minetest.get_item_group(node.name, "water") > 0 then
			local player_name = placer and placer:get_player_name() or ""
			if not minetest.is_protected(pos, player_name) then
				minetest.set_node(pos, {name = "algae:algae_thick",
					param2 = math.random(0, 3)})
				if not (creative and creative.is_enabled_for
						and creative.is_enabled_for(player_name)) then
					itemstack:take_item()
				end
			else
				minetest.chat_send_player(player_name, S("Node is protected."))
				minetest.record_protection_violation(pos, player_name)
			end
		end

		return itemstack
	end
}




minetest.register_node("algae:algae_thin", algae_thin_def)
minetest.register_node("algae:algae_medium", algae_medium_def)
minetest.register_node("algae:algae_thick", algae_thick_def)



---
--- Mapgen for algae
---

minetest.register_biome({
		name = "deciduous_forest_oceansurface",
		y_max = 5,
		y_min = -5,
		heat_point = 60,
		humidity_point = 68,
	})

minetest.register_decoration({
		name = "algae_thick1",
		deco_type = "simple",
		place_on = {"default:dirt"},
        spawn_by = {"default:dirt_with_grass"},
        num_spawn_by = 3,        
		sidelen = 8,
		fill_ratio = 0.7,
		biomes = {"rainforest_swamp", "savanna_shore", "deciduous_forest_shore"},
		y_max = 0,
		y_min = 0,
		decoration = "algae:algae_thick",
		param2 = 0,
		param2_max = 3,
		place_offset_y = 1,
})

minetest.register_decoration({
		name = "algae_thick_rainforest",
		deco_type = "simple",
		place_on = {"default:water_source"},
        spawn_by = {"default:papyrus"},
        num_spawn_by = 3,        
		sidelen = 16,
		fill_ratio = 0.7,
		biomes = {"rainforest_swamp", "savanna_shore", "deciduous_forest_shore"},
		y_max = 1,
		y_min = 1,
		decoration = "algae:algae_thick",
		param2 = 0,
		param2_max = 3,
		place_offset_y = 0,
        flags = "liquid_surface",
})


minetest.register_decoration({
		name = "algae_medium",
		deco_type = "simple",
		place_on = {"default:water_source"},
		sidelen = 16,
		fill_ratio = 2,
        spawn_by = {"algae:algae_thick"},
        num_spawn_by = 1,   
		y_max = 1,
		y_min = 1,
        param2 = 0,
		param2_max = 3,
		decoration = "algae:algae_medium",
		flags = "liquid_surface",
})

minetest.register_decoration({
		name = "algae_thick2",
		deco_type = "simple",
		place_on = {"default:water_source"},
		sidelen = 16,
		fill_ratio = 0.7,
        spawn_by = {"algae:algae_medium"},
        num_spawn_by = 2,   
		y_max = 1,
		y_min = 1,
        param2 = 0,
		param2_max = 3,
		decoration = "algae:algae_thick",
		flags = "liquid_surface",
})

minetest.register_decoration({
		name = "algae_thin",
		deco_type = "simple",
		place_on = {"default:water_source"},
		sidelen = 16,
		fill_ratio = 3,
        spawn_by = {"algae:algae_medium"},
        num_spawn_by = 1,   
		y_max = 1,
		y_min = 1,
        param2 = 0,
		param2_max = 3,
		decoration = "algae:algae_thin",
		flags = "liquid_surface",
})

minetest.register_decoration({
		name = "algae_thin2",
		deco_type = "simple",
		place_on = {"default:water_source"},
		sidelen = 16,
		fill_ratio = 3,
        spawn_by = {"algae:algae_thick"},
        num_spawn_by = 1,   
		y_max = 1,
		y_min = 1,
        param2 = 0,
		param2_max = 3,
		decoration = "algae:algae_thin",
		flags = "liquid_surface",
})


