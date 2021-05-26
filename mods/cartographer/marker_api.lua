local marker_lookup = {};

-- Format marker ids to allow their use as formspec element ids.
-- We're mostly concerned with guarding against the : character because it is
-- common for ids and has an alternate meaning in formspecs.
--
-- id: The id to format
--
-- Returns the formatted id
local function format_marker_id(id)
    return id:gsub(":", "_");
end

-- Find the marker data for a given id
--
-- id: The id to search for
--
-- Returns the marker data, or nil if not found
local function get_marker(id)
    if not id then
        return nil;
    end

    id = format_marker_id(id);
    for _,marker in pairs(marker_lookup) do
        if marker.id == id then
            return marker;
        end
    end

    return nil;
end

-- Get the number of registered markers
--
-- Returns the length of the marker table
local function get_marker_count()
    return #marker_lookup;
end

-- Get all registered markers
--
-- Returns a copy of the marker table
local function get_registered_markers()
    return table.copy(marker_lookup);
end

-- Register a marker with textures to display
--
-- id: A string containing the id of the marker
-- name: A string containing the displayedname of the marker
-- textures: A table of texture names.
--           These should correspond with detail levels,
--           any detail level past the length of the table will return the last texture
local function add_marker(id, name, textures)
    if not id then
        return nil;
    end

    id = format_marker_id(id);
    local existing_marker = get_marker(id);
    if existing_marker then
        existing_marker.name = name;
        existing_marker.textures = textures;
    else
        marker_lookup[#marker_lookup+1] = {
            id = id,
            name = name,
            textures = textures,
        };
    end
end

-- Get the texture name (minus extension) for the given marker and detail level.
--
-- id: A string containing the marker id
-- detail: The detail level
-- Returns a string with a texture name, or nil if no matching marker was found.
local function get_marker_texture(id, detail)
    if not id then
        return nil;
    end

    id = format_marker_id(id);
    local marker = get_marker(id);

    if marker then
        return marker.textures[math.min(detail, #marker.textures)];
    end

    return nil;
end

return {
    add = add_marker,
    count = get_marker_count,
    get = get_marker,
    get_all = get_registered_markers,
    get_texture = get_marker_texture,
};
