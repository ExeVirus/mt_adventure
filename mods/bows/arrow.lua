
-- Localise functions
local floor, min, max = math.floor, math.min, math.max

--Should we use new collisionbox detection
local colbox = false
local radius = colbox and 3.0 or 1.0


--= Functions inspired from Kaeza's Firearms mod

local function minmax(x, y)
	return min(x, y), max(x, y)
end


local function pos_in_box(p, b1, b2)

	local xmin, xmax = minmax(b1.x, b2.x)
	local ymin, ymax = minmax(b1.y, b2.y)
	local zmin, zmax = minmax(b1.z, b2.z)

	return p.x >= xmin and p.x <= xmax
			and p.y >= ymin and p.y <= ymax
			and p.z >= zmin and p.z <= zmax
end


local function get_obj_box(obj)

	local box

	if obj:is_player() then
		box = {-.5, -.5, -.5, .5, 1.5, .5}
	else
		box = obj:get_luaentity().collisionbox
				or {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	end

	local p = obj:get_pos()
	local x1, y1, z1, x2, y2, z2 = unpack(box)

	return {x = x1 + p.x, y = y1 + p.y, z = z1 + p.z},
			{x = x2 + p.x, y = y2 + p.y, z = z2 + p.z}
end

--= END (Thanks Kaeza :)


local on_hit_remove = function(self)

	minetest.sound_play(
		bows.registed_arrows[self.name].on_hit_sound, {
			pos = self.object:get_pos(),
			gain = 1.0,
			max_hear_distance = 7
		})

	-- chance of dropping arrow
	local chance = minetest.registered_items[self.name].drop_chance

	if math.random(chance) == 1 then
		minetest.add_item(self.object:get_pos(), self.name)
	end

	self.object:remove()

	return self
end


local on_hit_object = function(self, target, hp, user, lastpos)

	target:punch(user, 0.1, {
		full_punch_interval = 0.1,
		damage_groups = {fleshy = hp},
	}, nil)

	if bows.registed_arrows[self.name].on_hit_object then

		bows.registed_arrows[self.name].on_hit_object(
			self, target, hp, user, lastpos)
	end

	on_hit_remove(self)

	return self
end


minetest.register_entity("bows:arrow",{

	hp_max = 10,
	visual = "wielditem",
	visual_size = {x = .20, y = .20},
	collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
	physical = true,
	textures = {"air"},
	_is_arrow = true,
	timer = 10,
	oldvel = {x = 0, y = 0, z = 0},

	on_activate = function(self, staticdata)

		if not self then
			self.object:remove()
			return
		end

		if bows.tmp and bows.tmp.arrow ~= nil then

			self.arrow = bows.tmp.arrow
			self.user = bows.tmp.user
			self.name = bows.tmp.name
			self.dmg = bows.registed_arrows[self.name].damage

			bows.tmp = nil

			self.object:set_properties({textures = {self.arrow}})
		else
			self.object:remove()
		end
	end,

	on_step = function(self, dtime, ...)

		self.timer = self.timer - dtime

		if self.timer < 0 then
			self.object:remove()
			return
		end

		local what_is, what_obj, ent

		for i, ob in pairs(minetest.get_objects_inside_radius(
				self.object:get_pos(), radius)) do

			what_obj = nil
			what_is = ""

			-- player
			if ob
			and bows.pvp
			and ob:is_player()
			and ob:get_player_name() ~= self.user:get_player_name() then

				what_obj = ob
				what_is = "player"
			end

			-- entity/mob
			if ob and not what_obj then

				ent = ob:get_luaentity()

				if ent
				and ent.physical
				and not ent._is_arrow
				and ent.name ~= "__builtin:item" then
					what_obj = ob
					what_is = "entity"
				end
			end

			if what_obj then

				if colbox then

					-- Object specific collision detection
					local p1, p2 = get_obj_box(what_obj)

					if pos_in_box(self.object:get_pos(), p1, p2) then

						on_hit_object(self, what_obj, self.dmg, self.user,
								self.object:get_pos())

						return self
					end
				else
					on_hit_object(self, what_obj, self.dmg, self.user,
							self.object:get_pos())

					return self
				end
			end
		end

		local vel = self.object:get_velocity()

		if vel.x == 0 or vel.y == 0 or vel.z == 0 then

			if bows.registed_arrows[self.name].on_hit_node then

				local pos = self.object:get_pos()
				local lastpos = {x = pos.x, y = pos.y, z = pos.z}

				pos.x = pos.x + (self.oldvel.x / 100)
				pos.y = pos.y + (self.oldvel.y / 100)
				pos.z = pos.z + (self.oldvel.z / 100)

				self.node = minetest.get_node(pos)

				bows.registed_arrows[self.name].on_hit_node(
						self, pos, self.user, lastpos)
			end

			on_hit_remove(self)

			return self
		end

		self.oldvel = vel
	end,
})
