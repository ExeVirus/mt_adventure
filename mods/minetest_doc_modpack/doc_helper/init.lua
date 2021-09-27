--See Readme.md for full use descriptions

--------------------------------
-- Builds a locale/templateDoc.txt for updating your template.txt
-- Then calls minetest_doc functions to add entries to the category
--
-- file_name.ent are doc.entries text files of name <file_name>
-- file_name.img are doc.entries img spec of name <file_name>
-- textures are assumed to be in the mod's texture folder and have no name collisions
-- the variable "path" is the path to these above mentioned .ent and .img files
-- Not every .ent needs an .img, but every .img needs an .ent

--helper functions
local MP = minetest.get_modpath(minetest.get_current_modname())
local util = assert(dofile(MP .. DIR_DELIM .. "utility.lua"))

--category is assumed to exist, and is a string
doc.build_entries = function(path, category)
	local modname = minetest.get_current_modname()
	local filelist = minetest.get_dir_list(path, false) --get all files
	
	for _, filename in pairs(filelist) do --for each file
		local extension = string.sub(filename, -3)
		if(extension == "ent") then --ent = entry
			util.generate_translations(modname, path, filename) --generates to modname/locale/templateDoc.txt
			util.create_entries(modname, path, filename, category) --generates entries for given category
		end
	end
end