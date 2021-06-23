-- Arguments
-- gui: The GUI API
-- gui_skin: The GUI skin
-- audio: The audio playback API
-- maps: The map API
-- materials: The material API
-- map_item: The map item API
-- settings: The mod settings
local gui, gui_skin, audio, maps, materials, map_item, settings = ...;

local SCALE_SMALL = 1;
local SCALE_MEDIUM = 2;
local SCALE_LARGE = 4;
local SCALE_HUGE = 8;
--FORMSPEC SCALING
local TABLE_WIDTH = 10;
local TABLE_HEIGHT = 10;

-- Get the material cost for the given map scale and detail level
--
-- scale: The map scale
-- detail: The detail level
--
-- Returns a table with material costs
local function get_material_cost(scale, detail)
    local paper = scale * 4;
    local pigment = detail * 5;

    if scale == SCALE_SMALL then
        pigment = pigment + 5;
    elseif scale == SCALE_MEDIUM then
        pigment = pigment + 10;
    elseif scale == SCALE_LARGE then
        pigment = pigment + 15;
    elseif scale == SCALE_HUGE then
        pigment = pigment + 20;
    end

    return {
        paper = math.max(paper, 0),
        pigment = math.max(pigment, 0),
    };
end

-- Get the material cost of the craft settings from the given table metadata
--
-- meta: The metadata to read
--
-- Returns a table with the material costs, and a boolean indicating if the
-- costs were positive or negative before clamping.
local function get_craft_material_cost(meta)
    local cost = get_material_cost(meta:get_int("scale") or SCALE_SMALL, meta:get_int("detail") or 0);
    local stack = meta:get_inventory():get_stack("output", 1);
    local is_positive = true;

    if stack:get_name() == "cartographer:map" then
        local smeta = stack:get_meta();
        local sub_cost = get_material_cost(smeta:get_int("cartographer:scale") or SCALE_SMALL,
                                          (smeta:get_int("cartographer:detail") or 1) - 1);
        is_positive = cost.paper >= sub_cost.paper and cost.pigment >= sub_cost.pigment;
        cost.paper = math.max(cost.paper - sub_cost.paper, 0);
        cost.pigment = math.max(cost.pigment - sub_cost.pigment, 0);
    end

    return cost, is_positive;
end

-- Check if the given table metadata has enough materials to cover the given
-- cost table.
--
-- cost: A table of material costs
-- meta: The metadata
--
-- Returns true if the table's materials can cover the cost
local function can_afford(cost, meta)
    return cost.paper + cost.pigment > 0
       and cost.paper <= meta:get_int("paper")
       and cost.pigment <= meta:get_int("pigment");
end

-- Get the material cost of the copy settings from the given table metadata
--
-- meta: The metadata to read
--
-- Returns a table with the material costs
local function get_copy_material_cost(meta)
    local inv = meta:get_inventory();
    local in_stack = inv:get_stack("copy_input", 1);
    local out_stack = inv:get_stack("copy_output", 1);


    if out_stack:is_empty() and in_stack:get_name() == "cartographer:map" then
        local smeta = in_stack:get_meta();
        local scale = smeta:get_int("cartographer:scale") or SCALE_SMALL;
        local detail = smeta:get_int("cartographer:detail") or 1;

        return get_material_cost(scale, detail - 1);
    end

    return {
        paper = 0,
        pigment = 0,
    };
end

local fs = {};

-- Draw a 1px thick horizontal separator formspec element
--
-- y: The y position of the separator
-- skin: A 9-slice background skin table
--
-- Returns a formspec string
function fs.separator(y, skin)
    return gui.bg9 {
        x = 0.1,
        y = y,
        w = TABLE_WIDTH,
        h = 0.01,

        skin = skin,
    };
end

-- Draw all the essential formspec data (size, background, styles, tabs)
--
-- w: The width of the formspec
-- h: The height of the formspec
-- rank: An into defining the 'rank' of the table being displayed
-- tab: An int defining the index of the selected tab
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.header(w, h, rank, tab, skin)
    local data = {
        gui.formspec {
            w = w,
            h = h,

            bg = skin.background,
        },
        gui.bg9 {
            x = TABLE_WIDTH/40,
            y = TABLE_HEIGHT/40,

            w = w - TABLE_WIDTH/20,
            h = h - TABLE_HEIGHT/20,

            skin = skin.inner_background,
        },

        gui.style_type {
            selector = "button",
            properties = {
                noclip = true,
                border = false,

                bgimg = skin.tab.texture .. ".png",
                bgimg_hovered = skin.tab.hovered_texture .. ".png",
                bgimg_pressed = skin.tab.pressed_texture .. ".png",
                bgimg_middle = skin.tab.radius,
                textcolor = skin.tab.font_color,
            }
        },
        gui.style {
            selector = "tab" .. tostring(tab),
            properties = {
                bgimg = skin.tab.selected_texture .. ".png",
                bgimg_hovered = skin.tab.selected_texture .. ".png",
                bgimg_pressed = skin.tab.selected_texture .. ".png",
            }
        },

        gui.button {
            x = 0.25,
            y = -TABLE_HEIGHT/20,

            w = TABLE_WIDTH/4,
            h = TABLE_HEIGHT/10,

            id = "tab1",

            text = "Materials"
        },
        gui.button {
            x = 0.25+TABLE_WIDTH/4,
            y = -TABLE_HEIGHT/20,

            w = TABLE_WIDTH/4,
            h = TABLE_HEIGHT/10,

            id = "tab2",

            text = "Create Map"
        },
    };

    if rank >= 2 then
        table.insert(data, gui.button {
            x = 0.25 + TABLE_WIDTH/2,
            y = -TABLE_HEIGHT/20,

            w = TABLE_WIDTH/4,
            h = TABLE_HEIGHT/10,

            id = "tab3",

            text = "Copy Map"
        });
    end

    table.insert(data, gui.style_type {
        selector = "button",
        properties = {
            bgimg = skin.button.texture .. ".png",
            bgimg_hovered = skin.button.hovered_texture .. ".png",
            bgimg_pressed = skin.button.pressed_texture .. ".png",
            bgimg_middle = skin.button.radius,

            textcolor = skin.button.font_color,
        },
    });
    table.insert(data, gui.style {
        selector = "disabled_button",
        properties = {
            bgimg = "",
            bgimg_hovered = "",
            bgimg_pressed = "",

            textcolor = skin.button.disabled_font_color,
        },
    });

    return table.concat(data);
end

-- Draw material counters from a table's metadata
--
-- x: The x position of the labels
-- y: The y position of the labels
-- meta: A metadata object containing the material quantities
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.materials(x, y, meta, skin)
    return gui.container {
        x = x,
        y = y,

        gui.bg9 {
            x = TABLE_WIDTH/80,
            y = TABLE_HEIGHT/80,

            w = TABLE_WIDTH/20,
            h = TABLE_HEIGHT/20,

            skin = skin.label,
        },
        gui.image {
            x = TABLE_WIDTH/80,
            y = TABLE_HEIGHT/80,

            w = TABLE_WIDTH/20,
            h = TABLE_WIDTH/20,

            image = skin.paper_texture .. ".png",
        },
        gui.label {
            x = TABLE_WIDTH/80+TABLE_WIDTH/20,
            y = TABLE_HEIGHT/20,

            textcolor = skin.label.font_color,
            text = string.format("x%d", meta:get_int("paper")),
        },

        gui.bg9 {
            x = TABLE_WIDTH/8,
            y = TABLE_HEIGHT/80,

            w = TABLE_WIDTH/20,
            h = TABLE_WIDTH/20,

            skin = skin.label,
        },
        gui.image {
            x = TABLE_WIDTH/8,
            y = TABLE_WIDTH/80,

            w = TABLE_WIDTH/20,
            h = TABLE_WIDTH/20,

            image = skin.pigment_texture .. ".png",
        },
        gui.label {
            x = TABLE_WIDTH/8+TABLE_WIDTH/20,
            y = TABLE_WIDTH/20,

            textcolor = skin.label.font_color,
            text = string.format("x%d", meta:get_int("pigment")),
        },
    };
end

-- Draw a label with material costs from a table
--
-- x: The x position of the interface
-- y: The y position of the interface
-- cost: A table of material costs, with string keys for the material
--       names and integer values
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.cost(x, y, cost, skin)
    local data = {
        gui.bg9 {
            x = x,
            y = y,
            w = TABLE_WIDTH/40*5,
            h = TABLE_HEIGHT/10,

            skin = skin.label,
        },
    }

    local i = 0;
    for name,value in pairs(cost) do
        local texture = "";
        if name == "paper" then
            texture = skin.paper_texture .. ".png";
        elseif name == "pigment" then
            texture = skin.pigment_texture .. ".png";
        end

        table.insert(data, gui.image {
            x = x,
            y = y + (i * TABLE_HEIGHT/20),
            w = TABLE_WIDTH/20,
            h = TABLE_HEIGHT/20,

            image = texture,
        });

        table.insert(data, gui.label {
            x = x + TABLE_WIDTH/20,
            y = y + (i * TABLE_HEIGHT/80*3)+TABLE_HEIGHT/80*3,
            w = TABLE_WIDTH/20,
            h = TABLE_HEIGHT/20,

            textcolor = skin.label.font_color,
            text = string.format("x %d", value);
        });

        i = i + 1;
    end

    return table.concat(data);
end

-- Draw the material conversion tab UI
--
-- x: The x position of the interface
-- y: The y position of the interface
-- pos: The table position (for displaying the inventory)
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.convert(x, y, pos, skin)
    local meta = minetest.get_meta(pos);
    local value = materials.get_stack_value(meta:get_inventory():get_stack("input", 1));

    return gui.container {
        x = x,
        y = y,

        gui.inventory {
            x = 0,
            y = 0,
            w = TABLE_WIDTH/10+TABLE_WIDTH/80,
            h = TABLE_WIDTH/10+TABLE_WIDTH/80,

            location = string.format("nodemeta:%d,%d,%d", pos.x, pos.y, pos.z),
            id = "input",
            bg = skin.slot,
            tooltip = "Place items here to convert\nthem into mapmaking materials",
        },

        gui.button {
            x = TABLE_WIDTH/4,
            y = 0,
            w = 3.5,
            h = 1,

            id = "convert",
            text = "Insert Materials",
            disabled = value.paper + value.pigment <= 0,
        },

        fs.cost(TABLE_WIDTH/8, 0, value, skin),
    };
end

-- Draw the map crafting tab UI
--
-- x: The x position of the interface
-- y: The y position of the interface
-- pos: The table position (for displaying the inventory)
-- rank: The 'rank' of the table
-- meta: A metadata object containing the table settings and material
--       quantities
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.craft(x, y, pos, rank, meta, skin)
    local cost, is_positive = get_craft_material_cost(meta);
    local stack = meta:get_inventory():get_stack("output", 1);

    local data = {
        x = x,
        y = y,

        gui.inventory {
            x = 0,
            y = TABLE_HEIGHT/10,
            w = TABLE_WIDTH/10,
            h = TABLE_HEIGHT/10,

            location = string.format("nodemeta:%d,%d,%d", pos.x, pos.y, pos.z),
            id = "output",
            bg = skin.slot,
            tooltip = "Place a map here to upgrade it,\nor leave empty to craft",
        },
        gui.button {
            x = TABLE_WIDTH/4,
            y = TABLE_HEIGHT/10,
            w = TABLE_WIDTH/3,
            h = TABLE_HEIGHT/10,

            id = "craft",
            text = stack:get_name() == "cartographer:map" and "Upgrade Map" or "Craft Map",
            disabled = not (is_positive and can_afford(cost, meta)),
        },
        fs.cost(TABLE_WIDTH/8, TABLE_HEIGHT/10, cost, skin),

        gui.style {
            selector = string.format("%dx,%d", meta:get_int("scale"), meta:get_int("detail") + 1),
            properties = {
                bgimg = skin.button.selected_texture .. ".png",
                bgimg_hovered = skin.button.selected_texture .. ".png",
                bgimg_pressed = skin.button.selected_texture .. ".png",
            },
        },
        gui.label {
            x = 0,
            y = TABLE_HEIGHT/80,

            text = "Detail Level",
            textcolor = skin.label.font_color,
        },
    };

    if rank > 1 then
        table.insert(data, gui.label {
            x = 3,
            y = TABLE_HEIGHT/80,

            text = "Zoom Out Level",
            textcolor = skin.label.font_color,
        });
        table.insert(data, gui.button {
            x = 3,
            y = TABLE_HEIGHT/40,
            w = 0.7,
            h = 0.7,

            id = "1x",
            text = "1x",
        });
        table.insert(data, gui.button {
            x = 3.7,
            y = TABLE_HEIGHT/40,
            w = 0.7,
            h = 0.7,

            id = "2x",
            text = "2x",
        });

        if rank > 2 then
            table.insert(data, gui.button {
                x = 4.4,
                y = TABLE_HEIGHT/40,
                w = 0.7,
                h = 0.7,

                id = "4x",
                text = "4x",
            });
            table.insert(data, gui.button {
                x = 5.1,
                y = TABLE_HEIGHT/40,
                w = 0.7,
                h = 0.7,

                id = "8x",
                text = "8x",
            });
        end
    end

    table.insert(data, gui.button {
        x = 0,
        y = TABLE_HEIGHT/40,
        w = 0.7,
        h = 0.7,

        id = "1",
        text = "1",
    });
    table.insert(data, gui.button {
        x = 0.7,
        y = TABLE_HEIGHT/40,
        w = 0.7,
        h = 0.7,

        id = "2",
        text = "2",
    });
    if rank > 1 then
        table.insert(data, gui.button {
            x = 1.4,
            y = TABLE_HEIGHT/40,
            w = 0.7,
            h = 0.7,

            id = "3",
            text = "3",
        });
        if rank > 2 then
            table.insert(data, gui.button {
                x = 2.1,
                y = TABLE_HEIGHT/40,
                w = 0.7,
                h = 0.7,

                id = "4",
                text = "4",
            });
        end
    end

    return gui.container(data);
end

-- Draw the map copying tab UI
--
-- x: The x position of the interface
-- y: The y position of the interface
-- pos: The table position (for displaying the inventory)
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.copy(x, y, pos, skin)
    local meta = minetest.get_meta(pos);
    local costs = get_copy_material_cost(meta);

    return gui.container {
        x = x,
        y = y,

        gui.inventory {
            x = 0,
            y = 0,
            w = TABLE_WIDTH/10,
            h = TABLE_HEIGHT/10,

            location = string.format("nodemeta:%d,%d,%d", pos.x, pos.y, pos.z),
            tooltip = "Place map to be copied here",
            id = "copy_input",
            bg = skin.slot,
        },
        gui.inventory {
            x = TABLE_WIDTH/2,
            y = 0,
            w = TABLE_WIDTH/10,
            h = TABLE_HEIGHT/10,

            location = string.format("nodemeta:%d,%d,%d", pos.x, pos.y, pos.z),
            tooltip = "Copied map will appear here",
            id = "copy_output",
            bg = skin.slot,
        },
        gui.button {
            x = TABLE_WIDTH/4,
            y = 0,
            w = TABLE_WIDTH/4,
            h = TABLE_HEIGHT/10,

            id = "copy",
            text = "Copy Map",
            disabled = not can_afford(costs, meta),
        },
        fs.cost(TABLE_WIDTH/8, 0, costs, skin),
    };
end

-- Draw the player's inventory
--
-- x: The x position of the inventory
-- y: The y position of the inventory
-- skin: A formspec skin table
--
-- Returns a formspec string
function fs.inv(x, y, skin)
    local styling = "style_type[list;size="..TABLE_WIDTH/10 ..";spacing=".. TABLE_WIDTH/80 .."]";
    local inventory = gui.inventory {
        x = x,
        y = y,
        w = 8,
        h = 4,

        location = "current_player",
        id = "main",
        bg = skin.slot,
		bgw = TABLE_WIDTH/10+TABLE_WIDTH/80,
		bgh = TABLE_HEIGHT/10+TABLE_WIDTH/80,
    };
	return styling..inventory
end

local player_tables = {};

-- Show the table formspec to the specified player
-- The player must be recorded in player_tables in order to receive
-- a formspec.
--
-- player: The player's name
local function table_formspec(player)
    local data = player_tables[player];
    local pos = data.pos;

    if not pos then
        return;
    end

    local meta = minetest.get_meta(pos);

    local rank = 1;
    local skin = gui_skin.table_skins.simple_table;
    local name = minetest.get_node(pos).name;
    if name == "cartographer:standard_table" then
        rank = 2;
        skin = gui_skin.table_skins.standard_table;
    elseif name == "cartographer:advanced_table" then
        rank = 3;
        skin = gui_skin.table_skins.advanced_table;
    end

    if data.tab == 1 then
        minetest.show_formspec(player, "cartographer:table",
            fs.header(TABLE_WIDTH, TABLE_HEIGHT, rank, data.tab, skin) ..
            fs.materials(TABLE_WIDTH/20, TABLE_HEIGHT/20, meta, skin) ..
            fs.convert(TABLE_WIDTH/20, TABLE_HEIGHT/8, pos, skin) ..
            fs.inv(TABLE_WIDTH/20, TABLE_HEIGHT/4+0.375, skin)
            );
    elseif data.tab == 2 then
        minetest.show_formspec(player, "cartographer:table",
            fs.header(TABLE_WIDTH, TABLE_HEIGHT + TABLE_HEIGHT/20, rank, data.tab, skin) ..
            fs.materials(TABLE_WIDTH/20, TABLE_HEIGHT/20, meta, skin) ..
            fs.craft(TABLE_WIDTH/20, TABLE_HEIGHT/8, pos, rank, meta, skin) ..
            fs.inv(TABLE_WIDTH/20, TABLE_HEIGHT/4+TABLE_HEIGHT/8, skin)
            );
    elseif data.tab == 3 then
        minetest.show_formspec(player, "cartographer:table",
            fs.header(TABLE_WIDTH, TABLE_HEIGHT, rank, data.tab, skin) ..
            fs.materials(TABLE_WIDTH/20, TABLE_HEIGHT/20, meta, skin) ..
            fs.copy(TABLE_WIDTH/20, TABLE_HEIGHT/8, pos, skin) ..
            fs.inv(TABLE_WIDTH/20, TABLE_HEIGHT/4+0.375, skin)
            );
    end
end

-- Called when a player sends input to the server from a formspec
-- This callback handles player input in the table formspec
--
-- player: The player who sent the input
-- name: The formspec name
-- fields: A table containing the input
minetest.register_on_player_receive_fields(function(player, name, fields)
    if name == "cartographer:table" then
        local meta = minetest.get_meta(player_tables[player:get_player_name()].pos);

        local rank = 1;
        local node_name = minetest.get_node(player_tables[player:get_player_name()].pos).name;
        if node_name == "cartographer:standard_table" then
            rank = 2;
        elseif node_name == "cartographer:advanced_table" then
            rank = 3;
        end

        if fields["convert"] then
            local inv = meta:get_inventory();
            local stack = inv:get_stack("input", 1);

            local value = materials.get_stack_value(stack);

            if value.paper + value.pigment > 0 then
                meta:set_int("paper", meta:get_int("paper") + value.paper);
                meta:set_int("pigment", meta:get_int("pigment") + value.pigment);
                inv:set_stack("input", 1, ItemStack(nil));
            end
        elseif fields["craft"] then
            local size = meta:get_int("size");
            local detail = meta:get_int("detail");
            local scale = meta:get_int("scale");
            local cost, is_positive = get_craft_material_cost(meta);

            if is_positive and can_afford(cost, meta) then
                meta:set_int("paper",  meta:get_int("paper") - cost.paper);
                meta:set_int("pigment", meta:get_int("pigment") - cost.pigment);

                local inv = meta:get_inventory();
                local stack = inv:get_stack("output", 1);

                if stack:is_empty() then
                    inv:set_stack("output", 1, map_item.create(size, 1 + detail, scale));
                else
                    local smeta = stack:get_meta();
                    smeta:set_int("cartographer:detail", 1 + detail);
                    map_item.resize(smeta, size);
                    map_item.rescale(smeta, scale);

                    local map = maps.get(smeta:get_int("cartographer:map_id"));
                    if map then
                        map.detail = 1 + detail;
                    end
                    inv:set_stack("output", 1, stack);
                end

                audio.play_feedback("cartographer_write", player);
            end
        elseif fields["copy"] and rank >= 2 then
            local cost = get_copy_material_cost(meta);
            if can_afford(cost, meta) then
                meta:set_int("paper",  meta:get_int("paper") - cost.paper);
                meta:set_int("pigment", meta:get_int("pigment") - cost.pigment);

                audio.play_feedback("cartographer_write", player);

                local inv = meta:get_inventory();
                inv:set_stack("copy_output", 1, map_item.copy(inv:get_stack("copy_input", 1)));
            end
        elseif fields["1"] then
            meta:set_int("detail", 0);
        elseif fields["2"] then
            meta:set_int("detail", 1);
        elseif fields["3"] and rank > 1 then
            meta:set_int("detail", 2);
        elseif fields["4"] and rank > 2 then
            meta:set_int("detail", 3);
        elseif fields["1x"] and rank > 1 then
            meta:set_int("scale", SCALE_SMALL);
        elseif fields["2x"] and rank > 1 then
            meta:set_int("scale", SCALE_MEDIUM);
        elseif fields["4x"] and rank > 2 then
            meta:set_int("scale", SCALE_LARGE);
        elseif fields["8x"] and rank > 2 then
            meta:set_int("scale", SCALE_HUGE);
        elseif fields["tab1"] then
            player_tables[player:get_player_name()].tab = 1;
            audio.play_feedback("cartographer_turn_page", player);
        elseif fields["tab2"] then
            player_tables[player:get_player_name()].tab = 2;
            audio.play_feedback("cartographer_turn_page", player);
        elseif fields["tab3"] and rank >= 2 then
            player_tables[player:get_player_name()].tab = 3;
            audio.play_feedback("cartographer_turn_page", player);
        end

        if not fields["quit"] then
            table_formspec(player:get_player_name());
        end
    end
end);

-- Called after a table is placed. Sets up the table's inventory and metadata.
--
-- pos: The node's position
local function setup_table_node(pos)
    local meta = minetest.get_meta(pos);
    meta:get_inventory():set_size("input", 1);
    meta:get_inventory():set_size("output", 1);
    meta:get_inventory():set_size("copy_input", 1);
    meta:get_inventory():set_size("copy_output", 1);

    meta:set_int("size", settings.default_size);
    meta:set_int("scale", SCALE_SMALL);
    meta:set_int("detail", 0);
end

-- Called when the player tries to put an item into one of the table's
-- inventories.
--
-- listname: The name of the inventory the item is being placed in.
-- stack: The itemstack
--
-- Returns 0 if the place is invalid; otherwise, returns the number of items
-- that can be placed.
local function table_can_put(_, listname, _, stack, _)
    if listname == "copy_output" then
        return 0;
    end

    if stack:get_name() ~= "cartographer:map" and (listname == "output" or listname == "copy_input") then
        return 0;
    end

    return stack:get_count();
end

-- Called when the player tries to move an item between two of the table's
-- inventories.
--
-- to_list: The name of the inventory the item is being placed in.
-- count: The number of items being moved
--
-- Returns 0 if the move is invalid; otherwise, returns the number of items
-- that can be moved.
local function table_can_move(_, _, _, to_list, _, count, _)
    if to_list == "copy_output" then
        return 0;
    end

    return count;
end

-- Called when a change occurs in a table's inventory
--
-- pos: The node's position
-- listname: The name of the changed inventory list
local function table_on_items_changed(pos, listname, _, _, _)
    for player, data in pairs(player_tables) do
        if vector.equals(pos, data.pos) and (
                        (data.tab == 1 and listname == "input")
                     or (data.tab == 2 and listname == "output")
                     or (data.tab == 3 and listname == "copy_input")) then
            table_formspec(player);
        end
    end
end

-- The table node definitions
minetest.register_node("cartographer:simple_table", {
    description = "Shabby Cartographer's Table",
    drawtype = "mesh",
    mesh = gui_skin.table_skins.simple_table.node_mesh,
    tiles = { gui_skin.table_skins.simple_table.node_texture },
    paramtype2 = "facedir",
    groups = {
        choppy = 2,
        oddly_breakable_by_hand = 2,
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    on_rightclick = function(_, _, player, _, pointed_thing)
        player_tables[player:get_player_name()] = {
            pos = minetest.get_pointed_thing_position(pointed_thing),
            tab = 1,
        };

        audio.play_feedback("cartographer_open_map", player);
        table_formspec(player:get_player_name())
    end,

    after_place_node = setup_table_node,

    allow_metadata_inventory_move = table_can_move,
    allow_metadata_inventory_put = table_can_put,
    on_metadata_inventory_put = table_on_items_changed,
    on_metadata_inventory_take = table_on_items_changed,
});

minetest.register_node("cartographer:standard_table", {
    description = "Simple Cartographer's Table",
    drawtype = "mesh",
    mesh = gui_skin.table_skins.standard_table.node_mesh,
    tiles = { gui_skin.table_skins.standard_table.node_texture },
    paramtype2 = "facedir",
    groups = {
        choppy = 2,
        oddly_breakable_by_hand = 2,
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    on_rightclick = function(_, _, player, _, pointed_thing)
        player_tables[player:get_player_name()] = {
            pos = minetest.get_pointed_thing_position(pointed_thing),
            tab = 1,
        };

        audio.play_feedback("cartographer_open_map", player);
        table_formspec(player:get_player_name())
    end,

    after_place_node = setup_table_node,

    allow_metadata_inventory_move = table_can_move,
    allow_metadata_inventory_put = table_can_put,
    on_metadata_inventory_put = table_on_items_changed,
    on_metadata_inventory_take = table_on_items_changed,
});

minetest.register_node("cartographer:advanced_table", {
    description = "Advanced Cartographer's Table",
    drawtype = "mesh",
    mesh = gui_skin.table_skins.advanced_table.node_mesh,
    tiles = { gui_skin.table_skins.advanced_table.node_texture },
    paramtype2 = "facedir",
    groups = {
        choppy = 2,
        oddly_breakable_by_hand = 2,
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.375, 0.5, 0.6875, 0.375},
        },
    },
    on_rightclick = function(_, _, player, _, pointed_thing)
        player_tables[player:get_player_name()] = {
            pos = minetest.get_pointed_thing_position(pointed_thing),
            tab = 1,
        };

        audio.play_feedback("cartographer_open_map", player);
        table_formspec(player:get_player_name())
    end,

    after_place_node = setup_table_node,

    allow_metadata_inventory_move = table_can_move,
    allow_metadata_inventory_put = table_can_put,
    on_metadata_inventory_put = table_on_items_changed,
    on_metadata_inventory_take = table_on_items_changed,
});
