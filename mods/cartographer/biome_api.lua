-- Arguments
-- util: API for uncategorized utility methods
local util = ...;

local biome_lookup = {};

-- Contains functions for registering and getting biome-related mapping information
return {
    -- Register a biome with textures to display
    --
    -- name: A string containing the biome name
    -- textures: A table of texture names.
    --           These should correspond with detail levels,
    --           any detail level past the length of the table will return the last texture
    -- (Optional) min_height: The minimum Y position where this biome data should be used
    -- (Optional) max_height: The maximum Y position where this biome data should be used
    add = function (name, textures, min_height, max_height)
        biome_lookup[#biome_lookup + 1] = {
            name = name,
            textures = textures,
            min_height = min_height,
            max_height = max_height,
        };
    end,

    -- Get the texture name (minus index/extension) for the given biome, height, and detail level.
    --
    -- name: A string containing the biome name
    -- height: A number representing the Y position of the biome
    -- detail: The detail level
    --
    -- Returns a string with a texture name, or nil if no matching biome entry was found.
    get_texture = function (name, height, detail)
        for _,biome in ipairs(biome_lookup) do
            local matches_height = (not biome.min_height or height >= biome.min_height)
            and (not biome.max_height or height <= biome.max_height);
            if biome.name == name and matches_height then
                return util.get_clamped(biome.textures, detail);
            end
        end

        return nil;
    end,
};
