-- Arguments
-- settings: The mod settings
local settings = ...;

-- Storage and saving
local mod_storage = minetest.get_mod_storage();
local map_data = {
    -- Scanned map data
    generated = minetest.deserialize(mod_storage:get_string("map")) or {},

    -- Maps
    maps = minetest.deserialize(mod_storage:get_string("maps")) or {},

    -- The next id
    next_map_id = mod_storage:get_int("next_map_id"),

    -- The version of the map api
    api_version = mod_storage:get_int("api_version"),
};

if map_data.next_map_id == 0 then
    map_data.next_map_id = 1;
end

if map_data.api_version == 0 then
    map_data.api_version = 1;
end

local function save()
    mod_storage:set_string("maps", minetest.serialize(map_data.maps));
    mod_storage:set_int("next_map_id", map_data.next_map_id);
    mod_storage:set_string("map", minetest.serialize(map_data.generated));
    mod_storage:set_string("api_version", minetest.serialize(map_data.api_version));
end
minetest.register_on_shutdown(save);
minetest.register_on_leaveplayer(save);

if settings.autosave_freq ~= 0 then
    local function periodic_save()
        save();
        minetest.after(settings.autosave_freq, periodic_save);
    end
    minetest.after(settings.autosave_freq, periodic_save);
end

return map_data;
