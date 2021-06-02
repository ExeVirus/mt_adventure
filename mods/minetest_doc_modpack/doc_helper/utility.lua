local util = {}

local function delete_section(textDomain, file)
	local contents = file:read("*a")
	local endfile = file:seek("end")
	local remainder = ""
	local start
	local nex
	start,nex = string.find(contents, "# textdomain: " .. textDomain .. "[^#]*# textdomain: ")
	if(start == nil) then
		start,nex = string.find(contents, "# textdomain: " .. textDomain .. ".*")
		if(start ~= nil) then
			remainder = contents:sub(1,start-endfile-2) --write the beginning
			if(contents:sub(nex,-2) ~= "") then --if the rest of the file is not empty
				remainder = remainder .. contents:sub(nex-13) .. "\n" --output that as well
			end
		else
			remainder = contents
		end
	else
		remainder = contents:sub(1,start-endfile-2)
		if(contents:sub(nex,-2) ~= "") then
			remainder = contents:sub(nex-13) .. "\n"
		end
	end
	return remainder
end

-------------------------------
-- generate_translations
-- folder path is path to filename
-- filename is expected to be .ent
-- file should be only text, and
-- newlines
--------------------------------
util.generate_translations = function(modname, folder_path, filename)
	local filelines = io.lines(folder_path .. DIR_DELIM .. filename)
	local modpath = minetest.get_modpath(modname)
	minetest.mkdir(modpath .. DIR_DELIM .. "locale")
	local oldfile = assert(io.open(modpath .. DIR_DELIM .. "locale" .. DIR_DELIM .. "template.txt", "a+b"))
	--example: default_doc_wood
	local textDomain = modname .. "_doc_" .. string.sub(filename, 1, -5)
	--first delete the section, loading the remainder into tmpFile
	local remainder = delete_section(textDomain, oldfile)
	oldfile:close()
	--reopen in order to overwrite the file
	local newfile = assert(io.open(modpath .. DIR_DELIM .. "locale" .. DIR_DELIM .. "template.txt", "wb"))
	--write out the remainder after the deletion
	newfile:write(remainder)
	
	--Rewrite the textDomain (updated)
	newfile:write("# textdomain: " .. textDomain .. "\n")
	for line in filelines do
		newfile:write(line .. "=" .. "\n")
	end
	newfile:close()
end

--------------------------------
--
--
--
--
--------------------------------
util.create_entries = function(modname, folder_path, filename)

end

return util
