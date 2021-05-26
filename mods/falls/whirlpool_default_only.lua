local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP..'/intllib.lua')

--
--Whirlpool Machine:    used to create turbulent water, allowing all other nodes to be crafted
--                      and runs on Mese Fragments

local function active_formspec(spin_percent)
	local formspec =
		'size[8,9]'..
        default.gui_bg..
        default.gui_bg_img..
        default.gui_slots..
        'image_button[3.5,1;1.5,2;lever_flip.png;lever;]'..
        'list[current_name;src;2.25,0.5;1,1;]'..
        'image[2.25,0.5;1,1;bucket_water_transparent.png]'..
        'image[2.25,1.5;1,1;whirlpool_machine_side.png^[multiply:#cccccc^[lowpart:'..
            math.max(10,100-spin_percent)..':whirlpool_machine_side_overlay.png]'..
        'list[current_name;fuel;2.25,2.5;1,1;]'..
        'image[2.25,2.5;1,1;mese_fragment_transparent.png]'..
        'list[current_name;dst;5.25,1.5;1,1;]'..
        'list[current_player;main;0,4.25;8,1;]'..
        'list[current_player;main;0,5.5;8,3;8]'..		
        'listring[current_name;dst]'..
        'listring[current_player;main]'..
        'listring[current_name;src]'..
        'listring[current_player;main]'..
        'listring[current_name;fuel]'..
        'listring[current_player;main]'
	return formspec
end

local inactive_formspec =
	'size[8,9]'..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	'label[3.75,0.6;Initiate]'..
	'image_button[3.5,1;1.5,2;lever.png;lever;]'..
	'list[current_name;src;2.25,0.5;1,1;]'..
	'image[2.25,0.5;1,1;bucket_water_transparent.png]'..
	'image[2.25,1.5;1,1;whirlpool_machine_side.png^[multiply:#cccccc]'..
	'list[current_name;fuel;2.25,2.5;1,1;]'..
	'image[2.25,2.5;1,1;mese_fragment_transparent.png]'..
	'list[current_name;dst;5.25,1.5;1,1;]'..
	'list[current_player;main;0,4.25;8,1;]'..
	'list[current_player;main;0,5.5;8,3;8]'..		
	'listring[current_name;dst]'..
	'listring[current_player;main]'..
	'listring[current_name;src]'..
	'listring[current_player;main]'..
	'listring[current_name;fuel]'..
	'listring[current_player;main]'


-- Node callback functions are the same for active and inactive whirlpool machines
-- Code originally modified from furnace.lua in default


local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv  = meta:get_inventory()
	return inv:is_empty('fuel') and inv:is_empty('dst') and inv:is_empty('src')
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()
	if listname == 'fuel' then
		if (stack:get_name() == 'default:mese_crystal_fragment') and inv:is_empty('fuel') then
			return 1
		else
			return 0
		end
	elseif listname == 'src' then
		if(stack:get_name() == 'bucket:bucket_water') and inv:is_empty('src') then
			return 1
		elseif (stack:get_name() == 'bucket:bucket_lava') and inv:is_empty('src') then
			return 1
        else
			return 0
		end
	elseif listname == 'dst' then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta  = minetest.get_meta(pos)
	local inv   = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end


--This function is called with On_timer for Whirlpool_machine_active node
local function whirlpool_cycle_timer(pos)
	local meta  = minetest.get_meta(pos)
	local inv   = meta:get_inventory()
	local count = meta:get_int('countdown')
	if(count > 0) then
		meta:set_string('formspec', active_formspec(count / 10 * 100))
		meta:set_int('countdown', count - 1)
		return true
	else
		meta:set_string('formspec', inactive_formspec)
		swap_node(pos, 'falls:whirlpool_machine')
        local set = meta:get_string("whirl_set")
        if set == "water" then
            inv:set_stack('dst', 1, 'falls:bucket_turbulent')
        else
            inv:set_stack('dst', 1, 'falls:lava_turbulent')
        end
		return false
	end	
end

--
-- Node definitions
--

-- Inactive Whirpool Machine
minetest.register_node('falls:whirlpool_machine', {
	description = S('Whirlpool Machine'),
	tiles = {
        'whirlpool_machine_top.png',
        'whirlpool_machine_top.png',
        'whirlpool_machine_side.png',
        'whirlpool_machine_side.png',
        'whirlpool_machine_back.png',
        'whirlpool_machine_front.png',
    },
    use_texture_alpha = true,
	paramtype2        = 'facedir',
	is_ground_content = false,
	groups            = {cracky=2},
	drop              = 'falls:whirlpool_machine',
	sounds            = default.node_sound_stone_defaults(),

	can_dig = can_dig,

    on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string('formspec', inactive_formspec)
		local inv = meta:get_inventory()
		inv:set_size('src' , 1)
		inv:set_size('fuel', 1)
		inv:set_size('dst' , 1)
	end,
	
	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		local meta = minetest.get_meta(pos)
		local inv  = meta:get_inventory()
        if(fields.lever) then 
			if(inv:contains_item('src', 'bucket:bucket_water') and inv:contains_item('fuel', 'default:mese_crystal_fragment')) and inv:is_empty('dst') then
			    meta:set_int('countdown', 10) --for the node timer countdown
			    minetest.get_node_timer(pos):start(1.0)
			    inv:set_stack('src' , 1, '')
			    inv:set_stack('fuel', 1, '')
			    swap_node(pos, 'falls:whirlpool_machine_active')
			    meta:set_string('formspec', active_formspec(100))
                meta:set_string("whirl_set", "water")
				return 
			elseif(inv:contains_item('src', 'bucket:bucket_lava') and inv:contains_item('fuel', 'default:mese_crystal_fragment')) and inv:is_empty('dst') then
			    meta:set_int('countdown', 10) --for the node timer countdown
			    minetest.get_node_timer(pos):start(1.0)
			    inv:set_stack('src' , 1, '')
			    inv:set_stack('fuel', 1, '')
			    swap_node(pos, 'falls:whirlpool_machine_active')
			    meta:set_string('formspec', active_formspec(100))
                meta:set_string("whirl_set", "lava")
				return 
            end
		end    
    end,
    
    allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
})

minetest.register_node('falls:whirlpool_machine_active', {
	description = S('Whirlpool Machine Active'),
	
	tiles = {
        'whirlpool_machine_top.png',
        'whirlpool_machine_top.png',
        'whirlpool_machine_side.png',
        'whirlpool_machine_side.png',
        {   image = 'whirlpool_machine_back_activated_animated.png',
            animation = {
                type     = 'vertical_frames',
                aspect_w = 16,
                aspect_h = 16,
                length   = 1.5
            }
        },
        {   image = 'whirlpool_machine_front_activated_animated.png',
            animation = {
                type     = 'vertical_frames',
                aspect_w = 16,
                aspect_h = 16,
                length   = 1.5
            }
        },
    },
    use_texture_alpha = true,
	paramtype2        = 'facedir',
	light_source      = 8,
	groups            = {not_in_creative_inventory=1},
	is_ground_content = false,
	drop              = 'falls:whirlpool_machine',
	sounds            = default.node_sound_stone_defaults(),
	on_timer          = whirlpool_cycle_timer,	
	
	--overwrite these functions while active
	allow_metadata_inventory_put = function()	return 0  end,
	allow_metadata_inventory_move = function()	return 0  end,
	allow_metadata_inventory_take = function()	return 0  end,
})

--
-- Crafting
--

minetest.register_craft({
	output = 'falls:whirlpool_machine',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:tin_ingot', 'default:glass', 'default:tin_ingot'},
		{'default:tin_ingot', 'default:diamond', 'default:tin_ingot'}
	}
})
