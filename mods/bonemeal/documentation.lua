-- bonemeal/documentation.lua

-----Load documentation via doc_helper------------------------
local MP = minetest.get_modpath(minetest.get_current_modname())
local docpath = MP .. DIR_DELIM .. "doc"
doc.add_category("bonemeal",
{
	name = "_Bonemeal_",
	description = "Bonemeal Documentation",
	build_formspec = doc.entry_builders.text_and_square_gallery,
})
doc.build_entries(docpath, "bonemeal")