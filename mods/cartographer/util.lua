return {
    -- Get an entry from a list for a given detail level
    --
    -- textures: An array of textures
    -- detail: The detail level
    --
    -- Returns the entry at detail, or the last entry if detail is out-of-bounds
    get_clamped = function(textures, detail)
        return textures[math.min(detail, #textures)];
    end
};
