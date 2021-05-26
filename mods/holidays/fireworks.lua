if holidays.is_holiday_active("fireworks") then
    holidays.log("action", "fireworks enabled")
end

holidays.fireworks = {}

local firework_height = 30
local firework_height_vector = vector.new(0, firework_height, 0)
local firework_delay = 2
local fireworks_colors = {
    '^[multiply:#FF0000', -- red
    '^[multiply:#0000FF', -- blue
    '^[multiply:#00FF00', -- green
    '^[multiply:#FFFF00', -- yellow
    '^[multiply:#C882C8', -- purple
    '^[multiply:#FF7f27', -- orange
    '',                   -- white
}

local function random_vector(min, max)
    return vector.new(math.random(min, max), math.random(min, max), math.random(min, max))
end

function holidays.fireworks.explode(pos, color)
	if not color then color = '' end
    pos = vector.add(pos, firework_height_vector)
    minetest.sound_play("holidays_fireworks_bang", {
        pos=pos,
        max_hear_distance=90,
        gain=2
    })
	local v = math.random(5, 10)
	local n = math.random(40, 100)
    minetest.add_particlespawner({
        amount=n,
        time=0.1,
        minpos=pos,
        maxpos=pos,
        minvel={x=-v,y=-v,z=-v},
        maxvel={x=v,y=v,z=v},
        minacc={x=0,y=0,z=0},
        maxacc={x=0,y=0,z=0},
        minexptime=2,
        maxexptime=3,
        minsize=1.5,
        maxsize=2,
        glow = 14,  -- not sure glow is used?
        collisiondetection=false,
        collision_removal=false,
        vertical=false,
        texture=("fireworks_dot.png%s"):format(color)
    })
end

function holidays.fireworks.launch_particle(pos)
    minetest.add_particle({
        pos=pos,
        velocity={x=0, y=firework_height / firework_delay, z=0},
        acceleration={x=0, y=0, z=0},
        expirationtime=firework_delay,
        size=4,
        glow=14,
        collisiondetection=false,
        collision_removal=false,
        vertical=true,
        texture="fireworks_dot.png^[multiply:#FF0000" -- red
    })
end

function holidays.fireworks.launch(pos, color)
    minetest.sound_play("holidays_fireworks_rocket", {pos=pos, max_hear_distance=13, gain=0.1})
    holidays.fireworks.launch_particle(pos)
    minetest.after(firework_delay, holidays.fireworks.explode, pos, color)
end

function holidays.fireworks.firework_ignite(pos)
    --randomly select a color for the fireworks
    local index = math.random(1, #fireworks_colors)
    local color = fireworks_colors[index]
    holidays.fireworks.launch(pos, color)
    minetest.remove_node(pos)
end

function holidays.fireworks.finale_timer(pos)
    local meta = minetest.get_meta(pos)
    local count = meta:get_int("count")
    if count > 0 then
        --randomly select a color for the fireworks
        local index = math.random(1, #fireworks_colors)
        local color = fireworks_colors[index]
        pos = vector.add(pos, random_vector(-5, 5))
        holidays.fireworks.launch(pos, color)
        meta:set_int("count", count - 1)
        return true
    else
        minetest.remove_node(pos)
        return false
    end
end

local firework_groups
if holidays.is_holiday_active("fireworks") then
    firework_groups = { dig_immediate = 3 }
else
    firework_groups = { dig_immediate = 3, not_in_creative_inventory = 1 }
end

minetest.register_node('holidays:fireworks', {
    description = 'Fireworks',
    drawtype = 'plantlike',
    tiles = { 'fireworks_firework.png', },
    groups = firework_groups,
    paramtype = 'light',
    inventory_image = 'fireworks_firework.png',
    wield_image = 'fireworks_firework.png',
    on_ignite = function(pos, igniter)
        holidays.fireworks.firework_ignite(pos)
	end,
	on_construct = function(pos)
		if not holidays.is_holiday_active("fireworks") then
			minetest.remove_node(pos)
		end
	end,
})

minetest.register_node('holidays:finale', {
    description = 'Finale',
    tiles = { 'fireworks_finale.png' },
    groups = firework_groups,
    paramtype = 'light',
    inventory_image = 'fireworks_finale.png',
    wield_image = 'fireworks_finale.png',
    on_ignite = function(pos, igniter)
        minetest.get_node_timer(pos):start(0.5)
    end,
    on_construct = function(pos)
		if holidays.is_holiday_active("fireworks") then
			local meta = minetest.get_meta(pos)
			meta:set_int("count", 50)
		else
			minetest.remove_node(pos)
		end
    end,
    on_timer = holidays.fireworks.finale_timer
})

if holidays.is_holiday_active("fireworks") then
    if minetest.get_modpath("tnt") then
        minetest.register_craft({
            output = "holidays:fireworks 4",
            recipe = {
                {"", "group:dye",        ""},
                {"", "default:stick",    ""},
                {"", "tnt:gunpowder",""}
            },
        })
    else
        minetest.register_craft({
            output = "holidays:fireworks 1",
            recipe = {
                {"", "group:dye",        ""},
                {"", "default:stick",    ""},
                {"", "default:coal_lump",""}
            },
        })
    end

    minetest.register_craft({
        output = "holidays:finale 1",
        recipe = {
            {"holidays:fireworks","holidays:fireworks","holidays:fireworks"},
            {"holidays:fireworks","holidays:fireworks","holidays:fireworks"},
            {"holidays:fireworks","holidays:fireworks","holidays:fireworks"}
        },
    })

else
    -- remove fireworks after July 4th
    minetest.register_lbm({
        name = 'holidays:remove_fireworks',
        nodenames = {'holidays:fireworks', 'holidays:finale'},
        run_at_every_load = false,
        action = minetest.remove_node
    })
end
