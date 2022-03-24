# Storing Data for Mods in The Binding of Isaac: Repentance

## The Problem

Generically speaking, mods need to store data about entities in order to accomplish features that rely on stateful tracking. "Entities" include players, familiars, pickups, NPCs, and so on. However, storing data about entities is far from straightforward.

To start with, the game helpfully provides a `Entity.GetData` method to return a table that it keeps track of for each entity. You can add arbitrary keys and values to this table. And since it is a method of the `Entity` itself, you can somewhat-easily retrieve the data table in any particular callback that you want. At first glance, this seems like the obvious solution to this problem. Unfortunatly, `GetData` is unsuitable for the following reasons:

1. **The table is a global variable.** In other words, this means that other mods will get the same table, which can cause conflicts. It also means that other mods can modify or destroy your data. Carefully namespacing your variable names can mitigate this problem, but it's still not a good solution if you want your mod to be perfect.
1. **The table is ephemeral, meaning that when the entity despawns, the table will be deleted and you will lose your data.** For example, pickups are a type of entity that at first glance appears to be persistent. Meaning that when you get a heart drop in one room, you can backtrack to that room later, and the heart drop will still be there. However, behind the scenes, what is really happening is that the heart drop is despawned when you leave the room, and then a brand-new heart pickup entity is respawned when you re-enter the room. In this situation, if you had previously stored data on the `GetData` table of the heart pickup, the brand-new entity would not have this same data.
1. **Even for persistent entities like players and familiars, the table is ephemeral.** For example, a familiar is considered to be a truly "persistent" entity, unlike a heart drop. The familiar is never despawned; the same entity continues to exist as the player moves from room to room. Thus, the problem in the previous section would not apply to data stored in the `GetData` table for a familiar. However, once the player saves and quits and continues, the familiar will also be despawned in the exact same way that the heart drop was, and all of the data will be lost. Saving and quitting and continuing is a common strategy for players to reset a room, so any well-designed mod must be able to handle this case. (More generally, any well-designed mod should support someone quitting the game and then finishing the run at a later time.)

For these reasons, it is folly to use `GetData` for almost any reason. For small mods that don't care about being perfect, using `GetData` is fine when combined with proper variable namespacing, but only for data that doesn't need to persist beyond the current room or beyond a save & quit. For everyone else, just use a local variable instead.

Some mods attempt to work around problem #3 above by manually copying the `GetData` table into a local variable on `MC_PRE_GAME_EXIT`, and then using that as the basis for serialization in the "save#.dat" file. But notice that doing this is pointless - you can just store your data on a local variable to start with, and then all the code that transfers data in and out of the `GetData` table becomes superfluous and can be safely deleted.

<br>

## Indexing

Once you realize that you need to create your own data structures to store data about entities, the immediate next question is: what key/index do I use? The answer depends on the type of entity. Below, I'll enumerate some cases, starting from the least complex, to most complex.

<br>

### NPCs and Per-Room-Entities

The simplest case is for enemies and other non-persistent entities. For example, if you have a custom boss that has separate phases, you would keep track of the phase in a local variable. But if the player saved and quit and continued, then the boss would be refilled back to full health, and the state would be reset, just as if this was the first time the player was walking into the room.

For this case:
- You need to store variables on a table that is reset per room.
- You need to use a key/index of `PtrHash`. (You can get a `PtrHash` by using the global function `GetPtrHash`.)
- You need to use a value of a table/primitive containing your arbitrary data.

Note that:
- As the name implies, `PtrHash` is a pointer hash tied to the specific entity. Thus, in most cases, the lifetime of the index is per-room, or more specifically, whenever the entity despawns.
- Using `PtrHash` is better than using `Entity.Index`, since the latter will not work in some situations (e.g. when the entity is morphed).

<br>

### Familiars

By default, familiars are persistent, meaning that they will not despawn when the player leaves the room. Since `PtrHash` will not persist between saving and continuing, we can instead use `Entity.InitSeed`.

- In vanilla, no two familiars should ever have the same `InitSeed`, so this is a relatively safe index. (Using Box of Friends will result in familiars with brand-new seeds.)
- In mods, properly coded mods should also never have two familiars ever having the same `InitSeed`. However, due to bugs with the `EntityPlayer.CheckFamiliar` function, it is relatively common for mods to be poorly programed and spawn each of their familiars with the same `InitSeed`, which will break this indexing scheme. With that said, this probably remains the best indexing scheme, and the poorly-programmed-mods in question should update their code to fix the problem.

For this case:
- You need to store variables on a table that is reset per run.
- You need to use a key/index of `Entity.InitSeed`.
- You need to use a value of a table/primitive containing your arbitrary data.

<br>

### Dark Esau

Dark Esau is not a familiar, but he is persistent in an identical way that familiars are. You can also use `Entity.InitSeed` to index Dark Esau.

Note that when the player gets to a new floor, a new copy of Dark Esau will be spawned and it will have a different `InitSeed` than the one on the previous floor.

<br>

### Emulated Persistent Entities (One-per-Room)

By default, entities are not persistent, meaning that they will despawn when the player leaves the room. But you may have a custom entity that you want to *make* persistent to the specific room in the same way that a heart drop is. This means that you will have to keep track of the room and position, and then manually respawn it when the player re-enters the room.

For this case:
- You need to store variables on a table that is reset per level.
- You need to use a key/index of the `RoomDescriptor.ListIndex`.
- You need to use a value of a table containing the position of the entity and and other arbitrary data.

Note that:
- Using `RoomDescriptor.ListIndex` is better than using the `RoomDescriptor.GridIndex`, since the latter will result in bugs when the player enters an alternate dimension (such as the mirror world in Downpour 2).

<br>

### Players

In naive mods, information will only be stored about the first player. However, in order to be robust, mods must handle up to 4 players playing at the same time. But finding an good index player is difficult:

- We cannot use the index from `Isaac.GetPlayer(i)` since this fails in the case where there are two players and the first player leaves the run.
- We cannot use `EntityPlayer.ControllerIndex` as an index because it fails in the case of Jacob & Esau or Tainted Forgotten. It also fails in the case of a player changing their controls mid-run.
- We cannot use `EntityPlayer.GetData().index` because it does not persist across saving and continuing.
- We cannot use `GetPtrHash()` as an index because it does not persist across exiting and relaunching the game.
- We cannot use `EntityPlayer.InitSeed` because it is not consistent with additional players beyond the first.

Instead, we can use the `EntityPlayer.GetCollectibleRNG` method with an arbitrary value of `CollectibleType.COLLECTIBLE_SAD_ONION` (1). This works even if the player does not have any Sad Onions.

However, since the RNG value is the same for both Tainted Lazarus and Dead Tainted Lazarus, we need to revert to using the RNG of `CollectibleType.COLLECTIBLE_INNER_EYE` (2) for Dead Tainted Lazarus.

Note that since The Forgotten and The Soul also share the same RNG, they will have the same index. This is usually what is desired, since they share the same collectibles. However, if this is not desired, then you can use the RNG for `CollectibleType.COLLECTIBLE_SPOON_BENDER` (3) for The Soul.

All of this should be abstracted into a `getPlayerIndex` function. (In IsaacScript, this is included in the standard library.)

In conclusion, for this case:
- You need to store variables on a table that is reset per run.
- You need to use a key/index of `PlayerIndex` (which is the output of the `getPlayerIndex` function).
- You need to use a value of a table/primitive containing your arbitrary data.

<br>

### Pickups

As previously mentioned, pickups are non-persistent in that they are respawned every time the player re-enters the room. The naive solution of using `Entity.InitSeed` as an index does not work in this case because two or more pickups in the same room can share the same `InitSeed` (e.g. after using Diplopia, after using Crooked Penny). Furthermore, we cannot use `Entity.Position` as an index either, since pickups can move (e.g. a player pushing a heart drop when the player is already at full health, or a bomb explosion making the pickup move away from the explosion).

For this case, the easiest solution is to revert to using `PtrHash` for per-room data (in the same way that we would index a non-persistent NPC).

For the case of storing per-level data, you can use a 3-tuple of `RoomDescriptor.ListIndex`, `Entity.InitSeed`, and `Entity.Position`. However, for this to work, you must have code that runs on every frame to keep the data structure up-to-date by using a second data structure that maps pointer hashes to the reference tables. (Describing this in more detail is outside of the scope of this blog, as this method is non-trivial.)

<br>

### Collectibles

Collectibles are a special case of pickups in that they are (somewhat) stationary. Thus, we can index them by using a 4-tuple of `RoomDescriptor.ListIndex`, `GridIndex` (of the collectible inside of the room), `Entity.SubType`, and `Entity.InitSeed`.

The grid index is a necessary part of the tuple because Diplopia and Crooked Penny can cause two or more collectibles with the same `SubType` and `InitSeed` to exist in the same room. Unfortunately, this also means that this indexing scheme will fail in the case where the player uses Diplopia or a successful Crooked Penny seven or more times in the same room, since that will cause two or more collectibles with the same `GridIndex`, `SubType`, and `InitSeed` to exist.

The `SubType` is a necessary part of the collectible index because Tainted Isaac will continuously cause collectibles to morph into new sub-types with the same `InitSeed`.

Using `Entity.Position` as part of the index is problematic, since players can push a pedestal. (Even using the grid index does not solve this problem, since it is possible in certain cases for collectibles to be spawned at a position that is not aligned with the grid, and the pedestal can be pushed to an adjacent tile. But this case should be extremely rare.)

Mega Chests spawn two collectibles on the exact same position. However, both of them will have different `InitSeeds`, so this is not a problem for this indexing scheme.

If the collectible is inside of a Treasure Room, a different indexing scheem should be used in order to handle the case of the player seeing the same collectible again in a post-Ascent Treasure Room. For this case, you can use a 5-tuple of stage, stage type, `GridIndex`, `Entity.SubType`, and `Entity.InitSeed`. Note that:
- Using the `RoomDescriptor.ListIndex` or the `RoomDescriptor.GridIndex` is not suitable for this purpose, since both of these values can change in the post-Ascent Treasure Room.)
- Even though there can be two Treasure Rooms on an XL floor, both Treasure Rooms should not have collectibles with the same `GridIndex`, `Entity.SubType`, and `Entity.InitSeed`.

Also note that:
- Collectibles that are shifted by Tainted Isaac's mechanic will have unique collectible indexes because the `SubType` is different. (The collectible entities share the same `InitSeed`.)
- Collectibles that are rolled (with e.g. a D6) will have unique collectible indexes because both the `SubType` and `InitSeed` are different. If you want to track collectibles independently of any rerolls, then you can use the `PtrHash` as an index instead. (The `PtrHash` will not persist between rooms, however.)

All of this should be abstracted into a `getCollectibleIndex` function. (In IsaacScript, this is included in the standard library.)

In conclusion, for this case:
- You need to store variables on a table that is reset per run. (You can also reset it per level if do you want data to persist into a post-Ascent Treasure Room.)
- You need to use a key/index of `CollectibleIndex` (which is the output of the `getCollectibleIndex` function).
- You need to use a value of a table/primitive containing your arbitrary data.

### Summary

There is no universal scheme for indexing entities. In general, you should use `PtrHash` as an index, but specific kinds of entities require specific indexing schemes. Some indexing schemes are persistent, and some are not, so you must understand the trade-offs involved.

<br>

## Resetting Variables

Mod variables can be classified as falling under the 4 following categories:

1. `persistent` - Should never be automatically reset; all mutations are manual.
1. `run` - Should be reset at the beginning of every new run.
1. `level` - Should be reset at the beginning of every new level reached.
1. `room` - Should be reset at the beginning of every room entered.

When coding a larger mod with several features, it is helpful to provide an abstraction for this that mod-features can leverage.

The naive way to accomplish automatic variable resetting is to have a single `run`, `level`, and `room` table per-mod with some kind of "reset" function that restores every value to a pre-specified default. Then, all the features in the mod can stick their variables on this shared table. This is what I did in Racing+ for several years.

For more advanced users, you will want to do better than this:
- One problem with a shared table is that the variables are scoped incorrectly: every mod feature can mutate the variables of every other mod feature, which is the definition of spaghetti. It's also more difficult to read the code and understand the lifetime of a particular variable and see where it is used. Better to have all of the variables relating to item 1 be local to a file called "item1".
- The resetting functionality is per-mod. You have to reimplement the system in every new mod you create. And we know that when [we are repeating ourselves](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself), we need a better solution. This kind of functionality should be abstracted away into a library that any arbitrary mod can consume.

Thus, you can create a "save data manager" library that allows you to register arbitrary data, with sub-tables of `persistent`, `run`, `level`, or `room`. And the save data manager will automatically reset the variables at the appropriate times. Armed with this abstraction, writing mods becomes a lot easier. (In IsaacScript, this is included in the standard library.)

<br>

## Serialization Into the "save#.Dat" Files

Mods will contain a bunch of mod features, and each of these features is going to store stateful data. When the `MC_PRE_GAME_EXIT` callback fires, all of this data needs to be combined and written to disk.

The Isaac API offers a `Mod.SaveData` method to store data into the "save#.dat" file. Since this method takes a string, you must first convert all of your data to a string. The naive way to accomplish to have every variable in the mod live on a shared table, and then use the output of `json.encode` to store. Easy!

However, this strategy has a few gotchas. Anything that is a type of `userdata` won't be serialized properly, such as a `Color`, `RNG`, or `Vector`.

Serialization is a bit tricky. Booleans, strings, and numbers are fairly straightforward. But since mods will store tables within tables, we need to write a recursive deep-cloner that handles an arbitrary amount of depth.

as some things cannot be serialization, such as `EntityPtr`

Similar to automatic-variable-resetting in the previous section, this is also a task that you don't want to have to copy-paste into every mod that you write. Better to abstract this away and delegate it to a save data manager library that handles it automatically.

all of the variables for the features need to be combinedyou have a bunch of mod features that all contain their own state variables, and all of these need to be combined together and stored in the 

, and this is also a problem that is best delegated to a save data manager

<br>