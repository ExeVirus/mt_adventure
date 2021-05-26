-- The path to this mod, for including files
local modpath = minetest.get_modpath("cartographer");

local settings = {
    default_size = tonumber(minetest.settings:get("default_size")) or 40,
    autofill_freq = tonumber(minetest.settings:get("autofill_freq")) or 5,
    autosave_freq = tonumber(minetest.settings:get("autosave_freq")) or 60,
    backup_scan_freq = tonumber(minetest.settings:get("backup_scan_freq")) or 5,
    backup_scan_count = tonumber(minetest.settings:get("backup_scan_count")) or 20,
};

-- Includes
local map_data = loadfile(modpath .. "/storage.lua") (settings);
local chunk = loadfile(modpath .. "/chunk_api.lua") ();
local gui = loadfile(modpath .. "/formspec.lua") ();
local skin = loadfile(modpath .. "/skin_api.lua") ();
local util = loadfile(modpath .. "/util.lua") ();
local audio = loadfile(modpath .. "/audio.lua") ();
local biomes = loadfile(modpath .. "/biome_api.lua") (util);
local markers = loadfile(modpath .. "/marker_api.lua") ();
local scanner = loadfile(modpath .. "/scanner.lua") (map_data, chunk, settings);
local maps = loadfile(modpath .. "/map_api.lua") (map_data, chunk);
local materials = loadfile(modpath .. "/material_api.lua") ();
local map_formspec = loadfile(modpath .. "/map_formspec.lua") (map_data, gui, skin, util, biomes, markers);
local map_item = loadfile(modpath .. "/items.lua") (chunk, gui, skin, audio, maps, markers, map_formspec, settings);
loadfile(modpath .. "/commands.lua") (chunk, audio, map_formspec, settings);
loadfile(modpath .. "/table.lua") (gui, skin, audio, maps, materials, map_item, settings);
loadfile(modpath .. "/autofill.lua") (chunk, scanner, maps, settings);

-- The API object
cartographer = {
    -- skin_api.lua: Allows the visual customization of formspecs
    skin = skin,
    -- biome_api.lua: Allows biome data to be registered for display in maps
    biomes = biomes,
    -- marker_api.lua: Allows markers to be registered for placement on maps
    markers = markers,
    -- map_api.lua: Allows the creation, lookup, and management of map objects
    maps = maps,
    -- items.lua: Allows the creation of map items with proper metadata
    map_item = map_item,
    -- materials.lua: Allows items to be registered as mapmaking materials
    materials = materials,
    -- scanner.lua: Exposes functions for queuing and performing terrain scans
    scanner = scanner,
};
