-- Audio API (Internal)
--
-- Contains functions for providing audio feedback
local audio = {
    -- Play a feedback sound localized on the given player
    --
    -- sound: The sound to play
    -- player: The player who triggered the sound
    play_feedback = function(sound, player)
        minetest.sound_play(sound, { pos=player:get_pos(), max_hear_distance=5 }, true);
    end
};

return audio;
