# Cartographer
A Minetest mod that provides the necessary framework for crafting maps of the
local environment from various resources. The mod is structured as an API of
sorts, to allow it to be used with any game where such concepts are sensible.

## How to set up Cartographer
Since Cartographer is an API, it needs at least one additional mod in order to
function in your world. There are example mods available for Minetest Game and
Repixture, and you can make your own to extend these or support other games of
your choosing.

The process of making such a mod is pretty straightforward:
1. Register every biome in your game with cartographer, by calling `cartographer.biomes.add`, listing the biome, texture names to use for each detail level, and an optional min/max height for those textures to be used.
2. Register items/item groups that provide "paper" and "pigment" for mapmaking, by calling `cartographer.materials.register_by_name` or `cartographer.materials.register_by_group`. You can optionally specify how much of a material to provide per-item, or let it provide 1 unit by default.
3. Add crafting recipes or other ways of acquiring the following nodes:
    - cartographer:simple_table
    - cartographer:standard_table
    - cartographer:advanced_table
4. When integrating into a game, you can use `cartographer.skin` (skin_api.lua) to re-skin this mod's UI with your own textures and better integrate the mod with your art direction.

It's worth looking in the code to see what other options the cartographer API
offers. If your mod/game would benefit from another means of acquiring or
displaying maps, you can use the API to create your own crafting systems and
mapping items.

## Contact
For questions, requests, and other communications regarding this work, you can
contact the original creator at hugues.ross@gmail.com

# License
Cartographer's code is licensed under the GNU General Public License v3.0. A copy
of this license should be bundled with this work, if one was not provided then you
can find the license [here](https://www.gnu.org/licenses/gpl-3.0.html)

Cartographer's visual/audio assets are licensed under the Creative Commons
Attribution-ShareAlike 4.0 International License. A copy of this license should
be bundled with this work, if one was not provided then you can find the
license [here](https://creativecommons.org/licenses/by-sa/4.0/)
