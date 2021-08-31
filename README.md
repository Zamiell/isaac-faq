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

## How Do I Start Modding Isaac?

We generally recommend that people watch the Lytebringr's series of [video tutorials on YouTube](https://www.youtube.com/playlist?list=PLMZJyHSWa_My5DDoTQcKCgs475xIpQHSF). These were made for Afterbirth+, but not much has changed now that Repentance is out, so they are still your best bet for learning the ropes.

The main difference with Repentance is that the mods folder is now located at:

```
C:\Program Files (x86)\Steam\steamapps\common\The Binding of Isaac Rebirth\mods
```

Other resources:

- Cucco has also made a series of [video tutorials on YouTube](https://www.youtube.com/playlist?list=PLUYzSIp7NO8cEer2FmtxSXlXoMFirvYDN).
- The IsaacScript website has a good [text tutorial](https://isaacscript.github.io/docs/example-mod) on how to build an example mod using IsaacScript.

<br />

## Why is my sprite showing up in-game as a black square?

This happens when the sprite is saved with the wrong bit depth. Set it at 32-bit depth specifically. (Don't set it to be "Automatic".)

<br />
