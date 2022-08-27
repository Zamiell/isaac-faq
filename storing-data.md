# Storing Data for Mods in The Binding of Isaac: Repentance

## The Problem

Generically speaking, mods need to store data about entities in order to accomplish features that rely on stateful tracking. "Entities" include players, familiars, pickups, NPCs, and so on. However, storing data about entities is far from straightforward.

To start with, the game helpfully provides a `Entity.GetData` method. This returns a table that is attached to each entity. You can add arbitrary keys and values to this table. And since it is a method of the `Entity` itself, you can somewhat-easily retrieve the data table in any particular callback that you want. At first glance, this seems like the obvious solution to this problem. Unfortunately, `GetData` is unsuitable for the following reasons:

1. **The table is a global variable.** In other words, this means that other mods will get the same table, which can cause conflicts. It also means that other mods can modify or destroy your data. Carefully namespacing your variable names can mitigate this problem, but it's still not a good solution if you want your mod to be perfect.
1. **The table is ephemeral, meaning that when the entity despawns, the table will be deleted and you will lose your data.** For example, pickups are a type of entity that at first glance appear to be persistent. Meaning that when you get a heart drop in one room, you can backtrack to that room later, and the heart drop will still be there. However, behind the scenes, what is really happening is that the heart drop is despawned when you leave the room, and then a brand-new heart pickup entity is respawned when you re-enter the room. In this situation, if you had previously stored data on the `GetData` table of the heart pickup, the brand-new entity would not have this same data.
1. **Even for persistent entities like players and familiars, the table is ephemeral.** For example, a familiar is considered to be a truly "persistent" entity, unlike a heart drop. The familiar is never despawned; the same entity continues to exist as the player moves from room to room. Thus, the problem in the previous section would not apply to data stored in the `GetData` table for a familiar. However, once the player saves and quits and continues, the familiar will also be despawned in the exact same way that the heart drop was, and all of the data will be lost. Saving and quitting and continuing is a common thing that people do in order to continue a run at a later time, so any well-designed mod should be able to handle this.

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
- Using `PtrHash` is better than using `Entity.Index`, since the latter will not work in some situations.

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

Note that since The Forgotten and The Soul also share the same RNG, they will have the same index. This is usually what is desired, since they share the same collectibles. However, if this is not desired, then you can use the RNG for `CollectibleType.COLLECTIBLE_INNER_EYE` (2) for The Soul.

All of this should be abstracted into a `getPlayerIndex` function so that you have a nice high-level API to work with. (In [IsaacScript](https://isaacscript.github.io/), this is included in the standard library.)

In conclusion, for this case:
- You need to store variables on a table that is reset per run.
- You need to use a key/index of `PlayerIndex` (which is the output of the `getPlayerIndex` function).
- You need to use a value of a table/primitive containing your arbitrary data.

<br>

### Pickups

As previously mentioned, pickups are non-persistent in that they are respawned every time the player re-enters the room. The naive solution of using `Entity.InitSeed` as an index does not work in this case because two or more pickups in the same room can share the same `InitSeed` (e.g. after using Diplopia, after using Crooked Penny).

Furthermore, we cannot use `Entity.Position` as an index either, since pickups can move (e.g. a player pushing a heart drop when the player is already at full health, or a bomb explosion making the pickup move away from the explosion). Pickups can also exist on the same position; this is the case for e.g. Mega Chest.

The solution is to create an arbitrary index for each pickup seen on the run, tracking information about each pickup index that has been created. This is the most complicated case, as unlike other indexing schemes, it requres stateful tracking per run.

The main data structure needed is a map of `PtrHash` to `PickupIndex` for the current room. This map is populated in the `POST_PICKUP_INIT` callback for brand new pickups. (`PickupIndex` assignment is arbitrary; I use a counter that represents the run order of the pickup.)

A secondary data structure with a type of `Map<RoomListIndex, Map<PickupIndex, PickupDescription>>` is also needed. This is populated in the `POST_ENTITY_REMOVE` callback when a player is leaving a room. `PickupDescription` is a tuple of `Position` and `InitSeed`. The point of this data structure is to store metadata about the pickup so that it can be re-identified if the player returns to the room.

To make things worse, there is also the special case of a post-Ascent Treasure Room or Boss Room to handle. In these rooms, the player will see pickups from previous floors, which means that extra information must be stored to handle this case. I use two extra maps (for Treasure Rooms and Boss Rooms, respectively) that are indexed by the `PickupDescription` tuple. These maps are only used in the specific fallback case where a normal pickup index was not found. (This scheme assumes that there will not be more than one pickup per run per room type with the same `Position` and `InitSeed`.)

All of this should be abstracted into a `getPickupIndex` function so that you have a nice high-level API to work with. (In [IsaacScript](https://isaacscript.github.io/), this is included in the standard library.)

<br>

## Indexing Summary

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
- The resetting functionality is per-mod. You have to re-implement the system in every new mod you create. And we know that when [we are repeating ourselves](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself), we need a better solution. This kind of functionality should be abstracted away into a library that any arbitrary mod can consume.

Thus, you can create a "save data manager" library that allows you to register arbitrary data, with sub-tables of `persistent`, `run`, `level`, or `room`. When the data comes into the manager, a deep-copy of the input is made, which serves as the default values. With the "default copy", the save data manager can automatically reset the variables at the appropriate times. Armed with this abstraction, writing mods becomes a lot easier. (But this is only the first half; also see the subsequent section.)

<br>

## Serialization Into the "save#.dat" Files

Mods will contain a bunch of mod features, and each of these features may store stateful data. When saving, all of this data needs to be combined and written to disk. And when loading, we need to restore all of the data from disk.

<br>

### When to Save Data

Data should be saved in the `MC_PRE_GAME_EXIT` callback. (You want to unconditionally save data, in order to handle the case of e.g. saving and quitting.)

Additionally, as an extra safety precaution, you can also save to disk at the beginning of each floor, which mimics what the game does internally (for the purposes of mitigating data loss from crashes). If you do this, remember to only do it on the second floor and onwards, as saving is expensive, and we definately don't need to save all the data back to disk immediately after reading it.

<br>

### When to Load Data

You will want to load data at the beginning of every run. The naive place to do that would be `MC_POST_GAME_STARTED`, but that won't work properly, as it runs after other callbacks have already executed, and you might have logic that relies on stateful tracking in those other callbacks.

Instead, you want to load data in `MC_POST_PLAYER_INIT`, which is the [earliest possible callback](https://wofsauge.github.io/IsaacDocs/rep/images/infographics/Isaac%20Callbacks.svg). Use a variable so that you do this at most once per run (since e.g. it will fire in a Genesis room, it will fire when another player joins the run). Remember to use `pcall`, as reading disk can randomly fail, and you don't want to stop the execution of logic for the rest of the callback. Additionally, end-user data can be garbage, so you want to fall back to sane defaults if so (e.g. `{}`).

<br>

### How to Save Data

The Isaac API offers a `Mod.SaveData` method to store data into a "save#.dat" file. Since this method takes a string, you must first convert all of your data to a string. The naive way to accomplish this is to have every variable in the mod live on a shared table, and then use `json.encode` to store it. And then you can use `json.decode` to restore it. Easy!

However, this strategy has a few gotchas:
- Anything that is a type of `userdata` won't be serialized properly, such as a `Color`, `RNG`, or `Vector`. So, with this strategy, you should avoid storing these objects directly in your saved data structures. However, this is kind of a pain, as working with vectors is extremely common, and it is easier to use `RNG` objects than seeds (since you don't have to `Next` them every time you use them).
- The JSON library is unable to distinguish between a map with number keys and an array. It will assume that both of these are an array. Thus, in the case of a map with number keys, it will insert `null` in every empty spot, leading to crashes. For example, a map with keys of 5 and 10 would be converted to the following array: `[null, null, null, null, "myValueForKey5", null, null, null, null, "myValueForKey10"]`. Many Isaac modders work around this problem by manually converting their map keys to strings, but this is a foot gun that can cause pain if you forget to do it. You shouldn't have to convert keys when working with your data structures - this is an implementation detail that can be abstracted away.

For more advanced users, you will want to do better than this:
- As explained in the previous section, we definitely don't want to have a gargantuan global table with every variable in it.
- We want to abstract serialization away into a library so that we don't have to copy-paste the same code into all of the mods that we write.
- Building on the previous section, once we have a save data manager that accomplishes automatic resetting, we already have the building blocks for a system that can just automatically dump everything that it manages into the "save#.dat" file at the appropriate times.
- The "deep-cloner" responsible for saving a copy of all of the default values can be extended to handle special cases of `Color`, `RNG`, and `Vector`, and serialize them appropriately.
- The "deep-cloner" can also properly handle converting maps with number keys to strings, which abstracts away the foot-gun.
- We can "brand" Lua tables with specific keys to denote situations where specific kinds of serialization has occurred, such as `__VECTOR` or `__MAP_WITH_NUMBER_KEYS`. During deserialization, we can use the brands to properly instantiate the respective object.
- We can throw a helpful runtime error if a mod feature tries to serialize an unserializable thing, like an `EntityPtr`.
- We can use the [json.lua](https://github.com/rxi/json.lua) library to get a speed up of around 11.8x.

Your end goal should try to be something that accomplishes all of the things that DeadInfinity outlines in [this GitHub issue](https://github.com/Meowlala/RepentanceAPIIssueTracker/issues/168).

It's worth noting that if you are use [IsaacScript](https://isaacscript.github.io/), you can avoid dealing with any of this since you can easily leverage the well-tested save data manager this is included in the standard library.

<br>
