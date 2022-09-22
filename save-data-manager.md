# Using the IsaacScript Save Data Manager

<br>

## What is the save data manager?

A save data manager is defined as a system that has the following two features:
- automatic resetting of variables on a new run, on a new level, or on a new room (as desired)
- automatic saving and loading of all tracked data to the "save#.dat" file

Isaac does not come with a save data manager, so I wrote my own and put it in the IsaacScript standard library. The IsaacScript save data manage also has some minor features, like automatic rewinding of variables when the Glowing Hour Glass is used, and proper serialization of the various Isaac userdata classes.

<br>

## Can the IsaacScript save data manager be used in Lua?

Yes. It can be used in both TypeScript and [Lua](https://isaacscript.github.io/main/isaacscript-in-lua).

<br>

## Why do I need the save data manager?

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

const modVanilla = RegisterMod("foo", 1);
const mod = upgradeMod(modVanilla);

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

local modVanilla = RegisterMod("foo", 1)
local mod = isc:upgradeMod(modVanilla)

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

Now, try running this simple mod. First, notice that the counters increase on every frame. (You can check the console to see the results of the `print` function.) Next, close the game and reopen it - the counters will resume right where they left off. It's really just as easy as that.

<br>

## What is the "v" object in the above example?

The object name of `v` is conventionally used to denote "variables". We abbreviate it to "v" so that it is nice and easy to type - we will be using this object a lot throughout our mod. We stick all of the state-related variables in our mod on "v", and the save data manager will manage them. (By "manage", we mean "automatically reset them and automatically save them to disk".)

(Note that in a real mod, you would have a separate `v` for each file or mod feature. The save data manager solves the scoping problem of having variables shared between your mod features. It will never share or expose the variables, so they can remain truly local to the file.)

`v` is composed of four different sub-objects, all of which are optional:
- `persistent`
- `run`
- `level`
- `room`

In the above example, we stuck the `myCounters` variable on a sub-object of `run`, meaning that the lifetime of the `myCounters` should be that of a run. When the player starts a new run, `myCounters` is automatically reset to the starting value (which we defined as 0).

If we had instead put it on a `level` object, then it would be wiped at the beginning of a new floor. And if we had instead put it on a `room` object, then it would be wiped at the beginning of a new room. And if we had instead put it on a `persistent` object, then it would never be reset at all.

<br>

## What does the `saveDataManager` function do?

For the save data manager to manage your variables, you need to give it your variables. The `saveDataManager` function will initialize the save data manager.

The first argument is the key. In the above example, we used "foo", which is the name of the mod. If you are storing variables for your entire mod in a single object, then use the name of your mod. (However, this is really bad, so for medium to large scale mods you should never do this and instead have many different `v` objects per file.)

The second argument is the save data object to manager, which will conventionally be called `v`, but can technically be called anything you want.

<br>

## What kinds of data can I put on my save data?

The save data manager supports most of what you will throw at it, but some things are not serializable, like `EntityPtr`. For a full list of supported data, see the [documentation for the `deepCopy` function](https://isaacscript.github.io/isaacscript-common/functions/deepCopy/#deepcopy).

<br>

## Where can I read more about the save data manager?

See the [official documentation](https://isaacscript.github.io/isaacscript-common/features/saveDataManager_exports/#savedatamanager) on the IsaacScript website.

<br>
