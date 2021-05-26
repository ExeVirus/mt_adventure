-- Arguments
-- map_data: The cartographer map data table
-- gui: The GUI API
-- skin: The GUI skin
-- util: API for uncategorized utility methods
-- biomes: The biome API
-- markers: The marker API
local map_data, gui, skin, util, biomes, markers = ...;

-- Constants
local TILE_SIZE = 0.25;
local TILE_OFFSET = 0.24; -- Slightly smaller than TILE_SIZE. We overlap tiles slightly to minimize seams

-- NoiseParams table for tile variations
local MAP_NOISE = {
    offset = 0,
    scale = 1,
    spread = {x = 2, y = 2, z = 2},
    seed = tonumber(minetest.get_mapgen_setting("seed")),
    octaves = 2,
    persist = 0.63,
    lacunarity = 2.0,
    flags = "defaults, absvalue",
};

local function map_is_filled(map, x, y)
    return map:is_filled(x, y);
end

local function map_get_marker(map, x, y)
    return map:get_marker(x, y);
end

-- Get the variant of the tile at a given position
--
-- prefix: The part of the tile texture name before the variant
-- x: The X position of the tile (in map coordinates)
-- z: The Z position of the tile (in map coordinates)
-- noise: A 2d lookup table of perlin noise. Must contain the position [x + 1][y + 1]
--
-- Returns a string in the format 'prefix.variant.png', where variant is a number from 1 to 4
local function get_variant(prefix, x, z, noise)
    return string.format("%s.%d.png", prefix, math.floor(math.min(noise[x + 1][z + 1] * 3, 3)) + 1);
end

-- Generate formspec markup for a given map
--
-- x: The X position of the map (in relative map coordinates)
-- y: The Z position of the map (in relative map coordinates)
-- w: The width of the map (in map coordinates)
-- h: The height of the map (in map coordinates)
-- player_x: The X position of the player marker (in map coordinates)
-- player_y: The Y position of the player marker (in map coordinates)
-- detail: The detail level
-- map_scale: Integer scaling factor for displaying a zoomed-out map
-- height_mode: If true, displaces tiles by their height
-- (Optional) is_visible: Callback to determine if a tile should be drawn
-- (Optional) get_marker: Callback to get the marker for any given tile
--
-- Additional arguments are provided to is_visible / get_marker
--
-- Returns a formspec string
local function generate_map(x, y, w, h, player_x, player_y, detail, map_scale, height_mode, is_visible, get_marker, ...)
    local str = "";
    local noise = PerlinNoiseMap(MAP_NOISE, { x=w + 1, y=h + 1, z=1}):get_2d_map({ x=x, y=y});

    for i = 0,w,1 do
        local world_i = x + (i * map_scale);
        local fx = i * TILE_OFFSET;
        local column = map_data.generated[world_i];
        for j = h,0,-1 do
            local world_j = y + (j * map_scale);
            local fy = (h - j) * TILE_OFFSET;
            if column == nil or column[world_j] == nil or (is_visible and not is_visible(..., x + i, y + j)) then
                local unknown_tex = util.get_clamped(skin.unknown_biome_textures, detail);
                str = str .. gui.image {
                    x = fx,
                    y = fy,
                    w = TILE_SIZE,
                    h = TILE_SIZE,

                    image = get_variant(unknown_tex, i, j, noise),
                };
            else
                local name = minetest.get_biome_name(column[world_j].biome);
                local height = column[world_j].height;
                local biome = biomes.get_texture(name, math.floor(height + 0.5), detail);

                if biome then
                    local depth = math.min(math.max(math.floor(height / 8), -8), 0) * -1
                    height = math.max(math.min(math.floor(height / (math.max(map_scale * 0.5, 1) + 4)), 8), 0)

                    local mod = "";
                    if height > 0 then
                        mod = "^[colorize:white:"..tostring(height * 10)
                        height = height * 0.05;

                        if height_mode then
                            str = str .. gui.image {
                                x = fx,
                                y = fy - height + TILE_OFFSET,
                                w = TILE_SIZE,
                                h = height + 0.01,

                                image = util.get_clamped(skin.cliff_textures, detail)  .. ".png",
                            };
                        else
                            height = 0;
                        end
                    elseif depth > 0 then
                        mod = "^[colorize:#1f1f34:"..tostring(depth * 10)
                    end

                    str = str .. gui.image {
                        x = fx,
                        y = fy - height,
                        w = TILE_SIZE,
                        h = TILE_SIZE,

                        image = get_variant(biome, i, j, noise) .. mod,
                    };

                    if get_marker then
                        local marker = markers.get_texture(get_marker(..., i, j), detail);
                        if marker then
                            str = str .. gui.image {
                                x = fx,
                                y = fy - height,
                                w = TILE_SIZE,
                                h = TILE_SIZE,

                                image = marker .. ".png",
                            };
                        end
                    end

                    if i == player_x and j == player_y then
                        local player_icon = util.get_clamped(skin.player_icons, detail);
                        str = str .. gui.animated_image {
                            x = fx,
                            y = fy - height,
                            w = TILE_SIZE,
                            h = TILE_SIZE,

                            animation = player_icon,
                        };
                    end
                else
                    local unknown_tex = util.get_clamped(skin.unknown_biome_textures, detail);
                    str = str .. gui.image {
                        x = fx,
                        y = fy,
                        w = TILE_SIZE,
                        h = TILE_SIZE,

                        image = get_variant(unknown_tex, i, j, noise),
                    };
                end
            end
        end
    end

    return str;
end

local map_formspec = {};

-- Get the formspec for a given map segment
--
-- x: The X position of the map, in map coordinates
-- y: The Y position of the map, in map coordinates
-- w: The width of the map, in map coordinates
-- h: The height of the map, in map coordinates
-- detail: The detail level of the map
-- scale: Integer scaling factor for displaying a zoomed-out map
-- height_mode: If true, displaces tiles by their height
--
-- Returns a formspec string, the width of the formspec, and the height of the
-- formspec
function map_formspec.from_coords(x, y, w, h, detail, scale, height_mode)
    local formspec_width = (w + 1) * TILE_OFFSET + 0.01;
    local formspec_height = (h + 1) * TILE_OFFSET + 0.01;
    return gui.formspec {
        w = formspec_width,
        h = formspec_height,

        generate_map(x - (w * 0.5), y - (h * 0.5), w, h, w * 0.5, h * 0.5, detail, scale, height_mode),
    }, formspec_width, formspec_height;
end

-- Get the formspec for a given map table
--
-- map: The map to use
-- x: The X position of the player marker, in relative map coordinates
-- y: The Y position of the player marker, in relative map coordinates
-- height_mode: If true, displaces tiles by their height
--
-- Returns a formspec string, the width of the formspec, and the height of the
-- formspec
function map_formspec.from_map(map, x, y, height_mode)
    local formspec_width = (map.w + 1) * TILE_OFFSET + 0.01;
    local formspec_height = (map.h + 1) * TILE_OFFSET + 0.01;
    return gui.formspec {
        w = formspec_width,
        h = formspec_height,

        generate_map(map.x, map.z, map.w, map.h,
                     x, y, map.detail, map.scale, height_mode, map_is_filled, map_get_marker, map),
    }, formspec_width, formspec_height;
end

return map_formspec;
