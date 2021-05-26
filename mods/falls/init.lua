local settings = Settings(minetest.get_modpath('falls')..'/settings.txt')
local MP 	= minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP..'/intllib.lua')


dofile(MP..'/bucket_turbulent.lua')
if minetest.get_modpath("quartz") and minetest.get_modpath("moreores") and minetest.get_modpath("titanium") then
     dofile(MP..'/whirlpool.lua')
else
    minetest.log("Whirlpool Default Loaded")
     dofile(MP..'/whirlpool_default_only.lua')
end
dofile(MP..'/active_nodes.lua')
dofile(MP..'/lava_active_nodes.lua')