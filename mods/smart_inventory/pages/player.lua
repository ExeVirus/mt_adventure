smart_inventory.skins_mod = minetest.get_modpath("skinsdb")
smart_inventory.armor_mod = minetest.get_modpath("3d_armor")
smart_inventory.clothing_mod = minetest.get_modpath("clothing")

if not smart_inventory.skins_mod and
		not smart_inventory.armor_mod and
		not smart_inventory.clothing_mod then
	return
end

local filter = smart_inventory.filter
local cache = smart_inventory.cache
local ui_tools = smart_inventory.ui_tools
local txt = smart_inventory.txt

local function update_grid(state, listname)
	local player_has_creative = state.param.invobj:get_has_creative()
-- Update the users inventory grid
	local list = {}
	state.param["player_"..listname.."_list"] = list
	local name = state.location.rootState.location.player
	local player = minetest.get_player_by_name(name)
	local invlist_tab = {}
	if listname == "main" then
		local inventory = player:get_inventory()
		local invlist = inventory and inventory:get_list("main")
		table.insert(invlist_tab, invlist)
	else
		if smart_inventory.armor_mod then
			local inventory = minetest.get_inventory({type="detached", name=name.."_armor"})
			local invlist = inventory and inventory:get_list("armor")
			if invlist then
				table.insert(invlist_tab, invlist)
			end
		end
		if smart_inventory.clothing_mod then
			local clothing_meta = player:get_attribute("clothing:inventory")
			state.param.player_clothing_data = clothing_meta and minetest.deserialize(clothing_meta) or {}
			local invlist = {}
			for i=1,6 do
				table.insert(invlist, ItemStack(state.param.player_clothing_data[i]))
			end
			table.insert(invlist_tab, invlist)
		end
	end

	local list_dedup = {}
	for _, invlist in ipairs(invlist_tab) do
		for stack_index, stack in ipairs(invlist) do
			local itemdef = stack:get_definition()
			local is_armor = false
			if itemdef then
				cache.add_item(itemdef) -- analyze groups in case of hidden armor
				if cache.citems[itemdef.name].cgroups["armor"] or cache.citems[itemdef.name].cgroups["clothing"] then
					local entry = {}
					for k, v in pairs(cache.citems[itemdef.name].ui_item) do
						entry[k] = v
					end
					entry.stack_index = stack_index
					local wear = stack:get_wear()
					if wear > 0 then
						entry.text = tostring(math.floor((1 - wear / 65535) * 100 + 0.5)).." %"
					end
					table.insert(list, entry)
					list_dedup[itemdef.name] = itemdef
				end
			end
		end
	end

	-- add all usable in creative available armor to the main list
	if listname == "main" and player_has_creative == true then
		if smart_inventory.armor_mod then
			for _, itemdef in pairs(cache.cgroups["armor"].items) do
				if not list_dedup[itemdef.name] and not itemdef.groups.not_in_creative_inventory then
					list_dedup[itemdef.name] = itemdef
					table.insert(list, cache.citems[itemdef.name].ui_item)
				end
			end
		end
		if smart_inventory.clothing_mod then
			for _, itemdef in pairs(cache.cgroups["clothing"].items) do
				if not list_dedup[itemdef.name] and not itemdef.groups.not_in_creative_inventory then
					list_dedup[itemdef.name] = itemdef
					table.insert(list, cache.citems[itemdef.name].ui_item)
				end
			end
		end
	end

	local grid = state:get(listname.."_grid")
	grid:setList(list)
end

local function update_selected_item(state, listentry)
	local name = state.location.rootState.location.player
	state.param.armor_selected_item = listentry or state.param.armor_selected_item
	listentry = state.param.armor_selected_item
	if not listentry then
		return
	end
	local i_list = state:get("i_list")
	i_list:clearItems()
	for _, groupdef in ipairs(ui_tools.get_tight_groups(cache.citems[listentry.itemdef.name].cgroups)) do
		i_list:addItem(groupdef.group_desc)
	end
	state:get("item_name"):setText(listentry.itemdef.description)
	state:get("item_image"):setImage(listentry.item)
end

local function update_page(state)
	local name = state.location.rootState.location.player
	local player_obj = minetest.get_player_by_name(name)
	local skin_obj = smart_inventory.skins_mod and skins.get_player_skin(player_obj)

	-- Update grid lines
	if smart_inventory.armor_mod or smart_inventory.clothing_mod then
		update_grid(state, "main")
		update_grid(state, "overlay")
	end

	-- Update preview area and armor informations list
	if smart_inventory.armor_mod then
		state:get("preview"):setImage(armor.textures[name].preview)
		state.location.parentState:get("player_button"):setImage(armor.textures[name].preview)
		local a_list = state:get("a_list")
		a_list:clearItems()
		for k, v in pairs(armor.def[name]) do
			local grouptext
			if k == "groups" then
				for gn, gv in pairs(v) do
					if txt and txt["armor:"..gn] then
						grouptext = txt["armor:"..gn]
					else
						grouptext = "armor:"..gn
					end
					if grouptext and gv ~= 0 then
						a_list:addItem(grouptext..": "..gv)
					end
				end
			else
				local is_physics = false
				for _, group in ipairs(armor.physics) do
					if group == k then
						is_physics = true
						break
					end
				end
				if is_physics then
					if txt and txt["physics:"..k] then
						grouptext = txt["physics:"..k]
					else
						grouptext = "physics:"..k
					end
					if grouptext and v ~= 1 then
						a_list:addItem(grouptext..": "..v)
					end
				else
					if txt and txt["armor:"..k] then
						grouptext = txt["armor:"..k]
					else
						grouptext = "armor:"..k
					end
					if grouptext and v ~= 0 then
						if k == "state" then
							a_list:addItem(grouptext..": "..tostring(math.floor((1 - v / armor.def[name].count / 65535) * 100 + 0.5)).." %")
						else
							a_list:addItem(grouptext..": "..v)
						end
					end
				end
			end
		end
		update_selected_item(state)
	elseif skin_obj then
		local skin_preview = skin_obj:get_preview()
		state.location.parentState:get("player_button"):setImage(skin_preview)
		state:get("preview"):setImage(skin_preview)
	elseif smart_inventory.clothing_mod then
		update_selected_item(state)
		state.location.parentState:get("player_button"):setImage('inventory_plus_clothing.png')
		state:get("preview"):setImage('blank.png') --TODO: build up clothing preview
	end

	-- Update skins list and skins info area
	if skin_obj then
		local m_name = skin_obj:get_meta_string("name")
		local m_author = skin_obj:get_meta_string("author")
		local m_license = skin_obj:get_meta_string("license")
		if m_name then
			state:get("skinname"):setText("Skin name: "..(skin_obj:get_meta_string("name")))
		else
			state:get("skinname"):setText("")
		end
		if m_author then
			state:get("skinauthor"):setText("Author: "..(skin_obj:get_meta_string("author")))
		else
			state:get("skinauthor"):setText("")
		end
		if m_license then
			state:get("skinlicense"):setText("License: "..(skin_obj:get_meta_string("license")))
		else
			state:get("skinlicense"):setText("")
		end

		-- set the skins list
		state.param.skins_list = skins.get_skinlist_for_player(name)
		local cur_skin = skins.get_player_skin(player_obj)
		local skins_grid_data = {}
		local grid_skins = state:get("skins_grid")
		for idx, skin in ipairs(state.param.skins_list) do
			table.insert(skins_grid_data, {
					image = skin:get_preview(),
					tooltip = skin:get_meta_string("name"),
					is_button = true,
					size = { w = 0.87, h = 1.30 }
			})
			if not state.param.skins_initial_page_adjusted and skin:get_key() == cur_skin:get_key() then
				grid_skins:setFirstVisible(idx - 19) --8x5 (grid size) / 2 -1
				state.param.skins_initial_page_adjusted = true
			end
		end
		grid_skins:setList(skins_grid_data)
	end
end

local function move_item_to_armor(state, item)
	local player_has_creative = state.param.invobj:get_has_creative()
	local name = state.location.rootState.location.player
	local player = minetest.get_player_by_name(name)
	local inventory = player:get_inventory()
	local armor_inv = minetest.get_inventory({type="detached", name=name.."_armor"})

	-- get item to be moved to armor inventory
	local itemstack, itemname, itemdef
	if player_has_creative == true then
		itemstack = ItemStack(item.item)
		itemname = item.item
	else
		itemstack = inventory:get_stack("main", item.stack_index)
		itemname = itemstack:get_name()
	end
	itemdef = minetest.registered_items[itemname]
	local new_groups = {}
	for _, element in ipairs(armor.elements) do
		if itemdef.groups["armor_"..element] then
			new_groups["armor_"..element] = true
		end
	end

	-- remove all items with the same group
	local removed_items = {}
	for stack_index, stack in ipairs(armor_inv:get_list("armor")) do
		local old_def = stack:get_definition()
		if old_def then
			for groupname, groupdef in pairs(old_def.groups) do
				if new_groups[groupname] then
					table.insert(removed_items, stack)
					armor_inv:set_stack("armor", stack_index, {}) --take old
					minetest.detached_inventories[name.."_armor"].on_take(armor_inv, "armor", stack_index, stack, player)
					if armor_inv:set_stack("armor", stack_index, itemstack) then --put new
						minetest.detached_inventories[name.."_armor"].on_put(armor_inv, "armor", stack_index, itemstack, player)
						itemstack = ItemStack("")
					end
				end
			end
		end
		if stack:is_empty() and not itemstack:is_empty() then
			if armor_inv:set_stack("armor", stack_index, itemstack) then
				minetest.detached_inventories[name.."_armor"].on_put(armor_inv, "armor", stack_index, itemstack, player)
				itemstack = ItemStack("")
			end
		end
	end

	-- handle put backs in non-creative to not lost items
	if player_has_creative == false then
		inventory:set_stack("main", item.stack_index, itemstack)
		for _, stack in ipairs(removed_items) do
			stack = inventory:add_item("main", stack)
			if not stack:is_empty() then
				armor_inv:add_item("armor", stack)
			end
		end
	end
end

local function move_item_to_clothing(state, item)
	local name = state.location.rootState.location.player
	local player = minetest.get_player_by_name(name)
	local inventory = player:get_inventory()

	local clothes = state.param.player_clothing_data
	local clothes_ordered = {}

	for i=1, 6 do
		if clothes[i] then
			table.insert(clothes_ordered, clothes[i])
		end
	end

	if #clothes_ordered < 6 then
		table.insert(clothes_ordered, item.item)
		player:set_attribute("clothing:inventory", minetest.serialize(clothes_ordered))
		clothing:set_player_clothing(player)
		state.param.player_clothing_data = clothes_ordered
		-- handle put backs in non-creative to not lost items
		if player_has_creative == false then
			local itemstack = inventory:get_stack("main", item.stack_index)
			itemstack:take_item()
			inventory:set_stack("main", item.stack_index, itemstack)
		end
	end
end

local function move_item_to_inv(state, item)
	local player_has_creative = state.param.invobj:get_has_creative()
	local name = state.location.rootState.location.player
	local player = minetest.get_player_by_name(name)
	local inventory = player:get_inventory()

	if cache.cgroups["armor"] and cache.cgroups["armor"].items[item.item] then
		local armor_inv = minetest.get_inventory({type="detached", name=name.."_armor"})
		local itemstack = armor_inv:get_stack("armor", item.stack_index)
		if player_has_creative == true then
			-- trash armor item in creative
			itemstack = ItemStack("")
		else
			itemstack = inventory:add_item("main", itemstack)
		end
		armor_inv:set_stack("armor", item.stack_index, itemstack)
		minetest.detached_inventories[name.."_armor"].on_take(armor_inv, "armor", item.stack_index, itemstack, player)

	elseif cache.cgroups["clothing"] and cache.cgroups["clothing"].items[item.item] then
		local clothes = state.param.player_clothing_data

		if player_has_creative ~= true and clothes[item.stack_index] then
			local itemstack = inventory:add_item("main", ItemStack(clothes[item.stack_index]))
			if itemstack:is_empty() then
				clothes[item.stack_index] = nil
			end
		else
			clothes[item.stack_index] = nil
		end
		player:set_attribute("clothing:inventory", minetest.serialize(clothes))
		clothing:set_player_clothing(player)
	end

end

local function player_callback(state)
	local name = state.location.rootState.location.player
	state:background(0, 1.2, 6, 6.6, "it_bg", "smart_inventory_background_border.png")
	state:item_image(0.8, 1.5,2,2,"item_image","")
	state:label(2.5,1.2,"item_name", "")
	state:listbox(0.8,3.3,5.1,4,"i_list", nil, true)

	state:background(6.2, 1.2, 6, 6.6, "pl_bg", "smart_inventory_background_border.png")
	state:image(6.7,1.7,2,4,"preview","")
	state:listbox(8.6,1.7,3.5,3,"a_list", nil, true)
	state:label(6.7,5.5,"skinname","")
	state:label(6.7,6.0,"skinauthor", "")
	state:label(6.7,6.5, "skinlicense", "")

	state:background(0, 0, 20, 1, "top_bg", "halo.png")
	state:background(0, 8, 20, 2, "bottom_bg", "halo.png")
	if smart_inventory.armor_mod or smart_inventory.clothing_mod then
		local grid_overlay = smart_inventory.smartfs_elements.buttons_grid(state, 0, 0, 20, 1, "overlay_grid")

		grid_overlay:onClick(function(self, state, index, player)
			if state.param.player_overlay_list[index] then
				update_selected_item(state, state.param.player_overlay_list[index])
				move_item_to_inv(state, state.param.player_overlay_list[index])
				update_page(state)
			end
		end)

		local grid_main = smart_inventory.smartfs_elements.buttons_grid(state, 0, 8, 20, 2, "main_grid")
		grid_main:onClick(function(self, state, index, player)
			update_selected_item(state, state.param.player_main_list[index])
			local item = state.param.player_main_list[index]
			if cache.citems[item.item].cgroups["armor"] then
				move_item_to_armor(state, state.param.player_main_list[index])
			elseif cache.citems[item.item].cgroups["clothing"]  then
				move_item_to_clothing(state, state.param.player_main_list[index])
			end
			update_page(state)
		end)
	end

	if smart_inventory.skins_mod then
		local player_obj = minetest.get_player_by_name(name)
		-- Skins Grid
		local grid_skins = smart_inventory.smartfs_elements.buttons_grid(state, 12.9, 1.5, 7 , 7, "skins_grid", 0.80, 1.20)
		state:background(12.4, 1.2, 7.5 , 6.6, "bg_skins", "smart_inventory_background_border.png")
		grid_skins:onClick(function(self, state, index, player)
			local cur_skin = state.param.skins_list[index]
			if state.location.rootState.location.type ~= "inventory" and cur_skin._key:sub(1,17) == "character_creator" then
				state.location.rootState.obsolete = true  -- other screen appears, obsolete the inventory session
			end
			skins.set_player_skin(player_obj, cur_skin)
			if smart_inventory.armor_mod then
				armor.textures[name].skin = cur_skin:get_texture()
				armor:set_player_armor(player_obj)
			end
			update_page(state)
		end)
	end

	-- not visible update plugin for updates from outsite (API)
	state:element("code", { name = "update_hook" }):onSubmit(function(self, state)
		update_page(state)
		state.location.rootState:show()
	end)

	update_page(state)
end

smart_inventory.register_page({
	name = "player",
	icon = "player.png",
	tooltip = "Customize yourself",
	smartfs_callback = player_callback,
	sequence = 20,
	on_button_click = update_page
})

-- register callback in 3d_armor for updates
if smart_inventory.armor_mod and armor.register_on_update then

	local function submit_update_hook(player)
		local name = player:get_player_name()
		local state = smart_inventory.get_page_state("player", name)
		if state then
			state:get("update_hook"):submit()
		end
	end

	armor:register_on_update(submit_update_hook)

	-- There is no callback in 3d_armor for wear change in on_hpchange implementation
	minetest.register_on_player_hpchange(function(player, hp_change)
		minetest.after(0, submit_update_hook, player)
	end)
end
