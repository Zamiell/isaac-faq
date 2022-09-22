# Using the IsaacScript Save Data Manager

<br>

## What is the Save Data Manager?

A save data manager is defined as a system that has the following two features:
- automatic resetting of variables on a new run, on a new level, or on a new room (as desired)
- automatic saving and loading of all tracked data to the "save#.dat" file

Isaac does not come with a save data manager, so I wrote my own and put it in the IsaacScript standard library. The IsaacScript save data manage ralso has some minor features, like automatic rewinding of variables when the Glowing Hour Glass is used, and proper serialization of the various Isaac userdata classes.

<br>

## Can the IsaacScript save data manager be used in Lua?

Yes. It can be used in both TypeScript and [Lua](https://isaacscript.github.io/main/isaacscript-in-lua).

## Why do I need the Save Data Manager?

It is extremely common to have variables that need to be reset at the beginning of a new run, a new level, or a new room. For example, if you had a modded item that granted a damage up every time the player killed an enemey, then that variable would need to be reset at the beginning of every new run. The save data manager handles this for you automatically.

Furthermore, in Isaac, players have the ability to save and quit out of a run. If a player does that, all of your mod state should be serialized and saved to the disk, so that when they resume the run later, everything is exactly the way that it was before. Doing this correctly is pretty difficult, but the save data manager handles this for you automatically.

Even if you have already implemented your own save data system, you will still probably want to drop it and use the one in the standard library:
- You don't want to have to copy-paste your own boilerplate code into every single mod you write. This is the kind of thing that needs to be abstracted away into a library.
- The code in the standard library will almost certainly be better tested, handle more edge cases, and be more bug-free than anything you will write. (Does your system support serialization of BitSet128?)

Using the save data maanger is easy, as the rest of this document will show.

<br>

## What is the "hello world" for the save data manager?

In TypeScript:

```ts
import { saveDataManager } from "isaacscript-common";

const mod = RegisterMod("foo", 1);

const v = {
  run: {
    myCounters: 0,
  },
}

saveDataManager("foo", v);

mod.AddCallback(ModCallback.POST_UPDATE, () => {
  v.run.myCounters++;
  print(myCounters);
});
```

In Lua (almost exactly the same, sans the minor syntax differences):

```lua
local isc = require("foo.lib.isaacscript-common")

local mod = RegisterMod("foo", 1)

local v = {
  run = {
    myCounters: 0,
  },
}

isc:saveDataManager("foo", v)

mod.AddCallback(ModCallbacks.MC_POST_UPDATE, function()
  v.run.myCounters = v.run.myCounters + 1
  print(myCounters)
end)
```

Let's break this down.

The object name of `v` is conventionally used to denote "variables". In this example, we have a `v` object for the entire mod.

(In a real mod, you would have a separate `v` for each file or mod feature. The save data manager solves the scoping problem of having variables shared between your mod features.)

`v` is composed of sub-objects. By specifying a room sub-object, that tells the save data manager to automatically wipe the data in that sub-object when a new room is entered. This is what we want, because in this example, enemy NPCs will only exist in the context of the current room, and we don't care about keeping data for NPCs that have already despawned.

Finally, inside of the room sub-object, we define the fooData map. (If you don't know what a Map is, read the JavaScript/TypeScript tutorial, as understanding maps is essential for this section.) The fooData map is two-dimensional in that it will contain the data for every NPC in the room.

So, we need a way to identify each NPC in the room, and then use this identifier as the index in our map. The solution is to use the pointer hash, which a unique string that can be retrieved with the global function GetPtrHash:



Here is a more full example of a mod feature that uses RNG in a local variable that is automatically saved to disk when the player saves and quits the game:

```lua
local foo = {}

local v = {
  run = {
    rng = RNG(),
  },
}

function foo:init()
  isc:saveDataManager("foo", v)
end

function foo:postGameStarted()
  local seeds = isc.game:GetSeeds()
  local gameStartSeed = seeds:GetStartSeed()
  v.run.rng:SetSeed(gameStartSeed)
end

function foo:someCallback()
  local randomInt = isc:getRandomInt(2, 4, v.run.rng)
  -- TODO: use the random number
end

return foo
```

Or, here's the same code in TypeScript, which is mostly the same but is slightly shorter and more elegant:

```ts
const v = {
  run: {
    rng: RNG(),
  },
};

export function init() {
  saveDataManager("foo", v);
}

export function postGameStarted() {
  const seeds = game.GetSeeds();
  const gameStartSeed = seeds.GetStartSeed();
  v.run.rng.SetSeed(gameStartSeed);
}

export function someCallback() {
  const randomInt = getRandomInt(2, 4, v.run.rng);
  // TODO: use the random number
}
```
