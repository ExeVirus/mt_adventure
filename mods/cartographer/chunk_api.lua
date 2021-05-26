local CHUNK_SIZE = 16;

-- Contains functions for converting coordinates between world units and the
-- unit used by cartographer's maps
return {
    -- Convert world coordinates to map coordinates
    -- coord: The coordinate value
    --
    -- Returns a coordinate value in map space
    to = function(coord)
        return math.floor(coord / CHUNK_SIZE);
    end,

    -- Convert map coordinates to world coordinates
    -- coord: The coordinate value
    --
    -- Returns a coordinate value in world space
    from = function(coord)
        return math.floor(coord * CHUNK_SIZE);
    end
};
