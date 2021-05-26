-- Arguments
-- chunk: The chunk coordinate conversion API
-- gui: The GUI API
-- skin: The GUI skin
-- audio: The audio playback API
-- maps: The map API
-- markers: The marker API
-- map_formspec: The map display API
-- settings: The mod settings
local chunk, gui, skin, audio, maps, markers, map_formspec, settings = ...;

-- The list of players looking at maps, and the map IDs that they're looking at
local player_maps = {};

-- Generate formspec data for the map marker editor
--
-- selected_id: The id of the currently selected marker, or nil if no marker is
--              selected
-- detail: The map's detail level
-- page: The current page
--
-- Returns a formspec string for use in containers
local function marker_formspec(selected_id, detail, page)
    local marker_lookup = markers.get_all();

    local formspec = {
        gui.button {
            x = 0.125,
            y = 0.125,

            w = 1.125,
            h = 0.5,

            id = "clear_marker",
            text = "Erase",
            tooltip = "Remove the selected marker",
        },

        gui.label {
            x = 1.375,
            y = 3.5,

            text = string.format("%d / %d", page, math.ceil(#marker_lookup / 20)),
        },
    };

    if selected_id then
        table.insert(formspec, gui.style {
            selector = "marker-" .. selected_id,
            properties = {
                bgimg = skin.marker_button.selected_texture .. ".png",
                bgimg_hovered = skin.marker_button.selected_texture .. ".png",
                bgimg_pressed = skin.marker_button.selected_texture .. ".png",
            }
        });
    end

    local starting_id = ((page - 1) * 20) + 1;
    for i = starting_id,math.min(#marker_lookup,starting_id + 19),1 do
        local marker = marker_lookup[i];
        table.insert(formspec, gui.image_button {
            x = (i - starting_id) % 5 * 0.625 + 0.125,
            y = math.floor((i - starting_id) / 5) * 0.625 + 0.75,

            w = 0.5,
            h = 0.5,

            image = marker.textures[math.min(detail, #marker.textures)] .. ".png",
            id = "marker-" .. marker.id,
            tooltip = marker.name,
        });
    end

    if page > 1 then
        table.insert(formspec, gui.button {
            x = 0.125,
            y = 3.25,

            w = 0.5,
            h = 0.5,

            id = "prev_button",
            text = "<"
        });
    end

    if starting_id + 19 < #marker_lookup then
        table.insert(formspec, gui.button {
            x = 2.625,
            y = 3.25,

            w = 0.5,
            h = 0.5,

            id = "next_button",
            text = ">"
        });
    end

    return table.concat(formspec);
end

-- Show a map to a player
--
-- map: The map to display
-- player_x: The X position (in world coordinates)
-- player_z: The Z position (in world coordinates)
-- player_name: The name of the player to show to
-- height_mode: Whether or not to display the map in height mode
-- (Optional) marker_page: The current page that the marker editor is on
local function show_map_formspec(map, player_x, player_z, player_name, height_mode, marker_page)
    map:fill_local(player_x, player_z);

    player_maps[player_name] = {
        id = map.id,
        page = marker_page or 1,
        height_mode = height_mode,
    };

    player_x, player_z = map:to_coordinates(player_x, player_z, true);
    local formspec, formspec_width, _ = map_formspec.from_map(map, player_x, player_z, height_mode);
    local height_button_texture;
    if height_mode then
        height_button_texture = skin.height_button_texture .. ".png";
    else
        height_button_texture = skin.flat_button_texture .. ".png";
    end

    local data = {
        gui.style_type {
            selector = "button,image_button,label",
            properties = {
                noclip = true,
            }
        },
        gui.style_type {
            selector = "button,image_button",
            properties = {
                border = false,
                bgimg = skin.marker_button.texture .. ".png",
                bgimg_hovered = skin.marker_button.hovered_texture .. ".png",
                bgimg_pressed = skin.marker_button.pressed_texture .. ".png",
                bgimg_middle = skin.marker_button.radius,
                textcolor = skin.marker_button.font_color,
            },
        },
        gui.container {
            x = formspec_width - 0.01,
            y = 0.125,
            w = 0.75,
            h = 0.75,
            bg = skin.marker_bg,

            gui.image_button {
                x = 0.125,
                y = 0.125,
                w = 0.5,
                h = 0.5,

                id = "height_button",
                image = height_button_texture,
                tooltip = "Toggle height view",
            }
        },
    };

    if markers.count() > 0 then
        table.insert(data, gui.container {
                    x = formspec_width - 0.01,
                    y = 1,
                    w = 3.25,
                    h = 3.875,
                    bg = skin.marker_bg,

                    marker_formspec(map:get_marker(player_x, player_z), map.detail, marker_page or 1)});
    end

    formspec = formspec .. table.concat(data);
    minetest.show_formspec(player_name, "cartographer:map", formspec);
end

-- Get the description text for a map ID and dimensions
--
-- id: The map ID
-- from_x: The x coordinate of the top-left corner of the map, in map coordinates
-- from_z: The z coordinate of the top-left corner of the map, in map coordinates
-- w: The width, in world coordinates
-- h: The height, in world coordinates
--
-- returns a string containing the description
local function map_description(id, from_x, from_z, w, h)
    return string.format("Map #%d\n[%d,%d] - [%d,%d]",
                         id,
                         chunk.from(from_x), chunk.from(from_z),
                         chunk.from(from_x + w + 1), chunk.from(from_z + h + 1));
end

-- Create a map from metadata, and assign the ID to the metadata
--
-- meta: A metadata object containing the map ID
-- player_x: The X position (in map coordinates)
-- player_z: The Z position (in map coordinates)
--
-- Returns the id of the new map
local function map_from_meta(meta, player_x, player_z)
    local size = meta:get_int("cartographer:size");
    if size == 0 then
        size = settings.default_size;
    end

    local detail = meta:get_int("cartographer:detail");
    if detail == 0 then
        detail = 1;
    end

    local scale = meta:get_int("cartographer:scale");
    if scale == 0 then
        scale = 1;
    end

    local total_size = size * scale;

    local map_x = math.floor(player_x / total_size) * total_size;
    local map_y = math.floor(player_z / total_size) * total_size;

    local id = maps.create(map_x, map_y, size, size, false, detail, scale);

    meta:set_int("cartographer:map_id", id);
    meta:set_string("description", map_description(id, map_x, map_y, total_size, total_size));

    return id;
end

-- Show a map to a player from metadata, creating it if necessary
--
-- meta: A metadata object containing the map ID
-- player: The player to show the map to
local function show_map_meta(meta, player)
    local pos = player:get_pos();
    local player_x = chunk.to(pos.x);
    local player_z = chunk.to(pos.z);

    local id = meta:get_int("cartographer:map_id");
    if id == 0 then
        id = map_from_meta(meta, player_x, player_z);
    end

    local map = maps.get(id);
    if map then
        show_map_formspec(map, pos.x, pos.z, player:get_player_name(), true);
    end
end

-- Called when a player sends input to the server from a formspec
-- This callback handles player input in the map formspec, for editing markers
--
-- player: The player who sent the input
-- name: The formspec name
-- fields: A table containing the input
minetest.register_on_player_receive_fields(function(player, name, fields)
    if name == "cartographer:map" then
        local data = player_maps[player:get_player_name()];
        if not data then
            return;
        end

        local map = maps.get(data.id);
        if not map then
            return;
        end

        for k,_ in pairs(fields) do
            local marker = k:match("marker%-(.+)");
            local pos = player:get_pos();
            if marker or k == "clear_marker" then
                local player_x, player_z = map:to_coordinates(pos.x, pos.z, true);
                map:set_marker(player_x, player_z, marker);

                audio.play_feedback("cartographer_write", player);
                show_map_formspec(map, pos.x, pos.z, player:get_player_name(), data.page);
            elseif k == "prev_button" then
                local new_page = math.max(data.page - 1, 1);
                show_map_formspec(map, pos.x, pos.z, player:get_player_name(), data.height_mode, new_page);
            elseif k == "next_button" then
                local new_page = math.min(data.page + 1, math.ceil(markers.count() / 20));
                show_map_formspec(map, pos.x, pos.z, player:get_player_name(), data.height_mode, new_page);
            elseif k == "height_button" then
                show_map_formspec(map, pos.x, pos.z, player:get_player_name(), not data.height_mode, data.page);
            elseif k == "quit" then
                player_maps[player:get_player_name()] = nil;
            end
        end
    end
end);

-- The map item/node
minetest.register_node("cartographer:map", {
    description = "Map",
    inventory_image = "cartographer_map.png",
    wield_image = "cartographer_map.png",
    tiles = { "cartographer_map.png" },
    drawtype = "signlike",
    paramtype = "light",
    paramtype2 = "wallmounted",
    stack_max = 1,
    sunlight_propagates = true,
    walkable = false,
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, -7 / 16, 0.5},
        },
    },

    groups = {
        attached_node = 1,
        dig_immediate = 3,
    },

    -- Called when this node is placed in the world. Copies map data from the
    -- item to the node.
    -- pos: The position of the node
    -- stack: The itemstack that was placed
    after_place_node = function(pos, _, stack, _)
        local meta = stack:get_meta():to_table();
        local node_meta = minetest.get_meta(pos);
        node_meta:from_table(meta);

        -- Consume the item after placing
        return false;
    end,

    -- Called when this node is dug. Turns the node into an item.
    -- pos: The position of the node
    on_dig = function(pos, _, _)
        local node_meta = minetest.get_meta(pos):to_table();
        local item = ItemStack("cartographer:map");
        item:get_meta():from_table(node_meta);

        if minetest.add_item(pos, item) then
            minetest.remove_node(pos);
        end
    end,

    -- Called when a player right-clicks this node. Display's the map's
    -- content, creating it if it doesn't exist.
    -- pos: The position of the node
    -- player: The player that right-clicked the node
    on_rightclick = function(pos, _, player)
        audio.play_feedback("cartographer_open_map", player);
        show_map_meta(minetest.get_meta(pos), player);
    end,

    -- Called when a player uses this item. Displays the map's content,
    -- creating it if it doesn't exist.
    -- stack: The itemstack
    -- player: The player that used the item
    on_use = function(stack, player)
        audio.play_feedback("cartographer_open_map", player);
        show_map_meta(stack:get_meta(), player);
        return stack;
    end,

    -- Called when a node is about to be turned into an item. Copies all
    -- metadata into any items matching this node's name.
    -- oldnode: The old node's data
    -- oldmeta: A table containing the old node's metadata
    -- drops: A table containing the new items
    preserve_metadata = function(_, oldnode, oldmeta, drops)
        for _,item in ipairs(drops) do
            if item:get_name() == oldnode.name then
                item:get_meta():from_table({fields=oldmeta});
            end
        end
    end,
});

-- Create an empty map item with the given parameters
--
-- size: The size of the map
-- detail: The detail level of the map
-- scale: The scaling factor of the map
--
-- Returns an ItemStack
local function create_map_item(size, detail, scale)
    local map = ItemStack("cartographer:map");
    local meta = map:get_meta();
    meta:set_int("cartographer:size", size);
    meta:set_int("cartographer:detail", detail);
    meta:set_int("cartographer:scale", scale);
    meta:set_string("description", "Empty Map\nUse to set the initial location");

    return map;
end

-- Create a copy of the given map
--
-- stack: An itemstack containing a map
--
-- Returns a new ItemStack with the copied map
local function copy_map_item(stack)
    local meta = stack:get_meta();

    local size = meta:get_int("cartographer:size");
    local detail = meta:get_int("cartographer:detail");
    local scale = meta:get_int("cartographer:scale");

    local copy = create_map_item(size, detail, scale);
    local copy_meta = copy:get_meta();

    local id = meta:get_int("cartographer:map_id");
    if id > 0 then
        local src = maps.get(id);

        local new_id = maps.create(src.x, src.z, src.w, src.h, false, src.detail, src.scale);
        local dest = maps.get(new_id);
        for k,v in pairs(src.fill) do
            dest.fill[k] = table.copy(v);
        end
        for k,v in pairs(src.markers) do
            dest.markers[k] = table.copy(v);
        end

        copy_meta:set_int("cartographer:map_id", new_id);
        copy_meta:set_string("description", map_description(new_id,
                                                            dest.x, dest.z,
                                                            dest.w * dest.scale, dest.h * dest.scale));
    end

    return copy;
end

-- Resize the given map item
--
-- meta: A metadata object containing the map data
-- size: The new size
local function resize_map_item(meta, size)
    local old_size = meta:get_int("cartographer:size");

    if old_size >= size then
        return;
    end

    meta:set_int("cartographer:size", size);

    local id = meta:get_int("cartographer:map_id");
    if id > 0 then
        local map = maps.get(id);
        map:resize(size, size);

        meta:set_string("description", map_description(id, map.x, map.z, map.w * map.scale, map.h * map.scale));
    end
end

-- Change the scale of the given map item
--
-- meta: A metadata object containing the map data
-- scale: The new scale
local function rescale_map_item(meta, scale)
    local old_scale = meta:get_int("cartographer:scale");

    if old_scale >= scale then
        return;
    end

    meta:set_int("cartographer:scale", scale);

    local id = meta:get_int("cartographer:map_id");
    if id > 0 then
        local map = maps.get(id);
        map:rescale(scale);
        meta:set_string("description", map_description(id, map.x, map.z, map.w * map.scale, map.h * map.scale));
    end
end

return {
    create = create_map_item,
    copy = copy_map_item,
    resize = resize_map_item,
    rescale = rescale_map_item,
};
