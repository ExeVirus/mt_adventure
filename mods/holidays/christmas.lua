-- Is it Christmas?
if holidays.is_holiday_active("christmas") then
    holidays.log("action", "christmas enabled")

    -- Special chest textures
    minetest.override_item("default:chest", {
        tiles = {
            "christmas_chest_top.png",
            "christmas_chest_inside.png",
            "christmas_chest_side.png",
            "christmas_chest_side.png",
            "christmas_chest_side.png",
            "christmas_chest_front.png",
        }
    })
    minetest.override_item("default:chest_open", {
        tiles = {
            "christmas_chest_top.png",
            "christmas_chest_inside.png",
            "christmas_chest_side.png",
            "christmas_chest_side.png",
            "christmas_chest_front.png",
            "christmas_chest_inside.png",
        }
    })
    minetest.override_item("default:chest_locked", {
        tiles = {
            "christmas_chest_top.png",
            "christmas_chest_inside.png",
            "christmas_chest_side.png",
            "christmas_chest_side.png",
            "christmas_chest_side.png",
            "christmas_chest_locked_front.png",
        }
    })
    minetest.override_item("default:chest_locked_open", {
        tiles = {
            "christmas_chest_top.png",
            "christmas_chest_inside.png",
            "christmas_chest_side.png",
            "christmas_chest_side.png",
            "christmas_chest_locked_front.png",
            "christmas_chest_inside.png",
        }
    })
end
