# Mod Oragnization

This is a short blog about how to organize a big Isaac mod - one that has thousands of lines of code and is written by an experienced programmer. The principles are agnostic in that they equally apply to a mod written in TypeScript or a mod written in Lua.

Software has the problem where if you keep on adding things to it, eventually it becomes a Frankenstein monster - hard to manage and hard to understand. It is helpful to keep your mod code nice and organized so that it never reaches a state of unmaintainable spaghetti.

Small mods can be written in a single file - `main.ts` (for TypeScript) or `main.lua` (for Lua). But for bigger mods, you will want to split up your code into different files. For example, it makes sense for a mod pack that contains 10 items to have all of the code for each individual item live in a file dedicated to just that item. That way, you can leverage the `Ctrl + p` hotkey in VSCode to jump to the exact spot that you need to go. And if you need to fix a bug with item 1, then you don't have to go on a scavenger hunt throughout the entire repository - you can just focus all of your attention on the file called `item1.ts`.

And if an item/feature file has so much code that it gets to be 500-1000 lines, then consider splitting up that file into multiple files. Instead of having a file called `item1.ts`, you can have a directory called `item1` with child files based on the originating callback or some other distinguishing attribute.

But how do you glue it all together? There are two good ways to organize a bigger mod.

<br />

## 1) Dependency Injection

Use depedency injection and have all callback registration happen in the files dedicated to the item/feature.

This looks like:

```ts
// main.ts

import * as item1 from "./items/item1";

const mod = RegisterMod("My Mod", 1);

item1.init(mod);
```

```ts
// item1.ts

export function init(mod: Mod): void {
  mod.AddCallback(ModCallbacks.MC_UPDATE, postUpdate);  
}

function postUpdate() {
  // Code here
}
```

Or, in Lua:

```lua
-- main.lua

local item1 = require("mymod.items.item1")

local mod = RegisterMod("My Mod", 1)

item1:init(mod)
```

```lua
-- item1.lua

local item1 = {}

function item1:init(mod)
  mod:AddCallback(ModCallbacks.MC_UPDATE, item1.postUpdate)
end

function item1:postUpdate()
  -- Code here
end

return item1
```

<br />

## 2) Callback Files

Have a separate file per callback that calls out to the individual mod features.

This looks like:

```ts
// main.ts

import * as postUpdate from "./callbacks/postUpdate";

const mod = RegisterMod("My Mod", 1);

mod.AddCallback(ModCallbacks.POST_UPDATE, postUpdate.main);
```

```ts
// postUpdate.ts

import * as item1 from "../items/item1";

export function main(): void {
  item1.postUpdate();
}
```

```ts
// item1.ts

export function postUpdate(): void {
  // Code here
}
```

Or, in Lua:

```lua
-- main.lua

local postUpdate = require("myMod.callbacks.postUpdate")

local mod = RegisterMod("My Mod", 1)

mod:AddCallback(ModCallbacks.POST_UPDATE, postUpdate.main)
```

```lua
-- postUpdate.lua

local postUpdate = {}

local item1 = require("myMod.items.item1")

function postUpdate:main()
  item1:postUpdate()
end

return postUpdate
```

```lua
-- item1.lua

local item1 = {}

function item1:postUpdate()
  -- Code here
end

return item1
```

In this way, we only register one callback function per callback.

One advantage of having two degrees of hierarchy is that you can more easily control the *order* of feature execution. This can be important for bigger mods. As a toy example, say that one item/feature takes away all items from a player at the beginning of a run, and another item/feature adds items to a player at the beginning of a run. In this case, you would need to ensure that the former feature is executed last. It's easy to accomplish this in a callback file.

Another advantage of having two degrees of hierarchy is that the execution flow is easier to analyze and troubleshoot. Inevitably, you will need to troubleshoot problems in your mod. By commenting out functions in a specific callback file, you have more fine grained control than by simply disabling the initialization of an entire item/feature.

Using TypeScript compliments this strategy because it ensures that everything glues together properly.

<br />

## 2a) Callback Files with Dependency Injection for Callbacks with Optional Arguments

In your mod, you might want to take advantage of the "optional arguments" feature of the Isaac callbacks. However, we still want to contain all of the logic for a particular callback inside the file dedicated to that callback. So we can use dependency injection for this.

```ts
// main.ts

import postEntityKillInit from "./callbacks/postEntityKill";

const mod = RegisterMod("My Mod", 1);

postEntityKillInit(mod);
```

```ts
// postEntityKill.ts

import * as item1 from "../items/item1";
import * as item2 from "../items/item2";

export default function postEntityKillInit(mod: Mod): void {
  mod.AddCallback(
    ModCallbacks.MC_POST_ENTITY_KILL,
    main,
  );

  mod.AddCallback(
    ModCallbacks.MC_POST_ENTITY_KILL,
    mom,
    EntityType.ENTITY_MOM,
  );
}

function main(entity: Entity) {
  item1.postEntityKill(entity);
}

function mom(entity: Entity) {
  item2.postEntityKillMom(entity);
}
```

Or, in Lua:

```lua
-- main.lua

local postEntityKill = require("myMod.callbacks.postEntityKill")

local mod = RegisterMod("My Mod", 1);

postEntityKill.init(mod);
```

```lua
-- postEntityKill.lua

local postEntityKill = {}

local item1 = require("myMod.items.item1")
local item2 = require("myMod.items.item2")

function postEntityKill:init(mod)
  mod.AddCallback(
    ModCallbacks.MC_POST_ENTITY_KILL,
    postEntityKill.main
  )

  mod.AddCallback(
    ModCallbacks.MC_POST_ENTITY_KILL,
    postEntityKill.mom,
    EntityType.ENTITY_MOM
  )
end

function postEntityKill:main(entity)
  item1:postEntityKill(entity)
end

function postEntityKill:mom(entity)
  item2:postEntityKillMom(entity)
end
```

In general, I recommend that you use this strategy in your Isaac mods. It provides a nice separation of conerns and makes the code very easy to understand. Of course, every mod is unique, so you should think about a hierarchy that works for best your particular mod.

<br />

## Naming Feature Functions

In Isaac, callbacks are the root of nearly all code. So, when opening up a feature file, make the path to the function clear to the reader - name it **exactly** after the name of the calling callback function:

```lua
-- item1.lua

local item1 = {}

function item1:postUpdate()
  item1:doThing1()
  item2:doThing1()
  item3:doThing1()
end

function item1:doThing1()
  -- Code here
end

function item1:doThing2()
  -- Code here
end

function item1:doThing3()
  -- Code here
end

return item1
```

By looking at this file, I can immediately tell that this code is invoked from the `MC_POST_UPDATE` callback. I don't have to go on a scavenger hunt to find out exactly the situations that this code can run in.

<br />

### Use Functions to Provide a High-Level Inventory

There's a separate thing about the previous code-snippet to point out. Notice that the `postUpdate()` function provides a high-level inventory of the things that happen in the postUpdate callback. In other words, this function immediately tells us that three different things happen on every frame. But we don't have to read through hundreds of lines of code in order to find out *what* happens on every frame - we can instead read the nice little summary that it provides. As a reader, we don't have to bother wading into any of these child functions if we don't want to - all of those implementation details have been cleanly abstracted away.

This strategy also makes it easier to find bugs. For example, if you name a function `destroyAllGridEntities()`, and then you find a situation where the function does *not* destroy all of the grid entities, then it's clear where the bug is. We can immediately tell from the name of the function that whoever wrote it originally intended it to destroy all of the grid entities. On the other hand, if it was just a block of code in the middle of some other, bigger function, then determining that is not so clear.

As an aside, when I say "whoever wrote it", it might have been written by someone else on your team. But if you don't work on a team, the "someone else" might be **you** from months/years ago. Either way, you are in the same situation. :)

<br />

## Avoiding Global Variables

Beyond the two organizational strategies that were discussed above, there are other ways to organize a big mod. In particular, a lot of mods use global variables, which is the the naive way to split code up into several files. For example, in Lua:

```lua
-- main.lua

local item1 = require("mymod.items.item1")

myMod = RegisterMod("My Mod", 1)

item1:init()
```

```lua
-- item1.lua

local item1 = {}

function item1:init()
  myMod:AddCallback(ModCallbacks.MC_UPDATE, item1.postUpdate)
end

function item1:postUpdate()
  -- Code here
end

return item1
```

In this way, you can avoid using dependency injection, which reduces the complexity a little. Using global variables can get the job done. But there are several disadvantages with using global variables.

<br />

### 1) Variable Scoping

Let's talk about variables. Each variable has a lifecycle. It is initialized at a certain point, modified at other points, and (sometimes) reset back to the initialized state at the end of its lifecycle (like at the beginning of a new run).

A small mod might have ten or twenty different variables. And keeping track of them in your head might be easy. You have memorized where each variables is used. And you know that certain variables get reset in some places, and other variables can get reset in other places.

As you might have guessed, keeping track of variables in your head does not scale very well. In a big mod with thousands of variables, it is impossible to keep track. Just by looking at the name of a variable, you will have no idea where it is initialized, where it is used, and where it is reset. You need a segmentation strategy to stay organized.

<br />

### 2) Namespacing with a Global Variable

One way to stay organized is to use *namespacing* in combination with a global variable. For example:

```lua
-- item1.lua

myMod.item1 = {
  charges = 0,
  counters = 0,
}

function item1:activate()
  myMod.item1.charges = 0
  myMod.item1.counters = myMod.item1.counters + 1
end
```

This is a little gross, because we are now typing a fair amount of boilerplate every time we need to access or modify a variable. One way to get around this is to use locally cache the reference:

```lua
-- item1.lua

local v = {
  charges = 0,
  counters = 0,
}
myMod.item1 = v

function item1:activate()
  v.charges = 0
  v.counters = v.counters + 1
end
```

This works well, but it is ultimately a hack that doesn't address the more underlying problem: the variables are *scoped* incorrectly. Whenever you create a variable, you should think carefully about what its scope should be.

Say that item 2 has a synergy with item 1.

### 1) Resiliency

Obviously, global variables are global. In the Isaac Lua environment, other mods are able to access the global variables that you set. Meaning that other mods can delete your global variables, which will probably make your mod unfunctional. Why take the chance? Make your mod more resilient to failure and use local variables instead.

But what about exporting functionality to other mods?


## Avoiding Side Effects

Some mods import files for side effects, meaning that instead of importing specific files or functions, they just 
