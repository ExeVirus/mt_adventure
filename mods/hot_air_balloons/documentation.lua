-- hot_air_balloons/documentation.lua

-----Load documentation via doc_helper------------------------
local MP = minetest.get_modpath(minetest.get_current_modname())
local docpath = MP .. DIR_DELIM .. "doc"
doc.add_category("hot_air_ballons",
{
	name = "_Hot Air Balloons_",
	description = "Hot Air Balloons",
	build_formspec = doc.entry_builders.text_and_square_gallery,
})
doc.build_entries(docpath, "hot_air_ballons")