# Revival Items in The Binding of Isaac: Repentance

Creating modded items in Isaac is generally pretty easy. However, creating revival items is not. The main problem is that there is no built-in way to detect fatal damage, and if the player takes fatal damage, the save data for the run is immediately deleted to prevent saving & quitting & continuing. Thus, it is mandatory that mods intercept fatal damage.

Doing this properly is very difficult and takes thousands of lines of code. Thus, it is recommended that you keep your mod as clean as possible and use the `isaacscript-common` library.

If you don't know what a library is or you have never used a library before, then you might want to read [this explanation](https://isaacscript.github.io/main/isaacscript-in-lua) to start with.

<br>

## Example

Below is a short example of implementing a revival item called Maggy's Tampon. The item will revive the player as Magdalene. Both TypeScript and Lua examples are provided.

In TypeScript:

```ts
import { PlayerType } from "isaac-typescript-definitions";
import { ModCallbackCustom, upgradeMod } from "isaacscript-common";

const CollectibleTypeCustom = {
  MAGGYS_TAMPON: Isaac.GetItemIdByName("Maggy's Tampon"),
} as const;

enum RevivalType {
  MAGGYS_TAMPON,
}

const modVanilla = RegisterMod("Maggy's Tampon", 1);
const mod = upgradeMod(modVanilla);

mod.AddCallbackCustom(ModCallbackCustom.PRE_CUSTOM_REVIVE, preCustomRevive);
mod.AddCallbackCustom(
  ModCallbackCustom.POST_CUSTOM_REVIVE,
  postCustomRevive,
  RevivalType.MAGGYS_TAMPON,
);

function preCustomRevive(player: EntityPlayer) {
  const hasTampon = player.HasCollectible(CollectibleTypeCustom.MAGGYS_TAMPON);
  return hasTampon ? RevivalType.MAGGYS_TAMPON : undefined;
}

function postCustomRevive(player: EntityPlayer) {
  player.AnimateCollectible(CollectibleTypeCustom.MAGGYS_TAMPON);
  player.ChangePlayerType(PlayerType.MAGDALENE);
  player.RemoveCollectible(CollectibleTypeCustom.MAGGYS_TAMPON);
}
```

Or, in Lua:

```lua
local isc = require("maggys-tampon.lib.isaacscript-common")

local CollectibleTypeCustom = {
  MAGGYS_TAMPON = Isaac.GetItemIdByName("Maggy's Tampon"),
}

local RevivalType = {
  MAGGYS_TAMPON = 0,
}

local modVanilla = RegisterMod("Maggy's Tampon", 1)
local mod = isc:upgradeMod(modVanilla)

local function preCustomRevive(_, player)
  local hasTampon = player:HasCollectible(CollectibleTypeCustom.MAGGYS_TAMPON)
  if hasTampon then
    return RevivalType.MAGGYS_TAMPON
  end
  return nil;
end

local function postCustomRevive(_, player)
  player:AnimateCollectible(CollectibleTypeCustom.MAGGYS_TAMPON)
  player:ChangePlayerType(isc.PlayerType.MAGDALENE)
  player:RemoveCollectible(CollectibleTypeCustom.MAGGYS_TAMPON)
end

mod:AddCallbackCustom(isc.ModCallbackCustom.PRE_CUSTOM_REVIVE, preCustomRevive)
mod:AddCallbackCustom(isc.ModCallbackCustom.POST_CUSTOM_REVIVE, postCustomRevive, RevivalType.MAGGYS_TAMPON)
```
