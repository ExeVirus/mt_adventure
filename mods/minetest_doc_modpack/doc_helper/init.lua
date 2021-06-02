--See Readme.md for full use descriptions

--------------------------------
-- Builds a doc_helper.lua in the current mod directory
-- And then builds a locale_txt helper file.
-- The doc_helper.lua is loaded at the end of the function to actually load
-- the document
--
-- file_name.ent are doc.entries text files of name <file_name>
-- file_name.img are doc.entries img spec of name <file_name>
-- textures are assumed to be in the mod's texture folder and have no name collisions

--helper functions
local MP = minetest.get_modpath(minetest.get_current_modname())
local util = assert(dofile(MP .. DIR_DELIM .. "utility.lua"))

--category is assumed to exist
function doc.build_entries(folder_path, category)
	local modname = minetest.get_current_modname()
	local filelist = minetest.get_dir_list(folder_path, false) --get all files
	
	for _, filename in pairs(filelist) do --for each file
		local extension = string.sub(filename, -3)
		if(extension == "ent") then --ent = entry
			util.generate_translations(modname, folder_path, filename)
			util.create_entries(modname, folder_path, filename)
		end
	end
end

local docpath = MP .. DIR_DELIM .. "doc"
doc.build_entries(docpath, "doc_helper")
