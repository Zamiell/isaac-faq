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

When asking for help, it is common to post a screenshot of your code. **Don't do this**, because it isn't editable or copy-pastable. Instead, post the actual text of the code. See the section on [Discord syntax highlighting](#use-discord-syntax-highlighting).

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

Once you run the extractor, the resources directory will fill up with all of the XML files, ANM2 files, and images that the game uses.

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

## How do I troubleshoot my code?

When you write programs, they may not work right away. Your first reaction should not be to paste a bunch of code into Discord and ask "why doesn't this work?". Doing that means you aren't putting forth very much effort to try and solve the problem on your own.

The tried-and-true method to figure out almost any bug is called "print debugging". In Isaac, this means printing out a bunch of messages to the log.txt file so that you can view it and see which parts of your code are being executed, and which are not. So, go to a bunch of places in your code and add `Isaac.DebugString("GETTING HERE 1")`, `Isaac.DebugString("GETTING HERE 2")`, and so on. Then, run your code (i.e. walk around in-game and trigger the bug), and study the log.txt file to try and see what is happening.

Often times, the reason that your code is not working is that your variables are not what you think they are. So, print out what the variables are at each step of the way so that you can confirm that they are what you think they are. Use something along the lines of: `Isaac.DebugString("GETTING HERE - FOO IS: " .. tostring(foo))`

<br />

### I modified an XML file and it is crashing, what do I do?

A crash means that the XML file is invalid, meaning that you messed up somewhere while editing the file. Start over from scratch and make tiny edits one at a time until you find the exact part the crashes the game.

Another helpful troubleshooting tool is to use XML validation tools like [xmlvalidation.com](https://www.xmlvalidation.com/).

<br />
