## Sneeker mod for Minetest

---
### Description:

An explosive nuisance for [Minetest](http://minetest.net/).

![screenshot](screenshot.png)

---
### Licensing:

- Code: [MIT](LICENSE.txt)
  - Original by Rui: WTFPL
- tnt_function code: [MIT](tnt_function.lua)

---
### Usage:

Settings:
- ***sneeker.lifetime***
  - How long (in seconds) sneeker remains in world after spawn.
  - type: int
  - default: 900 (15 minutes)
- ***sneeker.boom_gain***
  - Loudness of explosion.
  - type: float
  - default: 1.5
- ***sneeker.spawn_require_player_nearby***
  - Determines whether or not a player must be close for spawn to occur.
  - type: bool
  - default: true
- ***sneeker.spawn_player_radius***
  - Distance a player must be within for spawn to occur.
  - type: int
  - default: 100
- ***sneeker.despawn_player_far***
  - If enabled, mobs not near any players will despawn.
  - type: bool
  - default: true
- ***sneeker.despawn_player_radius***
  - Distance determining if a player is near enough to prevent despawn.
  - type: int
  - default: 500
- ***sneeker.spawn_chance***
  - Sets possibility for spawn.
  - type: int
  - default: 10000
- ***sneeker.spawn_interval***
  - Sets frequency of spawn chance.
  - type: int
  - default: 240 (4 minutes)
- ***sneeker.spawn_minlight***
  - Sets the minimum light that a node must have for spawn to occur.
  - type: int
  - default: 0
- ***sneeker.spawn_maxlight***
  - Sets the maximum light that a node can have for spawn to occur.
  - type: int
  - default: 4
- ***sneeker.spawn_minheight***
  - Sets the maximum light that a node can have for spawn to occur.
  - type: int
  - default: -31000
- ***sneeker.spawn_maxheight***
  - Sets the lowest position at which sneeker can spawn.
  - type: int
  - default 31000
- ***sneeker.spawn_mapblock_limit***
  - Limits the number of entities that can spawn per mapblock (16x16x16).
  - type: int
  - default: 1

---
### Links:

- [Forum thread](https://forum.minetest.net/viewtopic.php?t=26685)
- [Original forum thread](https://forum.minetest.net/viewtopic.php?t=11891)
- [Git repo](https://github.com/AntumMT/mod-sneeker)
- [Reference](https://antummt.github.io/mod-sneeker/docs/api.html)
- [Changelog](CHANGES.txt)
- [TODO](TODO.txt)
