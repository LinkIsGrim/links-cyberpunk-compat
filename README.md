# Link's Cyberpunk Compatibility Mod

A small redscript mod that applies the settings other mods' authors recommend when their mods are used together. It writes them through [Mod Settings](https://www.nexusmods.com/cyberpunk2077/mods/4885)' own API, the same calls its menu makes, so the values are saved in Mod Settings' `user.ini` exactly as if you'd changed them by hand.

Every fix is a toggle on this mod's **Mod Settings** page (*Link's Compatibility*). While a toggle is on, the setting is **locked**:

- **In the menu:** its row on the other mod's Mod Settings page is greyed out, labelled *[locked by Link's Compatibility]* and can't be changed. This works in the main menu too.
- **Value:** it's applied when a save loads and again after any settings change, so it can't drift.

Turn a toggle off and this mod unlocks that setting and leaves it alone; it doesn't revert it. Fixes for mods that aren't installed are skipped.

## Fixes

| Toggle | Sets | Why |
|:--|:--|:--|
| Dark Future: allow crafting outside the stash | Dark Future `stashCraftingEnabled` = off | Dark Future's author: with Immersive Crafting Access, set "Limit Crafting to Stash" Off. |
| Much Better AI: Gunsensical owns enemy firing cadence | MBAI Marksmanship > Firing Cadence = off | Much Better AI's compatibility list (Gunsensical Reloaded). |
| Much Better AI: They Will Remember owns detection | MBAI Stealth > Detection Speed, Camera Reports & Detection = off | Much Better AI's compatibility list (They Will Remember). |
| Much Better AI: Silent Silencers owns silent hits | MBAI Stealth > Silent Hit Response = off | Much Better AI's compatibility list (Silent Silencers and Throwing Knives). |

The Much Better AI fixes are placeholders until its settings class is filled in (`LinksCompat.Mbai*`).

## Requirements

redscript and Mod Settings.

## Install (MO2)

Install this folder as a mod (it contains only `r6/scripts/LinksCompat/`). Its position in the mod list doesn't matter.

## How the lock works

`ModSettingsLock.reds` wraps the vanilla settings row (`SettingsSelectorController.Setup`). Every Mod Settings row passes through it, because Mod Settings' row controllers call `super.Setup` first. Rows whose variable path is `/mods/<locked mod>/…` are made non-interactive and labelled.

Mod Settings' own menu classes can't be wrapped: they're loaded from its RED4ext plugin script folder, and `@wrapMethod` can't target classes from there. I verified this with the compiler.

## Checking

Both scripts compile cleanly with the redscript compiler (`scc`) against a full mod setup, with Mod Settings' declarations included. Whether a fix took effect is visible in the target mod's own Mod Settings page.
