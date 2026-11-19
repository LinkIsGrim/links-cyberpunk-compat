# Link's Cyberpunk Compatibility Mod

A small redscript mod that applies the settings other mods' authors recommend when their mods are used together. It writes them through [Mod Settings](https://www.nexusmods.com/cyberpunk2077/mods/4885)' own API, the same calls its menu makes, so the values are saved in Mod Settings' `user.ini` exactly as if you'd changed them by hand.

Every fix is a toggle on this mod's **Mod Settings** page (*Link's Compatibility*). While a toggle is on, the fix is applied when a save loads and again whenever settings change. Turn it off and this mod leaves that setting alone; it doesn't revert it. Fixes for mods that aren't installed are skipped.

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

## Checking

`LinksCompat.reds` compiles cleanly with the redscript compiler (`scc`) against a full mod setup, with Mod Settings' declarations included. Whether a fix took effect is visible in the target mod's own Mod Settings page.
