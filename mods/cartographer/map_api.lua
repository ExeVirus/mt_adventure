-- Arguments
-- map_data: The map data source
-- chunk: The chunk coordinate conversion API
local map_data, chunk = ...;

-- The map 'class'
local Map = {};
Map.__index = Map;

for _,loaded_map in ipairs(map_data.maps) do
    setmetatable(loaded_map, Map);
end

-- Rescale this map
--
-- scale: The new scale
function Map.rescale(self, scale)
    if scale >= self.scale then
        self.fill = {};
        self.markers = {};
        self.scale = scale;
    end
end

-- Resize this map
--
-- w: The new width
-- h: The new height
function Map.resize(self, w, h)
    if w >= self.w and h >= self.h then
        self.w = w;
        self.h = h;
    end
end


-- Fill in a region of this map
--
-- x: The x position, in map coordinates
-- z: The z position, in map coordinates
-- w: The width, in map coordinates
-- h: The height, in map coordinates
function Map.fill_area(self, x, z, w, h)
    for i = math.max(x, 0),math.min(x + w - 1, self.w),1 do
        if not self.fill[i] then
            self.fill[i] = {};
        end

        for j = math.max(z, 0),math.min(z + h - 1, self.h),1 do
            self.fill[i][j] = self.detail;
        end
    end
end

-- Set the marker at the given position
--
-- x: The x position, in map coordinates
-- z: The z position, in map coordinates
-- marker: The marker ID to set, or nil to unset
function Map.set_marker(self, x, z, marker)
    if x < 0 or x > self.w or z < 0 or z > self.h then
        return;
    end

    if not self.markers[x] then
        self.markers[x] = {
            [z] = marker,
        };
    else
        self.markers[x][z] = marker;
    end
end

-- Get the marker at the given position
--
-- x: The x position, in map coordinates
-- z: The z position, in map coordinates
--
-- Returns a marker id
function Map.get_marker(self, x, z)
    if x < 0 or x > self.w or z < 0 or z > self.h or not self.markers[x] then
        return nil;
    end

    return self.markers[x][z];
end

-- Fill in the local area of a map around a position
--
-- id: A map ID
-- x: The x position, in world coordinates
-- z: The z position, in world coordinates
function Map.fill_local(self, x, z)
    x, z = self:to_coordinates(x, z, true);

    local scale_sizes = {
        7,
        5,
        5,
        3,
        3,
        3,
        1,
        1,
    };

    local fill_size = scale_sizes[math.min(self.scale, #scale_sizes)];
    local fill_radius = math.floor(fill_size / 2);

    if x >= 0 - fill_radius and x <= self.w + (fill_radius - 1)
        and z >= 0 - fill_radius and z <= self.h + (fill_radius - 1) then
        self:fill_area(x - fill_radius, z - fill_radius, fill_size, fill_size);
    end
end

-- Convert a position in world coordinates to the given map's coordinate system
--
-- x: The x position, in world coordinates
-- z: The z position, in world coordinates
-- (Optional) relative: When true, the coordinates are relative to this map's
--                      position.
--
-- Returns The converted x and z coordinates
function Map.to_coordinates(self, x, z, relative)
    if self.scale == 0 then
        return chunk.to(x), chunk.to(z);
    end

    if relative then
        return math.floor((chunk.to(x) - self.x) / self.scale + 0.5),
               math.floor((chunk.to(z) - self.z) / self.scale + 0.5);
    else
        return math.floor(chunk.to(x) / self.scale + 0.5),
               math.floor(chunk.to(z) / self.scale + 0.5);
    end
end

-- Check if the given position on this map is filled
--
-- x: The x position, in map coordinates
-- z: The z position, in map coordinates
function Map.is_filled(self, x, z)
    return self.fill[x - self.x] and self.fill[x - self.x][z - self.z];
end

-- The Map API
local maps = {
    -- Create a new map object with the given parameters
    --
    -- x: The x position, in map coordinates
    -- z: The z position, in map coordinates
    -- w: The width, in map coordinates
    -- h: The height, in map coordinates
    -- filled: Whether or not the map is pre-filled
    -- detail: The detail level
    -- scale: The scale factor
    --
    -- Returns the new map's id
    create = function(x, z, w, h, filled, detail, scale)
        local id = map_data.next_map_id;

        local map = {
            id = id,
            x = x,
            z = z,
            w = w,
            h = h,
            detail = detail,
            scale = scale,
            fill = {},
            markers = {},
        };
        setmetatable(map, Map);

        map_data.maps[id] = map;
        if filled then
            map:fill_area(0, 0, w, h);
        end

        map_data.next_map_id = map_data.next_map_id + 1;

        return id;
    end,

    -- Get the map objwct assigned to the given id
    --
    -- id: The map id
    --
    -- Returns a map object, or nil if the id is invalid
    get = function(id)
        return map_data.maps[id];
    end,
}

return maps;
