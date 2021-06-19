-- Documentation
local MP = minetest.get_modpath(minetest.get_current_modname())
dofile(MP .. "/documentation.lua")

--message loading functions
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then return {} end
  local Lines = {}
  for line in io.lines(file) do 
    Lines[#Lines + 1] = line
  end
  return Lines
end

local possible_messages = lines_from(MP .. "/messages.txt")

-- function to place on top of water instead of in the water
local function place_on_water(itemstack, placer, pointed_thing)
    -- I kinda copied stuff from core.item_place_node() to make sure it works correctly
    local above_node = minetest.get_node(pointed_thing.above)
    -- check if it can be placed
    if above_node.name ~= "air" or minetest.is_protected(pointed_thing.above, placer:get_player_name())
        then
        return itemstack
    end
    
    -- set rotation
    local placer_pos = placer:get_pos()
    local facedir = {
        x=pointed_thing.above.x-placer_pos.x,
        y=pointed_thing.above.y-placer_pos.y,
        z=pointed_thing.above.z-placer_pos.z,
    }
    local node = {name=itemstack:get_name(), param2=minetest.dir_to_facedir(facedir), param1=0}
    minetest.add_node(pointed_thing.above, node)
    
    local take_item = true
    
    
    -- call registered_on_placenodes
    for _, callback in ipairs(minetest.registered_on_placenodes) do
        local oldnode = minetest.get_node(pointed_thing.above)
        if callback(pointed_thing.above, node, placer, oldnode, itemstack, pointed_thing) then
            take_item = false
        end
    end
    
    -- call after_place_node (used by written_bottle to copy metadata)
    local def = itemstack:get_definition()
    if def.after_place_node then
        if def.after_place_node(pointed_thing.above, placer, itemstack, pointed_thing) then
            take_item = false
        end
    end
    
    if take_item then
        itemstack:take_item()
    end
    return itemstack, false
end

local node_box = {
    type = "fixed",
    fixed = {
        {-3/16, -12/16, -8/16-0.0001, 3/16, -6/16,        1/16},
        {-1/16, -10/16, 1/16,         1/16, -8/16+0.0001, 8/16+0.0001},
    },
}

-- Empty Bottle
minetest.register_node("bottle_message:bottle", {
    description = "Empty Bottle",
    drawtype = "nodebox",
    inventory_image = "message_bottle_empty_weild.png",
    wield_image = "message_bottle_empty_weild.png",
    tiles = {
        "message_bottle_empty.png",
        "message_bottle_empty.png^[transformFY",
        "message_bottle_empty.png^[transformR2700",
        "message_bottle_empty.png^[transformR90",
        "message_bottle_cap.png",
        "message_bottle_empty.png^[transformR270",
    },
    use_texture_alpha = true,
    groups = {cracky = 3, oddly_breakable_by_hand = 3},
    sounds = default.node_sound_glass_defaults(),
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    liquids_pointable = true,
    node_box = node_box,
    node_placement_prediction = "",
    
    on_place = place_on_water,
    on_secondary_use = function(itemstack, user, pointed_thing)
        if not user then return end
        
        playername = user:get_player_name()
        inv = user:get_inventory()
        
        if not inv:contains_item("main", "default:paper") then
            minetest.chat_send_player(playername, "Missing paper!")
        return end
        if not inv:room_for_item("main", "bottle_message:written_bottle") then
            minetest.chat_send_player(playername, "No space in inventory!")
        return end
        
        formspec = "formspec_version[4]"..
        "size[5,5]"..
        "textarea[0.2,0.5;4.6,3.5;message;Write your message:;]"..
        "button_exit[0.2,4;4.6,0.8;save;Finish]"
        
        
        minetest.show_formspec(playername, "bottle_message:write_message", formspec)
        
        return itemstack
    end,
})

-- Recieve formspec produced by empty bottle
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "bottle_message:write_message" or not fields.message then return end
    
    playername = player:get_player_name()
    inv = player:get_inventory()
    
    -- check again just incase
    if not inv:contains_item("main", "default:paper") or
       not inv:contains_item("main", "bottle_message:bottle") or
       not inv:room_for_item("main", "bottle_message:written_bottle") then
        minetest.chat_send_player(playername, "Error!")
    return end
    
    itemstack = ItemStack("bottle_message:written_bottle")
    meta = itemstack:get_meta()
    meta:set_string("bottle_message:author", playername)
    meta:set_string("bottle_message:message", fields.message)
    
    inv:remove_item("main", "default:paper 1")
    inv:remove_item("main", "bottle_message:bottle 1")
    inv:add_item("main", itemstack)
end)


-- Written Bottle
minetest.register_node("bottle_message:written_bottle", {
    description = "Written Bottle",
    drawtype = "nodebox",
    inventory_image = "message_bottle_written_weild.png",
    wield_image = "message_bottle_written_weild.png",
    tiles = {
        "message_bottle_written.png",
        "message_bottle_written.png^[transformFY",
        "message_bottle_written.png^[transformR2700",
        "message_bottle_written.png^[transformR90",
        "message_bottle_cap.png",
        "message_bottle_empty.png^[transformR270",
    },
    use_texture_alpha = true,
    groups = {cracky = 3, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
    sounds = default.node_sound_glass_defaults(),
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    stack_max = 1,
    liquids_pointable = true,
    node_box = node_box,
    -- place on water, not in
    node_placement_prediction = "",
    on_place = place_on_water,
    -- copy metadata to node
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local item_meta = itemstack:get_meta()
        local node_meta = minetest.get_meta(pos)
        
        local author = item_meta:get("bottle_message:author")
        local message = item_meta:get("bottle_message:message")
        
        if author then
            node_meta:set_string("bottle_message:author", author)
        end
        if message then
            node_meta:set_string("bottle_message:message", message)
        end
    end,
    -- copy metadata to item
    preserve_metadata = function(pos, oldnode, node_meta, drops)
        local item_meta = drops[1]:get_meta()
        
        local author = node_meta["bottle_message:author"]
        local message = node_meta["bottle_message:message"]
        
        
        if not author then
            author = "a mysterious traveler"
        end
        if not message then
            message = possible_messages[math.random(#possible_messages)]
        end
        item_meta:set_string("bottle_message:message", message)
        item_meta:set_string("bottle_message:author", author)
    end,
    -- display message
    on_secondary_use = function(itemstack, user, pointed_thing)
        if not user then return end
        
        local meta = itemstack:get_meta()
        
        
        local playername = user:get_player_name()
        local author = meta:get("bottle_message:author") or "Unknown Author"
        local message = meta:get("bottle_message:message") or "Corrupted Message"
        
        local formspec = "formspec_version[4]"..
        "size[8,8]"..
        "textarea[0.2,0.5;7.6,6.5;;Sent by "..author..";".. minetest.formspec_escape(message).."]"..
        "button_exit[0.2,7;7.6,0.8;save;Exit]"
        
        
        minetest.show_formspec(playername, "bottle_message:read_message", formspec)
        
        return itemstack
    end,
})

minetest.register_craft({
    output = "bottle_message:bottle",
    recipe = {
        {"default:glass", "", "default:glass"},
        {"default:glass", "dye:dark_green", "default:glass"},
        {"", "default:glass", ""},
    },
})

minetest.register_craft({
    type = "shapeless",
    output = "default:paper",
    recipe = {"bottle_message:written_bottle"},
    replacements = {{"bottle_message:written_bottle", "bottle_message:bottle"}},
})

generate_type = "bottle_message:written_bottle"

minetest.register_decoration({
    deco_type = "simple",
    place_on = "default:sand",
    spawn_by = "default:water_source",
    num_spawn_by = 2,
    fill_ratio = 0.012,
    decoration = generate_type,
    param2 = 0,
    param2_max = 3,
})

minetest.register_decoration({
    deco_type = "simple",
    place_on = "default:gravel",
    spawn_by = "default:water_source",
    num_spawn_by = 2,
    fill_ratio = 0.012,
    decoration = generate_type,
    param2 = 0,
    param2_max = 3,
})

minetest.register_decoration({
    deco_type = "simple",
    place_on = "default:snow",
    spawn_by = "default:water_source",
    num_spawn_by = 2,
    fill_ratio = 0.012,
    decoration = generate_type,
    param2 = 0,
    param2_max = 3,
})

minetest.register_decoration({
    deco_type = "simple",
    place_on = "default:dirt",
    spawn_by = "default:water_source",
    num_spawn_by = 2,
    fill_ratio = 0.012,
    decoration = generate_type,
    param2 = 0,
    param2_max = 3,
})

minetest.register_abm({
    label = "Moving bottles in water",
    nodenames = {"bottle_message:written_bottle", "bottle_message:bottle"},
    neighbors = {"default:water_source"},
    interval = 4,
    chance = 4,
    action = function(pos, node)
    
        local under_node = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
        local new_pos = vector.add(vector.add(pos, {x=math.random(-1, 1), y=0, z=math.random(-1, 1)}), minetest.facedir_to_dir(node.param2))
        local new_node = minetest.get_node(new_pos)
        local new_under_node = minetest.get_node({x=new_pos.x, y=new_pos.y-1, z=new_pos.z})
        local new_under_def = minetest.registered_nodes[new_under_node.name]
        if under_node.name == "default:water_source" and new_node.name == "air" and
           (new_under_node.name == "default:water_source" or (not new_under_def.drawtype) or new_under_def.drawtype == "normal") then
            -- move
            minetest.set_node(new_pos, {name=node.name, param2=node.param2})
            
            local old_meta = minetest.get_meta(pos)
            local new_meta = minetest.get_meta(new_pos)
            
            local author = old_meta:get("bottle_message:author")
            local message = old_meta:get("bottle_message:message")
            
            if author then
                new_meta:set_string("bottle_message:author", author)
            end
            if message then
                new_meta:set_string("bottle_message:message", message)
            end
            
            minetest.set_node(pos, {name="air"})
        end
    end,
})
