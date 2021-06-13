-- Arguments
-- map_data: The cartographer map data table
-- chunk: The chunk coordinate conversion API
-- settings: The mod settings
local map_data, chunk, settings = ...;

local scan_queue = {};

-- Register a new tile in map data
-- x: The x position in map coordinates
-- y: The y position in map coordinates
-- biome: The tile's biome id
-- height: The tile's height
-- (Optional): manual_scan: Indicates if this was a 'manual' (non-generated)
--                          scan. Manual scans are overridden by generated
--                          scans under normal circumstances.
local function register_tile(x, y, biome, height, manual_scan)
    if not map_data.generated[x] then
        map_data.generated[x] = {
            [y] = {
                biome = biome,
                height = height,
            }
        };
        if manual_scan ~= nil then
            map_data.generated[x][y].manual_scan = manual_scan;
        end
    elseif not map_data.generated[x][y] or map_data.generated[x][y].height < height then
        map_data.generated[x][y] = {
                biome = biome,
                height = height,
            };
        if manual_scan ~= nil or map_data.generated[x][y].manual_scan then
            map_data.generated[x][y].manual_scan = manual_scan;
        end
    end
end

-- Get the biome and height data for a region from mapgen data
--
-- min: The min coord of the generated terrain
-- max: The max coord of the generated terrain
-- mmin: The min coord of the region to scan
-- mmax: The max coord of the region to scan
--
-- Returns the biome and height of the scanned region
local function get_mapgen_biome(min, max, mmin, mmax)
    local UNDERGROUND = minetest.get_biome_id("underground");
    local DEFAULT = minetest.get_biome_id("default");

    local biomes = minetest.get_mapgen_object("biomemap");
    local heights = minetest.get_mapgen_object("heightmap");

    local xx = max.x - min.x;
    local zz = max.z - min.z;

    local xxx = mmax.x - mmin.x;

    local startx = min.x - mmin.x;
    local startz = min.z - mmin.z;

    local scan_biomes = {};
    local scan_heights = {};

    for i = startx,startx + xx,1 do
        for k = startz,startz + zz,1 do
            local b = biomes[i + (k * (xxx + 1))];
            if b ~= nil and b ~= UNDERGROUND and b ~= DEFAULT then
                scan_biomes[b] = (scan_biomes[b] or 0) + 1;
                scan_heights[b] = (scan_heights[b] or 0) + heights[i + (k * (xxx + 1))];
            end
        end
    end

    local biome = nil;
    local high = 0;
    for k,v in pairs(scan_biomes) do
        if v > high then
            biome = k;
            high = v;
        end
    end

    local avg_height = 0;
    if high > 0 then
        avg_height = scan_heights[biome] / high;
    end

    return biome, avg_height;
end

-- Get the biome and height data for a region from existing terrain
--
-- min: The min coord of the region to scan
-- max: The max coord of the region to scan
--
-- Returns the biome and height of the scanned region
local function get_biome(min, max)
    local UNDERGROUND = minetest.get_biome_id("underground");
    local DEFAULT = minetest.get_biome_id("default");
    local WATER_SOURCE = minetest.registered_aliases["mapgen_water_source"];

    local scan_biomes = {};
    local scan_heights = {};

    for i = min.x,max.x,1 do
        for j = min.y,max.y,1 do
            for k = min.z,max.z,1 do
                local pos = { x=i, y=j, z=k };
                local b = minetest.get_biome_data(pos).biome;
                local node = minetest.get_node(pos).name;
                if b ~= nil and b ~= UNDERGROUND and b ~= DEFAULT and node ~= "air" and node ~= WATER_SOURCE then
                    pos.y = pos.y + 1;
                    node = minetest.get_node(pos).name;
                    if node == "air" or node == WATER_SOURCE then
                        scan_biomes[b] = (scan_biomes[b] or 0) + 1;
                        scan_heights[b] = (scan_heights[b] or 0) + j;
                    end
                end
            end
        end
    end

    local biome = nil;
    local high = 0;
    for k,v in pairs(scan_biomes) do
        if v > high then
            biome = k;
            high = v;
        end
    end

    local avg_height = 0;
    if high > 0 then
        avg_height = scan_heights[biome] / high;
    end

    return biome, avg_height;
end

-- Called when new terrain is generated
--
-- min: The min coord of the generated terrain
-- max: The max coord of the generated terrain
local function on_generated(min, max, _)
    for i = chunk.to(min.x),chunk.to(max.x),1 do
        for j = chunk.to(min.z),chunk.to(max.z),1 do

            local sub_min = {
                x = chunk.from(i),
                y = min.y,
                z = chunk.from(j),
            };
            local sub_max = {
                x = chunk.from(i + 1),
                y = max.y,
                z = chunk.from(j + 1),
            };
            local biome, height = get_mapgen_biome(sub_min, sub_max, min, max);
            if  biome ~= nil then
                register_tile(i, j, biome, height)
            end

        end
    end
end
--minetest.register_on_generated(on_generated);

-- Is the scan of this position already handled?
--
-- x: The x position, in map coordinates
-- y: The y position, in world coordinates
-- x: The z position, in map coordinates
--
-- Returns true if the position is handled by the current map data
local function is_scan_handled(x, y, z)
    if not map_data.generated[x] then
        return false;
    end

    local tile = map_data.generated[x][z];

    return tile and ((not tile.manual_scan and tile.height > 0) or tile.height >= y);
end

local scanner = {};

-- Queue a tile for manual scanning
--
-- pos: The position as a table, in world coordinates
function scanner.queue_region(pos)
    local converted = {
        x = chunk.from(chunk.to(pos.x)),
        y = chunk.from(chunk.to(pos.y)),
        z = chunk.from(chunk.to(pos.z)),
    };

    if is_scan_handled(chunk.to(pos.x), pos.y, chunk.to(pos.z)) then
        return;
    end

    for _,queued_pos in ipairs(scan_queue) do
        if vector.equals(converted, queued_pos) then
            return;
        end
    end

    scan_queue[#scan_queue + 1] = converted;
end

local function scan_internal()
    local startpos = scan_queue[1];
    local chunk_x = chunk.to(startpos.x);
    local chunk_y = chunk.to(startpos.y);
    local chunk_z = chunk.to(startpos.z);

    local endpos = {
        x = chunk.from(chunk_x + 1),
        y = chunk.from(chunk_y + 1),
        z = chunk.from(chunk_z + 1),
    };

    if is_scan_handled(chunk_x, startpos.y, chunk_z) then
        table.remove(scan_queue, 1);
        return;
    end

    local biome,height = get_biome(startpos, endpos);
    if biome ~= nil then
        register_tile(chunk_x, chunk_z, biome, height, true)
    end

    table.remove(scan_queue, 1);
end

-- Scan the next N tiles on the queue, and remove them
-- N is determined by backup_scan_count
--
-- flush: Flush the entire scan queue, scanning all queued regions
function scanner.scan_regions(flush)
    if #scan_queue == 0 then
        return;
    end

    if settings.backup_scan_count == 0 or flush then
        while #scan_queue > 0 do
            scan_internal();
        end
    else
        for _=1,settings.backup_scan_count do
            if #scan_queue == 0 then
                break;
            end

            scan_internal();
        end
    end
end

if settings.backup_scan_freq ~= 0 then
    local function periodic_scan()
        scanner.scan_regions();
        minetest.after(settings.backup_scan_freq, periodic_scan);
    end
    minetest.after(settings.backup_scan_freq, periodic_scan);
end

return scanner;
