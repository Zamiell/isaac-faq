# The Binding of Isaac: Repentance Modding FAQ

<br />

## Read the Docs

Search [Wofsuage's API documentation](https://wofsauge.github.io/IsaacDocs/rep/) before you ask a question.

<br />

## Use Discord Syntax Highlighting

When pasting code into Discord, make sure to paste it in a "code block" by using triple backticks. And make sure to use syntax highlighting for the language, by typing the name of the language next to the backticks.

For example, this is a code snippet for Lua:

````
```lua
local foo = "bar"
Isaac.DebugString(foo)
```
````

Or, a code snippet for TypeScript:

````
```ts
const foo = "bar";
Isaac.DebugString(foo);
```
````

<br />

## Format Code

When asking for help, it is common to post a code-snippet. Before posting code, **please format it with an auto-formatter** so that it can be easily understood by others.

- In Lua, use [Lua Beautifier](https://goonlinetools.com/lua-beautifier/), [LuaFormatter](https://github.com/Koihik/LuaFormatter), or [lua-fmt](https://github.com/trixnz/lua-fmt).
- In TypeScript, use [Prettier](https://prettier.io/).

<br />

## No Screenshots

When asking for help, it is common to post a screenshot of your code. **Don't do this**, because it isn't editable or copy-pastable. Instead, post the actual text of the code. Also see the section on [Discord syntax highlighting](#use-discord-syntax-highlighting).

<br />

## Use Minimal, Reproducible Examples

When asking for help, it is common to post a bunch of code that is unrelated to the problem. This makes questions hard to understand and usually means that the person asking the question is putting forth very little effort.

Please read [this StackOverflow post on how to create minimal, reproducable examples](https://stackoverflow.com/help/minimal-reproducible-example).

<br />

## Don't Use Link Previews

Link previews can clutter the conversion, turning a tiny message into a massive wall of text. It is courteous to enclose all links in <>.

For example:

```
Here's a link to my code: <https://github.com/IsaacScript/isaacscript-common/blob/main/src/functions/array.ts#L3-L16>
```

<br />

## How do I start modding Isaac?

We generally recommend that people watch the Lytebringr's series of [video tutorials on YouTube](https://www.youtube.com/playlist?list=PLMZJyHSWa_My5DDoTQcKCgs475xIpQHSF). These were made for Afterbirth+, but not much has changed now that Repentance is out, so they are still your best bet for learning the ropes.

The main difference with Repentance is that the mods folder is now located at:

```
C:\Program Files (x86)\Steam\steamapps\common\The Binding of Isaac Rebirth\mods
```

Other resources:

- Cucco has also made a series of [video tutorials on YouTube](https://www.youtube.com/playlist?list=PLUYzSIp7NO8cEer2FmtxSXlXoMFirvYDN).
- The IsaacScript website has a good [text tutorial](https://isaacscript.github.io/docs/example-mod) on how to build an example mod using IsaacScript.

<br />

## How do I use the resource extractor? How do I unpack the game files?

By default, the game's resources are located here:

```
C:\Program Files (x86)\Steam\steamapps\common\The Binding of Isaac Rebirth\resources
```

However, this directory will be mostly empty unless you run the provided resource extrator. It is located here:

```
C:\Program Files (x86)\Steam\steamapps\common\The Binding of Isaac Rebirth\tools\ResourceExtractor\ResourceExtractor.exe
```

Once you run the extractor, the resources directory will fill up with all of the XML files, ANM2 files, images, and other various files that the game uses.

<br />

## Why is my sprite showing up in-game as a black square?

This happens when the sprite is saved with the wrong bit depth. Set it at 32-bit depth specifically. (Don't set it to be "Automatic".)

<br />

## How do I make sprites in the Isaac style?

Watch [this video](https://www.youtube.com/watch?v=cJ68vYqzSm0) by LeatherIceCream.

<br />

## Why isn't my code working? How do I know when errors occur?

Lua is an interpretted language, which means that if you make a typo or have otherwise bad code, you will only be able to discover it once the program actually runs. If the Lua interpreters encounters an error, it will write it to the game's log.txt file.

By default, this file is located at: `C:\Users\james\Documents\My Games\Binding of Isaac Repentance\log.txt`

Open this file and search it carefully for Lua-related errors. (Ctrl + f for "error" is a good start.) This will often tell you the line number that you messed up on.

It is also recommended to set `FadedConsoleDisplay=1` in the options.ini file so that it is a little bit more easy to discover errors while you play.

For people comfortable with command-line applications, use my [isaac-log-viewer](https://github.com/Zamiell/isaac-log-viewer) script and have it running on a second monitor as you code & test.

<br />

## When is the log.txt cleared?

Every time that you open the game, all of the contents of the log.txt is deleted. Thus, if you need information from the log after a bug occurs, make sure that you do not re-launch the game.

<br />

## How do I troubleshoot my code?

When you write programs, they may not work right away. Your first reaction should not be to paste a bunch of code into Discord and ask "why doesn't this work?". Doing that means you aren't putting forth very much effort to try and solve the problem on your own.

The tried-and-true method to figure out almost any bug is called "print debugging". In Isaac, this means printing out a bunch of messages to the log.txt file so that you can view it and see which parts of your code are being executed, and which are not. So, go to a bunch of places in your code and add `Isaac.DebugString("GETTING HERE 1")`, `Isaac.DebugString("GETTING HERE 2")`, and so on. Then, run your code (i.e. walk around in-game and trigger the bug), and study the log.txt file to try and see what is happening.

Often times, the reason that your code is not working is that your variables are not what you think they are. So, print out what the variables are at each step of the way so that you can confirm that they are what you think they are. Use something along the lines of: `Isaac.DebugString("GETTING HERE - FOO IS: " .. tostring(foo))`

<br />

## I modified an XML file and the game crashes when I open it or when I go into a new run.

A crash means that the XML file is invalid, meaning that you messed up somewhere while editing the file. Start over from scratch and make tiny edits one at a time until you find the exact part that crashes the game.

Another helpful troubleshooting tool is validators like [xmlvalidation.com](https://www.xmlvalidation.com/).

<br />

## What is the ID of [the sound that I care about]?

Simply use [this mod](sounds-display.lua), which will tell you what the ID of any currently-playing sound is.

<br />

## What is Single Line Responsibility (SLR)?

When writing code, put some effort into making it look nice and be easy to read for others, especially if you are showing it to other people or asking for help. In this vein, it is a good idea to follow the "single line responsibility" rule - meaning that **one line** should only do **one thing**. Read [this blog](https://midu.dev/single-line-responsability-haz-una-cosa-por-linea/) for more details about why SLR is great.

<br />

## How do I code X?

The fastest way to figure out how to do something is to simply download a few mods that provide similar functionality to what you want to do, and then study the code.

<br />

<br />

## How do I apply a costume to my character?

This is called a "null costume" and it is accomplished via the `EntityPlayer.AddNullCostume()` method. For more information, see [Lytebringr's 8th video](https://www.youtube.com/watch?v=R1CdCyGL1DQ&list=PLMZJyHSWa_My5DDoTQcKCgs475xIpQHSF&index=9).

<br />

## What is a callback?

Mods affect the game by putting code inside of *callbacks*. Each callback fires when a particular event happens in the game. There are 72 different callbacks to choose from, so you have to choose the right one depending on what you want to do.

For example, the most basic callback is `MC_POST_GAME_STARTED`, which fires once at the beginning of a new run. You would put code in here to do something custom at the beginning of every run.

Another common callback that mods use is `MC_POST_UPDATE`, which fires on every single update frame (i.e. 30 times per second). You would put code in this callback for custom items that have constant effects.

Go through the [official docs](https://wofsauge.github.io/IsaacDocs/rep/enums/ModCallbacks.html) and read what all of the callbacks do so that you can get familiar with them.

<br />

## How do I create a new floor/level/stage?

Unfortunately, Isaac does not natively support modded custom floors. BudJMT and DeadInfinity have built a custom system called [StageAPI](https://github.com/Meowlala/BOIStageAPI15) that allows mods to add custom floors in a hacky way. However, StageAPI is not easy to use, so unless you are already an experienced Isaac modder & coder, you should stick to more simple projects.

<br />

## How do I modify the Devil Room / Angel Room chances?

There is no built-in way to do this, so you will have to get inventive. For the most control, you can delete all vanilla Devil/Angel doors and completely re-implement the system from scratch. Otherwise, you can temporarily give items to the player such as Goat Head or Rosary Bead, or use things like [Game.SetLastDevilRoomStage()](SetLastDevilRoomStage ) or [Level.SetRedHeartDamage()](https://wofsauge.github.io/IsaacDocs/rep/Level.html#setredheartdamage). You also might want to use [LevelStateFlags](https://wofsauge.github.io/IsaacDocs/rep/enums/LevelStateFlag.html).

<br />

## How do I make the costume on my custom character persistent?

Simply use [Sanio's library](https://steamcommunity.com/sharedfiles/filedetails/?id=2541362255) for this, or study the source code and reimplement it yourself.

<br />

## What is the difference between an API and a library?

Some mods on the workshop package functionality together as an abstraction for other poeple to use. In software, this is what is typically known as a "library". As a programmer, it is usually a lot easier to leverage other people's battle-tested libraries than to roll your own from scratch.

On the other hand, an API is short for application programming interface, and it is exactly what it sounds like. An application might want to expose some functionality to external users and software, and it would do that through an explicitly defined interface. Libraries expose an API so that end-users can consume them. But note that *any* software can have an API, not just a library. For example, the Revelations Mod is a popular mod that adds new floors, bosses, and items to the game. But it also exposes an API so that it can be made compatible with other mods.

Historically, Isaac libraries have labeled themselves as "APIs", but this is a misnomer. Some examples of this include [StageAPI](https://github.com/Meowlala/BOIStageAPI15) and [MinimapAPI](https://github.com/TazTxUK/MinimapAPI). On the other hand, an example of a library that is correctly named is Sanio's [Costume Protector](https://steamcommunity.com/sharedfiles/filedetails/?id=2541362255).

If you are creating a new library, please use the correct terminology to name your project, which helps prevent confusion for newcomers to the Isaac modding scene.

<br />

## How do I overwrite vanilla music?

- For normal music replacement, you can simply blow away the respective vanilla resource files.
- For dynamic replacement, use Taz's [Music Mod Callback](https://steamcommunity.com/sharedfiles/filedetails/?id=2491006386).

<br />

## How do I iterate over a list object from the API?

For example, in Lua:

```lua
local game = Game()
local level = game:GetLevel()
local rooms = level:GetRooms()
for i = 0, rooms.Size - 1 do
  local room = rooms:Get(i)
  -- Do something with the room
end
```

For example, in TypeScript:

```ts
const game = Game();
const level = game.GetLevel();
const rooms = level.GetRooms();
for (let i = 0; i < rooms.Size; i++) {
  const room = rooms.Get(i);
  // Do something with the room
}
```

<br />

## How do I get a familiar to follow the player like Brother Bobby does?

For example, in Lua:

```lua
function postFamiliarInitMyFamiliar(familiar)
  familiar:AddToFollowers()
end

function postFamiliarUpdateMyFamiliar(familiar)
  familiar:FollowParent()
end
```

For example, in TypeScript:

```ts
function postFamiliarInitMyFamiliar(familiar: EntityFamiliar) {
  familiar.AddToFollowers();
}

function postFamiliarUpdateMyFamiliar(familiar: EntityFamiliar) {
  familiar.FollowParent();
}
```

<br />

## What are ANM2 files?

- In Isaac, animations are represented by anm2 files in the `resources/gfx` folder.
- Each entity in the game has an associated anm2 file.
- Additionally, UI elements are rendered using various anm2 files (in the `resources/gfx/ui` folder).
- anm2 files are simply XML files with a different file extension.
- To edit the vanilla animations or add new animations, you can:
  - Edit the files directly using a text editor. (Kilburn does this.)
  - Edit the files using the provided Isaac Animation Editor, which is located at: `C:\Program Files (x86)\Steam\steamapps\common\The Binding of Isaac Rebirth\tools\IsaacAnimationEditor\IsaacAnimationEditor.exe`

<br />

## How do you use StageAPI to add new bosses?

See [this screenshot](https://cdn.discordapp.com/attachments/205854782542315520/895485829458325604/unknown.png) from Xalum.

<br />

## What is the difference between `require` and `include`?

### `require`

`require` is a built-in Lua function. Using `require` is the conventional way in Lua programs to split code up into multiple files. For example:

```lua
-- main.lua
local foo = require("foo")

foo:bar() -- Prints "hello"
```

```lua
-- foo.lua
local foo = {}

function foo:bar()
  print("hello")
end

return foo
```

Here, "foo" is a Lua *module* that provides variables and methods.

One important aspect of `require` is that when it is used, it caches the result. Thus, when a file is required in two different places in the code, it will execute all the code normally on the first require, and then return a reference to the module on the second require. (This default behavior makes sense, because there is no need to execute the same code over and over.)

### The `luamod` Problem With `require`

Unfortunately, require caching causes the `luamod` console command to not work correctly. If code inside of a module is updated, it will not be reflected in game after using the `luamod` command because the reference to the module is already cached.

### The Namespacing Problem With `require`

Because require caching is based on the string passed to the function, this causes a problem for mods that have an overlap in the string. For example, imagine that there are two mods, mod 1 and mod 2. Both mods have a file called "foo.lua" and both mods use a require statement similar to the one in the above example. Mod 1 will work as normal, but when mod 2 loads, its require statement will actually return the "foo.lua" file from mod 1.

### `include`

In order to get around these two problems, Kilburn added an Isaac-specific API function called `include` in Repentance patch v1.06.J818. `include` works in a mostly identical way to `require`, except it will never cache the result, causing the code to execute every time.

Unfortunately, `include` does not work properly for users who have the `--luadebug` launch flag enabled, which is a requirement for many legitimate mods, such as the [Twitch Integration Mod](https://moddingofisaac.com/mod/3608/twitch-integration-for-isaac). Thus, mods should either not use `include`, or use it in combination with `require` as a fallback; see below.

### Directory Namespacing

You can get around the namespacing problem by putting all Lua files in a directory that has the name of your mod in it. It is conventional to use "src_" as a prefix, since source code is typically stored in a directory called "src". For example, the Job mod stores lua files in a directory called "src_job".

In this way, no mods will trample on each other, because the require statement of mod 1 would be:

```lua
local foo = require("src_mod1.foo")
```

And the require statement of mod 2 would be:

```lua
local foo = require("src_mod2.foo")
```

### Using `require` with `include`

In Lua, you can use `pcall` to see if something executes correctly without an error. This is similar to using `try` and `catch` in other programming languages. By using `pcall` with `include`, you can detect a `--luadebug` environment and safely fall back to `require`. For example:

```lua
local success, foo = pcall(include, "src_mod1.foo")
if not success then
  foo = require("src_mod1.foo")
end
```

By using this pattern in combination with namespacing, you work around both problems. The only limitation is that developers on your Lua project will not be able to use the `luamod` command if they also have the `--luadebug` flag turned on.

### IsaacScript

Finally, note that the two caching problems discussed above are non-problems if you are writing your mod with TypeScript, because the transpiler automatically combines all code into a single "main.lua" file. This is a nice reason to use TypeScript, but of course, there are [many better advantages](https://isaacscript.github.io/docs/features) to using TypeScript other than to simply fix the `require` function, so you might want to consider it for your current or future projects.
