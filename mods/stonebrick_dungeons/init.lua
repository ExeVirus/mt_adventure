--[[
	Stonebrick Dungeons - Turns newly generated cobblestone dungeons into
	stonebrick.
	Copyright © 2017, 2020 Hamlet and contributors.

	Licensed under the EUPL, Version 1.2 or – as soon they will be
	approved by the European Commission – subsequent versions of the
	EUPL (the "Licence");
	You may not use this work except in compliance with the Licence.
	You may obtain a copy of the Licence at:

	https://joinup.ec.europa.eu/software/page/eupl
	https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32017D0863

	Unless required by applicable law or agreed to in writing,
	software distributed under the Licence is distributed on an
	"AS IS" basis,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
	implied.
	See the Licence for the specific language governing permissions
	and limitations under the Licence.

--]]


--
-- Constants
--

local f_DEFAULT_DELAY = 2.0
local i_DEFAULT_OFFSET = 22
-- See mapgen_v6.cpp 'room_size_large_max'.
-- See mapgen.cpp 'room_size_large_max'.

local b_DUNGEON_NOTIFY =
	minetest.settings:get_bool('stonebrick_dungeons_dungeon_notify', false)

local b_CHANGE_FLOOR =
	minetest.settings:get_bool('stonebrick_dungeons_change_floor', false)

local b_RANDOM_DUNGEON_SET =
	minetest.settings:get_bool('stonebrick_dungeons_random_set', false)

local b_USE_VOXEL_MANIPULATOR =
	minetest.settings:get_bool('stonebrick_dungeons_voxelmanip', true)

local f_REPLACEMENT_DELAY =
	minetest.settings:get('stonebrick_dungeons_delay') or f_DEFAULT_DELAY

local i_MAX_OFFSET =
	minetest.settings:get('stonebrick_dungeons_max_offset') or i_DEFAULT_OFFSET


--
-- Variables
--

local s_DungeonWall = ''
local s_DungeonInnerWall = ''
local s_DungeonColumn = ''
local s_DungeonStair = ''
local s_DungeonFloor = ''
local s_DungeonCeiling = ''


--
-- Functions
--

-- Used to determine whether if a node should be considered as 'air'.
local fn_ToBeIgnored = function(a_s_node_name)
	local t_IgnoreList = {
		'air',
		'default:snow',
		'default:chest',
		'default:mese_post_light',
		'default:water_source',
		'default:water_flowing',
		'default:river_water_source',
		'default:river_water_flowing',
		'default:lava_source',
		'default:lava_flowing'
	}
	local b_ToBeIgnored = false

	for i_Element = 1, #t_IgnoreList do
		if (b_ToBeIgnored == false) then
			if (a_s_node_name == t_IgnoreList[i_Element]) then
				b_ToBeIgnored = true
			end
		end
	end

	return b_ToBeIgnored
end


-- Used to determine a biome's name.
local fn_BiomeName = function(a_t_coordinates)
	local t_BiomeData = minetest.get_biome_data(a_t_coordinates)
	local s_BiomeName = minetest.get_biome_name(t_BiomeData.biome)

	return s_BiomeName
end


-- Used to determine whether if a dungeon should be ignored, that is, not using
-- default:cobble, default:mossycobble, stairs:stair_cobble and
-- stairs:stair_mossycobble.
local fn_IgnoreDungeon = function(a_s_biome_name)
	local b_IgnoreDungeon = false
	local t_IgnoredBiomes = {
		'desert',
		'desert_ocean',
		'icesheet',
		'icesheet_ocean',
		'icesheet_under',
		'sandstone_desert',
		'sandstone_desert_ocean'
	}

	for i_Element = 1, #t_IgnoredBiomes do
		if (b_IgnoreDungeon == false) then
			if (a_s_biome_name == t_IgnoredBiomes[i_Element]) then
				b_IgnoreDungeon = true
			end
		end
	end

	return b_IgnoreDungeon
end


-- Used to determine if a node belongs to the floor, a wall or to the ceiling
local fn_NodeType = function(a_t_node_coordinates)
	local t_NodeCoordinates = a_t_node_coordinates
	local t_NodeAboveCoordinates = {
		z = t_NodeCoordinates.z,
		y = (t_NodeCoordinates.y + 1),
		x = t_NodeCoordinates.x
	}
	local t_NodeBelowCoordinates = {
		z = t_NodeCoordinates.z,
		y = (t_NodeCoordinates.y - 1),
		x = t_NodeCoordinates.x
	}
	local t_NorthernNodeCoordinates = {
		z = (t_NodeCoordinates.z + 1),
		y = t_NodeCoordinates.y,
		x = t_NodeCoordinates.x
	}
	local t_EasternNodeCoordinates = {
		z = t_NodeCoordinates.z,
		y = t_NodeCoordinates.y,
		x = (t_NodeCoordinates.x + 1)
	}
	local t_SouthernNodeCoordinates = {
		z = (t_NodeCoordinates.z - 1),
		y = t_NodeCoordinates.y,
		x = t_NodeCoordinates.x
	}
	local t_WesternNodeCoordinates = {
		z = t_NodeCoordinates.z,
		y = t_NodeCoordinates.y,
		x = (t_NodeCoordinates.x - 1)
	}
	local s_NorthernNodeName =
		minetest.get_node(t_NorthernNodeCoordinates).name

	local s_EasternNodeName =
		minetest.get_node(t_EasternNodeCoordinates).name

	local s_SouthernNodeName =
		minetest.get_node(t_SouthernNodeCoordinates).name

	local s_WesternNodeName =
		minetest.get_node(t_WesternNodeCoordinates).name

	local s_NodeAboveName = minetest.get_node(t_NodeAboveCoordinates).name
	local s_NodeBelowName = minetest.get_node(t_NodeBelowCoordinates).name
	local s_NorthernNodeName =
		minetest.get_node(t_NorthernNodeCoordinates).name

	local s_EasternNodeName =
		minetest.get_node(t_EasternNodeCoordinates).name

	local s_SouthernNodeName =
		minetest.get_node(t_SouthernNodeCoordinates).name

	local s_WesternNodeName =
		minetest.get_node(t_WesternNodeCoordinates).name
	local s_NodeType = nil


	-- Flush the coordinates tables for memory saving.
	t_NodeAboveCoordinates = nil
	t_NodeBelowCoordinates = nil
	t_NorthernNodeCoordinates = nil
	t_EasternNodeCoordinates = nil
	t_SouthernNodeCoordinates = nil
	t_WesternNodeCoordinates = nil


	-- Determine the node type.
	if (fn_ToBeIgnored(s_NodeAboveName) == true)
	and (fn_ToBeIgnored(s_NodeBelowName) == false)
	and (fn_ToBeIgnored(s_NorthernNodeName) == false)
	and (fn_ToBeIgnored(s_EasternNodeName) == false)
	and (fn_ToBeIgnored(s_SouthernNodeName) == false)
	and (fn_ToBeIgnored(s_WesternNodeName) == false)
	then
		s_NodeType = 'floor'

	-- If the node is part of a wall, or a column.
	elseif (fn_ToBeIgnored(s_NodeAboveName) == false)
	and (fn_ToBeIgnored(s_NodeBelowName) == false)
	then
		-- Air on two opposite sides.
		-- Case number 1
		if (
			(fn_ToBeIgnored(s_NorthernNodeName) == true)
			and
			(fn_ToBeIgnored(s_SouthernNodeName) == true)
		)
		and (
			(fn_ToBeIgnored(s_EasternNodeName) == false)
			and
			(fn_ToBeIgnored(s_WesternNodeName) == false)
		)

		-- Case number 2
		or (
			(fn_ToBeIgnored(s_EasternNodeName) == true)
			and
			(fn_ToBeIgnored(s_WesternNodeName) == true)
		)
		and (
			(fn_ToBeIgnored(s_NorthernNodeName) == false)
			and
			(fn_ToBeIgnored(s_SouthernNodeName) == false)
		)

		-- Air on threee sides.
		-- Case number 1
		or (
			(fn_ToBeIgnored(s_NorthernNodeName) == true)
			and
			(fn_ToBeIgnored(s_SouthernNodeName) == true)
		)
		and (
			(fn_ToBeIgnored(s_EasternNodeName) == true)
			and
			(fn_ToBeIgnored(s_WesternNodeName) == false)
		)

		-- Case number 2
		or (
			(fn_ToBeIgnored(s_NorthernNodeName) == true)
			and
			(fn_ToBeIgnored(s_SouthernNodeName) == true)
		)
		and (
			(fn_ToBeIgnored(s_EasternNodeName) == false)
			and
			(fn_ToBeIgnored(s_WesternNodeName) == true)
		)

		-- Case number 3
		or (
			(fn_ToBeIgnored(s_EasternNodeName) == true)
			and
			(fn_ToBeIgnored(s_WesternNodeName) == true)
		)
		and (
			(fn_ToBeIgnored(s_NorthernNodeName) == true)
			and
			(fn_ToBeIgnored(s_SouthernNodeName) == false)
		)

		-- Case number 4
		or (
			(fn_ToBeIgnored(s_EasternNodeName) == true)
			and
			(fn_ToBeIgnored(s_WesternNodeName) == true)
		)
		and (
			(fn_ToBeIgnored(s_NorthernNodeName) == false)
			and
			(fn_ToBeIgnored(s_SouthernNodeName) == true)
		)

		then
			s_NodeType = 'inner_wall'

		-- Air on four sides.
		elseif (
				(fn_ToBeIgnored(s_NorthernNodeName) == true)
				and
				(fn_ToBeIgnored(s_EasternNodeName) == true)
				and
				(fn_ToBeIgnored(s_SouthernNodeName) == true)
				and
				(fn_ToBeIgnored(s_WesternNodeName) == true)
		)
		then
			s_NodeType = 'column'

		else
			s_NodeType = 'wall'

		end

	elseif (fn_ToBeIgnored(s_NodeBelowName) == true) then
		s_NodeType = 'ceiling'

	end

	return s_NodeType
end


--
-- Procedures
--

-- Minetest logger
local pr_LogMessage = function()

	-- Constant
	local s_LOG_LEVEL = minetest.settings:get('debug_log_level')

	-- Body
	if (s_LOG_LEVEL == nil)
	or (s_LOG_LEVEL == 'action')
	or (s_LOG_LEVEL == 'info')
	or (s_LOG_LEVEL == 'verbose')
	then
		minetest.log('action', '[Mod] Stonebrick Dungeons [v0.4.1] loaded.')
	end
end


-- Used to replace a node at a given position.
local pr_NodeReplacer = function(a_t_coordinates, a_s_replacer)
	minetest.set_node(a_t_coordinates, {name = a_s_replacer})
end


-- Used to replace a node at a given position.
-- Allows to keep the former node's metadata, for example a stair's rotation.
local pr_VoxelManipulator = function(a_t_coordinates, a_s_replacer)
	local VoxelManip = minetest.get_voxel_manip(a_t_coordinates,
		a_t_coordinates)

	local Data = VoxelManip:get_node_at(a_t_coordinates)
	Data.name = a_s_replacer

	VoxelManip:set_node_at(a_t_coordinates, Data)
	VoxelManip:write_to_map()
end


-- Used to choose a random nodes' set from the default ones.
local pr_RandomDungeonSet = function()
	local i_RandomNumber = math.random(1, 6)

	if (i_RandomNumber == 1) then
		s_DungeonWall = 'default:stonebrick'
		s_DungeonInnerWall = 'default:stonebrick'
		s_DungeonColumn = 'default:stonebrick'
		s_DungeonStair = 'stairs:stair_stonebrick'
		s_DungeonFloor = 'default:stone'
		s_DungeonCeiling = 'default:stone_block'

	elseif (i_RandomNumber == 2) then
		s_DungeonWall = 'default:desert_stonebrick'
		s_DungeonInnerWall = 'default:desert_stonebrick'
		s_DungeonColumn = 'default:desert_stonebrick'
		s_DungeonStair = 'stairs:stair_desert_stonebrick'
		s_DungeonFloor = 'default:desert_stone'
		s_DungeonCeiling = 'default:desert_stone_block'

	elseif (i_RandomNumber == 3) then
		s_DungeonWall = 'default:sandstonebrick'
		s_DungeonInnerWall = 'default:sandstonebrick'
		s_DungeonColumn = 'default:sandstonebrick'
		s_DungeonStair = 'stairs:stair_sandstonebrick'
		s_DungeonFloor = 'default:sandstone'
		s_DungeonCeiling = 'default:sandstone_block'

	elseif (i_RandomNumber == 4) then
		s_DungeonWall = 'default:desert_sandstone_brick'
		s_DungeonInnerWall = 'default:desert_sandstone_brick'
		s_DungeonColumn = 'default:desert_sandstone_brick'
		s_DungeonStair = 'stairs:stair_desert_sandstone_brick'
		s_DungeonFloor = 'default:desert_sandstone'
		s_DungeonCeiling = 'default:desert_sandstone_block'

	elseif (i_RandomNumber == 5) then
		s_DungeonWall = 'default:silver_sandstone_brick'
		s_DungeonInnerWall = 'default:silver_sandstone_brick'
		s_DungeonColumn = 'default:silver_sandstone_brick'
		s_DungeonStair = 'stairs:stair_silver_sandstone_brick'
		s_DungeonFloor = 'default:silver_sandstone'
		s_DungeonCeiling = 'default:silver_sandstone_block'

	elseif (i_RandomNumber == 6) then
		s_DungeonWall = 'default:obsidianbrick'
		s_DungeonInnerWall = 'default:obsidianbrick'
		s_DungeonColumn = 'default:obsidianbrick'
		s_DungeonStair = 'stairs:stair_obsidianbrick'
		s_DungeonFloor = 'default:obsidian'
		s_DungeonCeiling = 'default:obsidian_block'

	end
end


-- Used to select a default dungeon set depending on the biome.
local pr_BiomeDungeonSet = function(a_s_biome_name)
	if (a_s_biome_name == 'coniferous_forest')
	or (a_s_biome_name == 'coniferous_forest_dunes')
	or (a_s_biome_name == 'coniferous_forest_ocean')
	or (a_s_biome_name == 'coniferous_forest_under')
	or (a_s_biome_name == 'deciduous_forest')
	or (a_s_biome_name == 'deciduous_forest_shore')
	or (a_s_biome_name == 'deciduous_forest_ocean')
	or (a_s_biome_name == 'deciduous_forest_under')
	or (a_s_biome_name == 'grassland')
	or (a_s_biome_name == 'grassland_dunes')
	or (a_s_biome_name == 'grassland_ocean')
	or (a_s_biome_name == 'grassland_under')
	or (a_s_biome_name == 'rainforest')
	or (a_s_biome_name == 'rainforest_swamp')
	or (a_s_biome_name == 'rainforest_ocean')
	or (a_s_biome_name == 'rainforest_under')
	or (a_s_biome_name == 'savanna')
	or (a_s_biome_name == 'savanna_shore')
	or (a_s_biome_name == 'savanna_ocean')
	or (a_s_biome_name == 'savanna_under')
	or (a_s_biome_name == 'snowy_grassland')
	or (a_s_biome_name == 'snowy_grassland_ocean')
	or (a_s_biome_name == 'snowy_grassland_under')
	or (a_s_biome_name == 'taiga')
	or (a_s_biome_name == 'taiga_ocean')
	or (a_s_biome_name == 'taiga_under')
	or (a_s_biome_name == 'tundra')
	or (a_s_biome_name == 'tundra_highland')
	or (a_s_biome_name == 'tundra_beach')
	or (a_s_biome_name == 'tundra_ocean')
	or (a_s_biome_name == 'tundra_under')
	then
		s_DungeonWall = 'default:stonebrick'
		s_DungeonInnerWall = 'default:stonebrick'
		s_DungeonColumn = 'default:stonebrick'
		s_DungeonStair = 'stairs:stair_stonebrick'
		s_DungeonFloor = 'default:stone'
		s_DungeonCeiling = 'default:stone_block'

	elseif (a_s_biome_name == 'desert_under') then
		local i_RandomNumber = math.random(0, 1)

		if (i_RandomNumber == 0) then
			s_DungeonWall = 'default:desert_stonebrick'
			s_DungeonInnerWall = 'default:desert_stonebrick'
			s_DungeonColumn = 'default:desert_stonebrick'
			s_DungeonStair = 'stairs:stair_desert_stonebrick'
			s_DungeonFloor = 'default:desert_stone'
			s_DungeonCeiling = 'default:desert_stone_block'

		else
			s_DungeonWall = 'default:desert_sandstone_brick'
			s_DungeonInnerWall = 'default:desert_sandstone_brick'
			s_DungeonColumn = 'default:desert_sandstone_brick'
			s_DungeonStair = 'stairs:stair_desert_sandstone_brick'
			s_DungeonFloor = 'default:desert_sandstone'
			s_DungeonCeiling = 'default:desert_sandstone_block'

		end

	elseif (a_s_biome_name == 'sandstone_desert_under')   then
		s_DungeonWall = 'default:sandstonebrick'
		s_DungeonInnerWall = 'default:sandstonebrick'
		s_DungeonColumn = 'default:sandstonebrick'
		s_DungeonStair = 'stairs:stair_sandstonebrick'
		s_DungeonFloor = 'default:sandstone'
		s_DungeonCeiling = 'default:sandstone_block'

	elseif (a_s_biome_name == 'cold_desert')
	or (a_s_biome_name == 'cold_desert_ocean')
	or (a_s_biome_name == 'cold_desert_under')
	then
		local i_RandomNumber = math.random(0, 1)

		if (i_RandomNumber == 0) then
			s_DungeonWall = 'default:stonebrick'
			s_DungeonInnerWall = 'default:stonebrick'
			s_DungeonColumn = 'default:stonebrick'
			s_DungeonStair = 'stairs:stair_stonebrick'
			s_DungeonFloor = 'default:stone'
			s_DungeonCeiling = 'default:stone_block'

		else
			s_DungeonWall = 'default:silver_sandstone_brick'
			s_DungeonInnerWall = 'default:silver_sandstone_brick'
			s_DungeonColumn = 'default:silver_sandstone_brick'
			s_DungeonStair = 'stairs:stair_silver_sandstone_brick'
			s_DungeonFloor = 'default:silver_sandstone'
			s_DungeonCeiling = 'default:silver_sandstone_block'

		end
	end
end


local pr_DungeonModifier = function(a_t_dungeon_coordinates)

	-- Constants
	local s_COBBLE = 'default:cobble'
	local s_COBBLE_MOSSY = 'default:mossycobble'
	local s_STAIR_COBBLE = 'stairs:stair_cobble'
	local s_STAIR_COBBLE_MOSSY = 'stairs:stair_mossycobble'

	-- Variable
	local t_DungeonCoordinates = a_t_dungeon_coordinates

	-- Scan the area for the nodes to be replaced.
	for i_Element = 1, #t_DungeonCoordinates.dungeon do
		local s_NodeName = ''
		local t_CoordinatesCenter = t_DungeonCoordinates.dungeon[i_Element]
		local t_NodeCoordinates = {z = 0.0, y = 0.0, x = 0.0}

		--[[
		if (b_DUNGEON_NOTIFY == true) then
			pr_NodeReplacer(t_CoordinatesCenter, 'default:mese_post_light')
		end
		--]]

		for i_Value = -i_MAX_OFFSET, i_MAX_OFFSET do
			t_NodeCoordinates.z = (t_CoordinatesCenter.z + i_Value)

			for i_Value = -i_MAX_OFFSET, i_MAX_OFFSET do
				t_NodeCoordinates.y = (t_CoordinatesCenter.y + i_Value)

				for i_Value = -i_MAX_OFFSET, i_MAX_OFFSET do
					t_NodeCoordinates.x = (t_CoordinatesCenter.x + i_Value)

					local s_NodeName =
						minetest.get_node(t_NodeCoordinates).name

					-- If there's a match, substitute the node.
					if (s_NodeName == s_COBBLE)
					or (s_NodeName == s_COBBLE_MOSSY)
					then
						local s_NodeType = fn_NodeType(t_NodeCoordinates)

						if (s_NodeType == 'floor')
						and (b_CHANGE_FLOOR == true)
						then
							if (b_USE_VOXEL_MANIPULATOR == true) then
								pr_VoxelManipulator(t_NodeCoordinates,
									s_DungeonFloor)

							else
								pr_NodeReplacer(t_NodeCoordinates,
									s_DungeonFloor)

							end

						elseif (s_NodeType == 'wall') then
							if (b_USE_VOXEL_MANIPULATOR == true) then
								pr_VoxelManipulator(t_NodeCoordinates,
									s_DungeonWall)

							else
								pr_NodeReplacer(t_NodeCoordinates,
									s_DungeonWall)

							end

						elseif (s_NodeType == 'inner_wall') then
							if (b_USE_VOXEL_MANIPULATOR == true) then
								pr_VoxelManipulator(t_NodeCoordinates,
									s_DungeonInnerWall)

							else
								pr_NodeReplacer(t_NodeCoordinates,
									s_DungeonInnerWall)

							end

						elseif (s_NodeType == 'column') then
							if (b_USE_VOXEL_MANIPULATOR == true) then
								pr_VoxelManipulator(t_NodeCoordinates,
									s_DungeonColumn)

							else
								pr_NodeReplacer(t_NodeCoordinates,
									s_DungeonColumn)

							end

						elseif (s_NodeType == 'ceiling') then
							if (b_USE_VOXEL_MANIPULATOR == true) then
								pr_VoxelManipulator(t_NodeCoordinates,
									s_DungeonCeiling)

							else
								pr_NodeReplacer(t_NodeCoordinates,
									s_DungeonCeiling)

							end
						end
					end

					-- If there's a match, substitute the stair node.
					if (s_NodeName == s_STAIR_COBBLE)
					or (s_NodeName == s_STAIR_COBBLE_MOSSY)
					then
						pr_VoxelManipulator(t_NodeCoordinates, s_DungeonStair)
					end
				end
			end
		end
	end
end


--
-- Main body
--

-- Map manipulator

minetest.set_gen_notify('dungeon')

minetest.register_on_generated(function(minp, maxp, blockseed)
	local t_DungeonCoordinates = minetest.get_mapgen_object('gennotify')

	-- If the table is not empty
	if (t_DungeonCoordinates.dungeon) then
		local s_BiomeName = fn_BiomeName(t_DungeonCoordinates.dungeon[1])

		if (b_DUNGEON_NOTIFY == true) then
			local s_Message = 'Dungeon: ' ..
				minetest.pos_to_string(t_DungeonCoordinates.dungeon[1])

			minetest.chat_send_all(s_Message)
		end

		if (fn_IgnoreDungeon(s_BiomeName) == false) then
			if (b_RANDOM_DUNGEON_SET == true) then
				pr_RandomDungeonSet()

			else
				pr_BiomeDungeonSet(s_BiomeName)

			end

			minetest.after(f_REPLACEMENT_DELAY, function()
				pr_DungeonModifier(t_DungeonCoordinates)
			end)
		end
	end
end)


-- Minetest engine debug logging
pr_LogMessage()
