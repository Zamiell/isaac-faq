# Mod Oragnization

This is a short blog about how to organize an Isaac mod. The principles are agnostic in that they equally apply to a mod written in TypeScript or a mod written in Lua.

Software has the problem where if you keep on adding things to it, eventually it becomes a Frankenstein monster - hard to manage and hard to understand. It is helpful to keep your mod code nice and organized so that it never reaches a state of unmaintainable spaghetti.

Small mods can be written in a single file - `main.ts` (for TypeScript) or `main.lua` (for Lua). But for bigger mods, you will want to split up your code into different files. For example, it makes sense for a mod pack that contains 10 items to have all of the code for each individual item live in a file dedicated to just that item. That way, you can leverage the `Ctrl + p` hotkey in VSCode to jump to the exact spot that you need to go. And if you need to fix a bug with item 1, then you don't have to go on a scavenger hunt throughout the entire repository - you can just focus all of your attention on the file called `item1.ts`.

And if an item/feature file has so much code that it gets to be 500-1000 lines, then consider splitting up that file into multiple files. Instead of having a file called `item1.ts`, have a directory called `item1` with child files based on the particular property of the feature or the originating callback.

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

(In a Lua mod, this would look almost exactly the same, obviously replacing "import" with "require" and so on.)

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

In this way, we have one callback function per callback.

One advantage of having two degrees of hierarchy is that you can control the *order* of the execution of all of the code in your mod. This can be important for bigger mods. For example, one item/feature might take away all items from a player, and another item/feature might add items to a player. In this case, you would have to ensure that the former feature is executed last.

Another advantage of having two degrees of hierarchy is that the execution flow is eaier to analyze and troubleshoot. By commenting out functions in a speciifc callback file, you have more fine grained control than by simply disabling the initialization of an entire item/feature.

Using TypeScript compliments this strategy because it ensures that everything glues together properly.

<br />

## 2a) Callback Files with Dependency Injection for Callbacks with Optional Arguments

In your mod, you might want to take advantage of the "optional arguments" feature of the Isaac callbacks. However, we still want to contain all of the logic for a particular callback inside the file dedicated to that callback. So we can use dependency injection for this.

```ts
// main.ts

import * as postEntityKillInit from "./callbacks/postEntityKill";

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

<br />
