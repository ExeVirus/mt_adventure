-- Arguments
-- chunk: The chunk coordinate conversion API
-- scanner: The map scanning API
-- maps: The map API
-- settings: The mod settings
local chunk, scanner, maps, settings = ...;

-- Periodically-called function to fill in maps and queue chunks for backup
-- scans
if settings.autofill_freq ~= 0 then
    -- scanning
    local function fill_loop()
        -- Fill in all player-held maps
        for _,p in ipairs(minetest.get_connected_players()) do
            local inventory = p:get_inventory();
            local pos = p:get_pos();
            if pos.y > -10 then
                for i = 1,inventory:get_size("main") do
                    local stack = inventory:get_stack("main", i);
                    local map = maps.get(stack:get_meta():get_int("cartographer:map_id"));

                    if map then
                        map:fill_local(pos.x, pos.z);
                    end
                end
                for i = -4,4 do
                    for j = -4,4 do
                        local adjusted_pos = {
                            x = pos.x + chunk.from(i),
                            y = pos.y,
                            z = pos.z + chunk.from(j),
                        }
                        scanner.queue_region(adjusted_pos);
                    end
                end
            end
        end
        minetest.after(settings.autofill_freq, fill_loop);
    end

    minetest.after(settings.autofill_freq, fill_loop);
end
