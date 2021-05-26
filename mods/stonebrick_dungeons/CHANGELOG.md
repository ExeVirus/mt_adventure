# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/).


## [Unreleased]

	- Improve the detection of the logic nodes.
	- Allow the customization of the dungeon styles via the Settings menu.


## [0.4.1] - 2020-07-02
## Changed

	- Minor code improvements.



## [0.4.0] - 2020-04-13
### Added

	- All Settings -> Mod -> stonebrick_dungeons
	- Option to keep the existing cobblestone floor.
	- Six predefined dungeon styles using the default MaterialName_brick, MaterialName_block, etc. ranging from stone to obsidian.
	- Option to choose whether if dungeons' style should be random or biome-based; the latter excludes obsidian dungeons.
	- Biome check to prevent useless scanning on dungeons not using cobblestone nodes; examples: ice-dungeons, sandstone-brick dungeons.
	- Option to select the preferred node replacement method; default: VoxelManipulator, optional: minetest.set_node.

### Changed

	- Nodes' replacement occurs using VoxelManip instead of set_node, by default.

### Removed

	- Support for Castle Masonry.



## [0.3.1] - 2020-04-10
### Changed

	- Disabled debug message.



## [0.3.0] - 2019-12-20
### Added

	- Replacement will occur only on dungeon generation notification, and only in that area.

### Changed

	- License changed to EUPL v1.2.
	- Code rewritten from scratch.



## [0.2.2] - 2018-05-13
### Removed

	- Useless modpath variable



## [0.2.1] - 2018-04-21
### Added

	- ../doc/


### Changed

	- depends.txt added missing dependency on "stairs"
