minetest.register_on_mods_loaded(function()
	for name,value in pairs(minetest.registered_nodes) do
		if minetest.get_item_group(name, "plant") >= 1
			or minetest.get_item_group(name, "grass") >= 1
			or minetest.get_item_group(name, "dry_grass") >= 1
			or minetest.get_item_group(name, "flower") >= 1 and not value.on_flood then
			minetest.override_item(name, {
				floodable = true,
				on_flood = function(pos, oldnode, newnode)
					minetest.dig_node(pos)
				end,
			})
		end
	end
end)