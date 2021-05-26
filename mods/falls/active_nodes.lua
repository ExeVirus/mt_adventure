local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP..'/intllib.lua')

--
-- Waterfall Block
--

local function waterfall_timer(pos)
	local meta = minetest.get_meta(pos)
	local id   = minetest.add_particlespawner({
		amount     = 325,
		time       = 10,
		minpos 	   = minetest.deserialize(meta:get_string('minpos')),
		maxpos     = minetest.deserialize(meta:get_string('maxpos')),
		minvel     = minetest.deserialize(meta:get_string('minvel')),
		maxvel     = minetest.deserialize(meta:get_string('maxvel')),
		minacc     = minetest.deserialize(meta:get_string('minacc')),
		maxacc     = minetest.deserialize(meta:get_string('maxacc')),
		minexptime = 3,
		maxexptime = 3,
		minsize    = 0.5,
		maxsize    = 1,
		collisiondetection = false,
		collision_removal  = false,
		vertical   = false,
		texture    = 'water_white.png',
	})
	meta:set_int('spawner', id)
	return 1
end

local function waterfall_formspec(direction, height, distance, spread)
	local formspec =
		'size[5.5,5]'..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		'label[1,0.5;Direction]'..
		'dropdown[1,1;1.5,1;direction;0,45,90,135,180,225,270,315;'.. direction ..']'..
		'label[1,2.5;Height]'..
		'dropdown[1,3;1.5,1;height;short,mid,tall...;'.. height ..']'..
		'label[3,0.5;Distance]'..
		'dropdown[3,1;1.5,1;distance;short,mid,far;'.. distance ..']'..
		'label[3,2.5;Spread]'..
		'dropdown[3,3;1.5,1;spread;narrow,normal,wide...;'.. spread ..']'..
		'button_exit[2,4;2,1;update;Update]'
	return formspec
end

minetest.register_lbm({
	name 	  = 'falls:trigger_waterfalls',
	nodenames = {'falls:waterfall_block'},
	run_at_every_load = true,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
        local id = minetest.add_particlespawner({
			amount = 325,
			time   = 10,
			minpos = minetest.deserialize(meta:get_string('minpos')),
			maxpos = minetest.deserialize(meta:get_string('maxpos')),
			minvel = minetest.deserialize(meta:get_string('minvel')),
			maxvel = minetest.deserialize(meta:get_string('maxvel')),
			minacc = minetest.deserialize(meta:get_string('minacc')),
			maxacc = minetest.deserialize(meta:get_string('maxacc')),
			minexptime = 3,
			maxexptime = 3,
			minsize = 0.5,
			maxsize = 1,
			collisiondetection = false,
			collision_removal  = false,
			vertical = false,
			texture = 'water_white.png',
		})
		meta:set_int('spawner', id) --ID to remove spawner on node destruct
		minetest.get_node_timer(pos):start(10.0)
	end,
})

minetest.register_node('falls:waterfall_block_inv', {
	drawtype 	= 'airlike',
	description = S('Invisible Waterfall Block'),
	paramtype 	= 'light',
    inventory_image = "waterfall_block_inv.png",
	walkable  	= false,
	groups 		= {oddly_breakable_by_hand=3},
	sounds 		= default.node_sound_water_defaults(),
	
    on_timer = waterfall_timer,

	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		minetest.delete_particlespawner(meta:get_int('spawner'))
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string('minpos', minetest.serialize({x=pos.x-.4, y=pos.y+0.5, z=pos.z-.4}))
		meta:set_string('maxpos', minetest.serialize({x=pos.x+.4, y=pos.y+0.5, z=pos.z+.4}))
		meta:set_string('minvel', minetest.serialize({x=1, y=0, z=0}))
		meta:set_string('maxvel', minetest.serialize({x=2, y=0, z=0}))
		meta:set_string('minacc', minetest.serialize({x=-1, y=-4.3, z=0}))
		meta:set_string('maxacc', minetest.serialize({x=-1, y=-6, z=0}))

		--set formspec to 0 degrees, mid height, short distance, mid spread
		meta:set_string('formspec', waterfall_formspec(1,2,1,2))

        local id = minetest.add_particlespawner({
			amount = 325,
			time   = 10,
			minpos   = {x=pos.x-.4,y=pos.y+0.5,z=pos.z-.4},
			maxpos   = {x=pos.x+.4,y=pos.y+0.5,z=pos.z+.4},
			minvel   = {x=1,y=0,z=0}, maxvel={x=2,y=0,z=0},
			minacc   = {x=-1,y=-4.3,z=0}, maxacc={x=-1,y=-6,z=0},
			minexptime = 3,
			maxexptime = 3,
			minsize    = 0.5,
			maxsize    = 1,
			collisiondetection = false,
			collision_removal  = false,
			vertical = false,
			texture  = 'water_white.png',
		})

		--set ID for destruct later
		meta:set_int('spawner', id)
		minetest.get_node_timer(pos):start(10.0)
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		local meta = minetest.get_meta(pos)
		if(fields.update) then
			local spread, spread_pos, minfall, maxfall, distance
			local ht,spd --for updating the formspec dropdowns
			if(fields.spread == 'narrow') then
				spread 	   = 0.1
				spread_pos = 0.2
				spd 	   = 1
			elseif(fields.spread == 'normal') then
				spread 	   = 0.2
				spread_pos = 0.4
				spd        = 2
			else
				spread     = 1
				spread_pos = 0.5
				spd        = 3
			end

			if(fields.height == 'short') then
				minfall = -2.1
				maxfall = -3
				ht      = 1
			elseif(fields.height == 'mid') then
				minfall = -4.3
				maxfall = -6
				ht      = 2
			else
				minfall = -4.3
				maxfall = -6
				ht      = 3
			end

			if(fields.distance == 'short') then
				distance = 1
			elseif(fields.distance == 'mid') then
				distance = 2
			else
				distance = 3
			end

			meta:set_string('minpos', minetest.serialize({x=pos.x-spread_pos, y=pos.y+0.5, z=pos.z-spread_pos}))
			meta:set_string('maxpos', minetest.serialize({x=pos.x+spread_pos, y=pos.y+0.5, z=pos.z+spread_pos}))
			meta:set_string('minvel', minetest.serialize({
                x = math.cos(math.rad(fields.direction)) * distance,
                y = 0,
                z = math.sin(math.rad(fields.direction)) * distance
            }))
			meta:set_string('maxvel', minetest.serialize({
                x = math.cos(math.rad(fields.direction)) * 2 * distance,
				y = 0,
				z = math.sin(math.rad(fields.direction)) * 2 * distance
            }))
            --At 0 degrees, direction is +z and spread is perpendicular to direction
			meta:set_string('minacc', minetest.serialize({
				x = -math.cos(math.rad(fields.direction)) * distance + math.sin(fields.direction) * -spread,
				y = minfall,
				z = -math.sin(math.rad(fields.direction)) * distance + math.cos(fields.direction) * spread
            }))
			meta:set_string('maxacc', minetest.serialize({
				x = -math.cos(math.rad(fields.direction)) * distance * 1.5 + math.sin(fields.direction) * spread,
				y = maxfall,
				z = -math.sin(math.rad(fields.direction)) * distance * 1.5 + math.cos(fields.direction) * -spread
            }))
			minetest.delete_particlespawner(meta:get_int('spawner'))
			local id = minetest.add_particlespawner({
                amount  = 325,
                time    = 10,
                minpos  = minetest.deserialize(meta:get_string('minpos')),
                maxpos  = minetest.deserialize(meta:get_string('maxpos')),
                minvel  = minetest.deserialize(meta:get_string('minvel')),
                maxvel  = minetest.deserialize(meta:get_string('maxvel')),
                minacc  = minetest.deserialize(meta:get_string('minacc')),
                maxacc  = minetest.deserialize(meta:get_string('maxacc')),
                minexptime = 1,
                maxexptime = 2,
                minsize = 0.5,
                maxsize = 1,
                collisiondetection=false,
                collision_removal=false,
                vertical=false,
                texture='water_white.png',
            })
			meta:set_int('spawner', id)
			minetest.get_node_timer(pos):start(10.0)
			meta:set_string('formspec',
                waterfall_formspec((fields.direction + 45) / 45, ht, distance, spd))
		end
	end,
})

minetest.register_node('falls:waterfall_block', {
	drawtype 	= 'glasslike',
	description = S('Waterfall Block'),
	tiles     	= {'waterfall_block.png'},
	alpha     	= 160,
	paramtype 	= 'light',
	walkable  	= false,
	drowning  	= 1,
	climbable 	= true,
	groups 		= {oddly_breakable_by_hand=3},
	sounds 		= default.node_sound_water_defaults(),
	post_effect_color = {a = 103, r = 30, g = 60, b = 95},

    on_timer = waterfall_timer,

	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		minetest.delete_particlespawner(meta:get_int('spawner'))
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string('minpos', minetest.serialize({x=pos.x-.4, y=pos.y+0.5, z=pos.z-.4}))
		meta:set_string('maxpos', minetest.serialize({x=pos.x+.4, y=pos.y+0.5, z=pos.z+.4}))
		meta:set_string('minvel', minetest.serialize({x=1, y=0, z=0}))
		meta:set_string('maxvel', minetest.serialize({x=2, y=0, z=0}))
		meta:set_string('minacc', minetest.serialize({x=-1, y=-4.3, z=0}))
		meta:set_string('maxacc', minetest.serialize({x=-1, y=-6, z=0}))

		--set formspec to 0 degrees, mid height, short distance, mid spread
		meta:set_string('formspec', waterfall_formspec(1,2,1,2))

        local id = minetest.add_particlespawner({
			amount = 325,
			time   = 10,
			minpos   = {x=pos.x-.4,y=pos.y+0.5,z=pos.z-.4},
			maxpos   = {x=pos.x+.4,y=pos.y+0.5,z=pos.z+.4},
			minvel   = {x=1,y=0,z=0}, maxvel={x=2,y=0,z=0},
			minacc   = {x=-1,y=-4.3,z=0}, maxacc={x=-1,y=-6,z=0},
			minexptime = 3,
			maxexptime = 3,
			minsize    = 0.5,
			maxsize    = 1,
			collisiondetection = false,
			collision_removal  = false,
			vertical = false,
			texture  = 'water_white.png',
		})

		--set ID for destruct later
		meta:set_int('spawner', id)
		minetest.get_node_timer(pos):start(10.0)
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		local meta = minetest.get_meta(pos)
		if(fields.update) then
			local spread, spread_pos, minfall, maxfall, distance
			local ht,spd --for updating the formspec dropdowns
			if(fields.spread == 'narrow') then
				spread 	   = 0.1
				spread_pos = 0.2
				spd 	   = 1
			elseif(fields.spread == 'normal') then
				spread 	   = 0.2
				spread_pos = 0.4
				spd        = 2
			else
				spread     = 1
				spread_pos = 0.5
				spd        = 3
			end

			if(fields.height == 'short') then
				minfall = -2.1
				maxfall = -3
				ht      = 1
			elseif(fields.height == 'mid') then
				minfall = -4.3
				maxfall = -6
				ht      = 2
			else
				minfall = -4.3
				maxfall = -6
				ht      = 3
			end

			if(fields.distance == 'short') then
				distance = 1
			elseif(fields.distance == 'mid') then
				distance = 2
			else
				distance = 3
			end

			meta:set_string('minpos', minetest.serialize({x=pos.x-spread_pos, y=pos.y+0.5, z=pos.z-spread_pos}))
			meta:set_string('maxpos', minetest.serialize({x=pos.x+spread_pos, y=pos.y+0.5, z=pos.z+spread_pos}))
			meta:set_string('minvel', minetest.serialize({
                x = math.cos(math.rad(fields.direction)) * distance,
                y = 0,
                z = math.sin(math.rad(fields.direction)) * distance
            }))
			meta:set_string('maxvel', minetest.serialize({
                x = math.cos(math.rad(fields.direction)) * 2 * distance,
				y = 0,
				z = math.sin(math.rad(fields.direction)) * 2 * distance
            }))
            --At 0 degrees, direction is +z and spread is perpendicular to direction
			meta:set_string('minacc', minetest.serialize({
				x = -math.cos(math.rad(fields.direction)) * distance + math.sin(fields.direction) * -spread,
				y = minfall,
				z = -math.sin(math.rad(fields.direction)) * distance + math.cos(fields.direction) * spread
            }))
			meta:set_string('maxacc', minetest.serialize({
				x = -math.cos(math.rad(fields.direction)) * distance * 1.5 + math.sin(fields.direction) * spread,
				y = maxfall,
				z = -math.sin(math.rad(fields.direction)) * distance * 1.5 + math.cos(fields.direction) * -spread
            }))
			minetest.delete_particlespawner(meta:get_int('spawner'))
			local id = minetest.add_particlespawner({
                amount  = 325,
                time    = 10,
                minpos  = minetest.deserialize(meta:get_string('minpos')),
                maxpos  = minetest.deserialize(meta:get_string('maxpos')),
                minvel  = minetest.deserialize(meta:get_string('minvel')),
                maxvel  = minetest.deserialize(meta:get_string('maxvel')),
                minacc  = minetest.deserialize(meta:get_string('minacc')),
                maxacc  = minetest.deserialize(meta:get_string('maxacc')),
                minexptime = 1,
                maxexptime = 2,
                minsize = 0.5,
                maxsize = 1,
                collisiondetection=false,
                collision_removal=false,
                vertical=false,
                texture='water_white.png',
            })
			meta:set_int('spawner', id)
			minetest.get_node_timer(pos):start(10.0)
			meta:set_string('formspec',
                waterfall_formspec((fields.direction + 45) / 45, ht, distance, spd))
		end
	end,
})

minetest.register_craft({
	output = 'falls:waterfall_block 1',
	recipe = {
		{'default:mese_crystal_fragment'},
		{'falls:basin'},
	},
})

minetest.register_craft({
	output = 'falls:waterfall_block_inv 1',
	recipe = {
		{'default:glass'},
		{'falls:waterfall_block'},
	},
})

--
-- Waterfall Basin
--

local function basin_timer(pos)
	local meta = minetest.get_meta(pos)
	local id = minetest.add_particlespawner({
        amount = 400,
        time   = 10,
		minpos = minetest.deserialize(meta:get_string('minpos')),
		maxpos = minetest.deserialize(meta:get_string('maxpos')),
		minvel = minetest.deserialize(meta:get_string('minvel')),
		maxvel = minetest.deserialize(meta:get_string('maxvel')),
		minacc = minetest.deserialize(meta:get_string('minacc')),
		maxacc = minetest.deserialize(meta:get_string('maxacc')),
		minexptime = 1,
        maxexptime = 2,
		minsize = 0.5,
        maxsize = 1,
		collisiondetection = false,
        collision_removal  = false,
		vertical = false,
		texture  = 'water_blue.png',
    })
	meta:set_int('spawner', id)
	return 1
end

local function basin_formspec(direction, height, distance, spread)
	local formspec =
		'size[5.5,5]'..
        default.gui_bg..
        default.gui_bg_img..
        default.gui_slots..
        'label[1,0.5;Direction]'..
        'dropdown[1,1;1.5,1;direction;0,45,90,135,180,225,270,315;'.. direction ..']'..
        'label[1,2.5;Height]'..
        'dropdown[1,3;1.5,1;height;short,mid,tall...;'.. height ..']'..
        'label[3,0.5;Distance]'..
        'dropdown[3,1;1.5,1;distance;short,mid,far;'.. distance ..']'..
        'label[3,2.5;Spread]'..
        'dropdown[3,3;1.5,1;spread;narrow,normal,wide...;'.. spread ..']'..
        'button_exit[2,4;2,1;update;Update]'
	return formspec
end

minetest.register_lbm({
	name      = 'falls:trigger_basins',
	nodenames = {'falls:basin'},
	run_at_every_load = true,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
        local id = minetest.add_particlespawner({
            amount  = 400,
            time    = 10,
            minpos  = minetest.deserialize(meta:get_string('minpos')),
            maxpos  = minetest.deserialize(meta:get_string('maxpos')),
            minvel  = minetest.deserialize(meta:get_string('minvel')),
            maxvel  = minetest.deserialize(meta:get_string('maxvel')),
            minacc  = minetest.deserialize(meta:get_string('minacc')),
            maxacc  = minetest.deserialize(meta:get_string('maxacc')),
            minexptime = 1,
            maxexptime = 2,
            minsize = 0.5,
            maxsize = 1,
            collisiondetection = false,
            collision_removal  = false,
            vertical = false,
            texture  = 'water_blue.png',
        })
		meta:set_int('spawner', id)
		minetest.get_node_timer(pos):start(10.0)
	end,
})

minetest.register_node('falls:basin', {
	drawtype    = 'glasslike',
	description = S('Waterfall Basin'),
	tiles       = {'waterfall_basin.png'},
	walkable    = false,
	paramtype 	= 'light',
    climbable   = true,
	groups      = {oddly_breakable_by_hand=3},
	drowning    = 1,
	alpha       = 160,
	sounds      = default.node_sound_water_defaults(),
    post_effect_color = {a = 103, r = 30, g = 60, b = 95},

    on_timer = basin_timer,

	on_destruct = function(pos)
        local meta = minetest.get_meta(pos)
		minetest.delete_particlespawner(meta:get_int('spawner'))
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string('minpos', minetest.serialize({x=pos.x-.2, y=pos.y+0.5, z=pos.z-.2}))
		meta:set_string('maxpos', minetest.serialize({x=pos.x+.2, y=pos.y+0.5, z=pos.z+.2}))
		meta:set_string('minvel', minetest.serialize({x=0, y=5, z=0}))
		meta:set_string('maxvel', minetest.serialize({x=0, y=6, z=0}))
		meta:set_string('minacc', minetest.serialize({x=-1, y=-7, z=1}))
		meta:set_string('maxacc', minetest.serialize({x=1, y=-7, z=1}))

		meta:set_string('formspec', basin_formspec(1,2,1,2))

        local id = minetest.add_particlespawner({
            amount  = 400,
            time    = 10,
            minpos  = {x=pos.x-.2,y=pos.y+0.5,z=pos.z-.2},
            maxpos  = {x=pos.x+.2,y=pos.y+0.5,z=pos.z+.2},
            minvel  = {x=0,y=5,z=0}, maxvel={x=0,y=6,z=0},
            minacc  = {x=-1,y=-7,z=1}, maxacc={x=1,y=-7,z=1},
            minexptime = 1,
            maxexptime = 2,
            minsize = 0.5,
            maxsize = 1,
            collisiondetection = false,
            collision_removal  = false,
            vertical = false,
            texture  = 'water_blue.png',
        })
		meta:set_int('spawner', id)
		minetest.get_node_timer(pos):start(10.0)
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		local meta = minetest.get_meta(pos)
		if(fields.update) then
			local spread, spread_pos, minheight, maxheight, fallback, distance
			local ht,spd
			if(fields.spread == 'narrow') then
				spread     = 0.5
				spread_pos = 0.1
				spd        = 1
			elseif(fields.spread == 'normal') then
				spread     = 1
				spread_pos = 0.2
				spd        = 2
			else
				spread     = 1.2
				spread_pos = 0.4
				spd        = 3
			end

			if(fields.height == 'short') then
				minheight = 2.5
				maxheight = 3
				fallback  = -5
				ht        = 1
			elseif(fields.height == 'mid') then
				minheight = 5
				maxheight = 6
				fallback  = -7
				ht        = 2
			else
				minheight = 8
				maxheight = 10
				fallback  = -9
				ht        = 3
			end

			if(fields.distance == 'short') then
				distance = 1
			elseif(fields.distance == 'mid') then
				distance = 2
			else
				distance = 3
			end

			meta:set_string('minpos', minetest.serialize({x=pos.x-spread_pos, y=pos.y+0.5, z=pos.z-spread_pos}))
			meta:set_string('maxpos', minetest.serialize({x=pos.x+spread_pos, y=pos.y+0.5, z=pos.z+spread_pos}))
			meta:set_string('minvel', minetest.serialize({x=0, y=minheight, z=0}))
			meta:set_string('maxvel', minetest.serialize({x=0, y=maxheight, z=0}))
            --At 0 degrees, direction is +z and spread is perpendicular to direction
			meta:set_string('minacc', minetest.serialize({
				x = math.sin(math.rad(fields.direction)) * distance+math.cos(fields.direction) * -spread,
				y = fallback,
				z = math.cos(math.rad(fields.direction)) * distance+math.sin(fields.direction) * spread
            }))
			meta:set_string('maxacc', minetest.serialize({
				x = math.sin(math.rad(fields.direction)) * distance+math.cos(fields.direction) * spread,
				y = fallback,
				z = math.cos(math.rad(fields.direction)) * distance+math.sin(fields.direction) * -spread
            }))
			minetest.delete_particlespawner(meta:get_int('spawner'))
			local id = minetest.add_particlespawner({
                amount  = 400,
                time    = 10,
                minpos  = minetest.deserialize(meta:get_string('minpos')),
                maxpos  = minetest.deserialize(meta:get_string('maxpos')),
                minvel  = minetest.deserialize(meta:get_string('minvel')),
                maxvel  = minetest.deserialize(meta:get_string('maxvel')),
                minacc  = minetest.deserialize(meta:get_string('minacc')),
                maxacc  = minetest.deserialize(meta:get_string('maxacc')),
                minexptime = 1,
                maxexptime = 2,
                minsize = 0.5,
                maxsize = 1,
                collisiondetection = false,
                collision_removal  = false,
                vertical = false,
                texture  = 'water_blue.png',
            })
			meta:set_int('spawner', id)
			minetest.get_node_timer(pos):start(10.0)
			meta:set_string('formspec',
                basin_formspec((fields.direction + 45) / 45, ht, distance, spd))
		end
	end,
})

minetest.register_node('falls:basin_inv', {
	drawtype    = 'airlike',
	description = S('Invisible Waterfall Basin'),
	inventory_image = "waterfall_basin.png",
	paramtype 	= 'light',
	groups      = {oddly_breakable_by_hand=3},
	sounds      = default.node_sound_water_defaults(),

    on_timer = basin_timer,

	on_destruct = function(pos)
        local meta = minetest.get_meta(pos)
		minetest.delete_particlespawner(meta:get_int('spawner'))
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string('minpos', minetest.serialize({x=pos.x-.2, y=pos.y+0.5, z=pos.z-.2}))
		meta:set_string('maxpos', minetest.serialize({x=pos.x+.2, y=pos.y+0.5, z=pos.z+.2}))
		meta:set_string('minvel', minetest.serialize({x=0, y=5, z=0}))
		meta:set_string('maxvel', minetest.serialize({x=0, y=6, z=0}))
		meta:set_string('minacc', minetest.serialize({x=-1, y=-7, z=1}))
		meta:set_string('maxacc', minetest.serialize({x=1, y=-7, z=1}))

		meta:set_string('formspec', basin_formspec(1,2,1,2))

        local id = minetest.add_particlespawner({
            amount  = 400,
            time    = 10,
            minpos  = {x=pos.x-.2,y=pos.y+0.5,z=pos.z-.2},
            maxpos  = {x=pos.x+.2,y=pos.y+0.5,z=pos.z+.2},
            minvel  = {x=0,y=5,z=0}, maxvel={x=0,y=6,z=0},
            minacc  = {x=-1,y=-7,z=1}, maxacc={x=1,y=-7,z=1},
            minexptime = 1,
            maxexptime = 2,
            minsize = 0.5,
            maxsize = 1,
            collisiondetection = false,
            collision_removal  = false,
            vertical = false,
            texture  = 'water_blue.png',
        })
		meta:set_int('spawner', id)
		minetest.get_node_timer(pos):start(10.0)
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		local meta = minetest.get_meta(pos)
		if(fields.update) then
			local spread, spread_pos, minheight, maxheight, fallback, distance
			local ht,spd
			if(fields.spread == 'narrow') then
				spread     = 0.5
				spread_pos = 0.1
				spd        = 1
			elseif(fields.spread == 'normal') then
				spread     = 1
				spread_pos = 0.2
				spd        = 2
			else
				spread     = 1.2
				spread_pos = 0.4
				spd        = 3
			end

			if(fields.height == 'short') then
				minheight = 2.5
				maxheight = 3
				fallback  = -5
				ht        = 1
			elseif(fields.height == 'mid') then
				minheight = 5
				maxheight = 6
				fallback  = -7
				ht        = 2
			else
				minheight = 8
				maxheight = 10
				fallback  = -9
				ht        = 3
			end

			if(fields.distance == 'short') then
				distance = 1
			elseif(fields.distance == 'mid') then
				distance = 2
			else
				distance = 3
			end

			meta:set_string('minpos', minetest.serialize({x=pos.x-spread_pos, y=pos.y+0.5, z=pos.z-spread_pos}))
			meta:set_string('maxpos', minetest.serialize({x=pos.x+spread_pos, y=pos.y+0.5, z=pos.z+spread_pos}))
			meta:set_string('minvel', minetest.serialize({x=0, y=minheight, z=0}))
			meta:set_string('maxvel', minetest.serialize({x=0, y=maxheight, z=0}))
            --At 0 degrees, direction is +z and spread is perpendicular to direction
			meta:set_string('minacc', minetest.serialize({
				x = math.sin(math.rad(fields.direction)) * distance+math.cos(fields.direction) * -spread,
				y = fallback,
				z = math.cos(math.rad(fields.direction)) * distance+math.sin(fields.direction) * spread
            }))
			meta:set_string('maxacc', minetest.serialize({
				x = math.sin(math.rad(fields.direction)) * distance+math.cos(fields.direction) * spread,
				y = fallback,
				z = math.cos(math.rad(fields.direction)) * distance+math.sin(fields.direction) * -spread
            }))
			minetest.delete_particlespawner(meta:get_int('spawner'))
			local id = minetest.add_particlespawner({
                amount  = 400,
                time    = 10,
                minpos  = minetest.deserialize(meta:get_string('minpos')),
                maxpos  = minetest.deserialize(meta:get_string('maxpos')),
                minvel  = minetest.deserialize(meta:get_string('minvel')),
                maxvel  = minetest.deserialize(meta:get_string('maxvel')),
                minacc  = minetest.deserialize(meta:get_string('minacc')),
                maxacc  = minetest.deserialize(meta:get_string('maxacc')),
                minexptime = 1,
                maxexptime = 2,
                minsize = 0.5,
                maxsize = 1,
                collisiondetection = false,
                collision_removal  = false,
                vertical = false,
                texture  = 'water_blue.png',
            })
			meta:set_int('spawner', id)
			minetest.get_node_timer(pos):start(10.0)
			meta:set_string('formspec',
                basin_formspec((fields.direction + 45) / 45, ht, distance, spd))
		end
	end,
})

minetest.register_craft({
	output = 'falls:basin 1',
	recipe = {
		{'','falls:bucket_turbulent',''},
		{'default:sand','default:sand','default:sand'}
	},
	replacements = {{ 'falls:bucket_turbulent', 'bucket:bucket_empty'}}
})

minetest.register_craft({
	output = 'falls:basin_inv 1',
	recipe = {
		{'falls:basin'},
		{'default:glass'},
	},
})

--
-- Fountain
--

local function fountain_timer(pos)
	local id = minetest.add_particlespawner({
        amount  = 400,
        time    = 10,
		minpos  = {x=pos.x-.1,y=pos.y+0.5,z=pos.z-.1},
		maxpos  = {x=pos.x+.1,y=pos.y+0.5,z=pos.z+.1},
		minvel  = {x=0,y=5,z=0}, maxvel={x=0,y=6,z=0},
		minacc  = {x=-1,y=-7,z=-1}, maxacc={x=1,y=-7,z=1},
		minexptime = 1,
        maxexptime = 2,
		minsize = 0.5,
        maxsize = 1,
		collisiondetection = false,
        collision_removal = false,
		vertical = false,
		texture = 'water_blue.png',
    })
	local meta = minetest.get_meta(pos)
	meta:set_int('spawner', id)
	return 1
end

minetest.register_lbm({
	name      = 'falls:trigger_fountains',
	nodenames = {'falls:fountain'},
	run_at_every_load = true,
	action = function(pos, node)
        local meta = minetest.get_meta(pos)
        local id = minetest.add_particlespawner({
            amount  = 400,
            time    = 10,
            minpos  = {x=pos.x-.1,y=pos.y+0.5,z=pos.z-.1},
            maxpos  = {x=pos.x+.1,y=pos.y+0.5,z=pos.z+.1},
            minvel  = {x=0,y=5,z=0},
            maxvel  = {x=0,y=6,z=0},
            minacc  = {x=-1,y=-7,z=-1},
            maxacc  = {x=1,y=-7,z=1},
            minexptime = 1,
            maxexptime = 2,
            minsize = 0.5,
            maxsize = 1,
            collisiondetection = false,
            collision_removal  = false,
            vertical = false,
            texture  = 'water_blue.png',
        })
		meta:set_int('spawner', id)
		minetest.get_node_timer(pos):start(10.0)
	end,
})

minetest.register_node('falls:fountain', {
	description     = S('Fountain'),
	drawtype        = 'plantlike',
	tiles           = {'fountain.png'},
	inventory_image = 'fountain_inventory.png',
	groups          = {oddly_breakable_by_hand=3},
	sounds          = default.node_sound_stone_defaults(),
    use_texture_alpha = true,
	paramtype 	= 'light',

    on_timer = fountain_timer,

	on_destruct = function(pos)
        local meta = minetest.get_meta(pos)
		minetest.delete_particlespawner(meta:get_int('spawner'))
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
        local id = minetest.add_particlespawner({
            amount  = 400,
            time    = 10,
            minpos  = {x=pos.x-.1,y=pos.y+0.5,z=pos.z-.1},
            maxpos  = {x=pos.x+.1,y=pos.y+0.5,z=pos.z+.1},
            minvel  = {x=0,y=5,z=0},
            maxvel  = {x=0,y=6,z=0},
            minacc  = {x=-1,y=-7,z=-1},
            maxacc  = {x=1,y=-7,z=1},
            minexptime = 1,
            maxexptime = 2,
            minsize = 0.5,
            maxsize = 1,
            collisiondetection = false,
            collision_removal = false,
            vertical = false,
            texture = 'water_blue.png',
        })
		meta:set_int('spawner', id)
		minetest.get_node_timer(pos):start(10.0)
	end,
})

minetest.register_craft({
	output = 'falls:fountain 1',
	recipe = {
		{'default:tin_ingot','default:steel_ingot','default:tin_ingot'},
		{'','falls:bucket_turbulent',''},
		{'default:tin_ingot','default:diamond','default:tin_ingot'}
	},
	replacements = {{ 'falls:bucket_turbulent', 'bucket:bucket_empty'}}
})


