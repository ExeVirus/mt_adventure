-- Arguments
-- chunk: The chunk coordinate conversion API
-- audio: The audio playback API
-- map_formspec: The map display API
-- settings: The mod settings
local chunk, audio, map_formspec, settings = ...;
local MAXINT = 2147483647;

minetest.register_privilege("cartographer", {
    description = "Allows use of the /map command to view local area maps",
    give_to_singleplayer = false,
    give_to_admin = true,
});

-- /map <detail> <scale> -- Displays a regional map around the player
-- (Optional)detail: Specifies the map's detail level. Defaults to the highest
--                   available detail.
-- (Optional)scale: Specifies the map's scale. Defaults to 1.
minetest.register_chatcommand("map", {
    params = "[<detail>] [<scale>]",
    description = "Display a mapo of the local area",
    privs = { cartographer = true },
    func = function(name, param)
        local detail, scale = param:match("(%d*) (%d*)");

        if detail then
            detail = tonumber(detail);
        else
            detail = MAXINT;
        end

        if scale then
            scale = tonumber(scale);
        else
            scale = 1;
        end

        local player = minetest.get_player_by_name(name);
        local pos = player:get_pos();
        local player_x = math.floor((chunk.to(pos.x) / scale) + 0.5);
        local player_z = math.floor((chunk.to(pos.z) / scale) + 0.5);

        audio.play_feedback("cartographer_open_map", player);
        minetest.show_formspec(name, "map", map_formspec.from_coords(player_x,
                                                                     player_z,
                                                                     settings.default_size,
                                                                     settings.default_size,
                                                                     detail,
                                                                     scale,
                                                                     true));
    end,
})
