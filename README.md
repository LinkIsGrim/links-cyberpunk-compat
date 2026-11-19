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

Much Better AI keys: Firing Cadence = `MarksmanshipCadence`; Detection Speed = `StealthDetection`; Camera Reports & Detection = `EnableSensors`; Silent Hit Response = `StealthHitResponse` (from its `nativeSettingsUI.lua` and `config.reds`).

## Requirements

redscript, Mod Settings, and Cyber Engine Tweaks (for the Much Better AI locks).

## Install (MO2)

Install this folder as a mod (`r6/scripts/LinksCompat/` and `bin/x64/plugins/cyber_engine_tweaks/mods/LinksCompat/`). Its position in the mod list doesn't matter.

## How the lock works

`ModSettingsLock.reds` wraps the vanilla settings row (`SettingsSelectorController.Setup`). Every Mod Settings row passes through it, because Mod Settings' row controllers call `super.Setup` first. Rows whose variable path is `/mods/<locked mod>/…` are made non-interactive and labelled.

`@wrapMethod` can only target the game's own classes, not classes added by other mods. The [redscript hook-annotation reference](https://wiki.redmodding.org/scripting-cyberpunk/redscript/language-reference/hook-annotations) says annotations "can't be used on modded methods or classes and native functions", and the compiler confirmed it against Mod Settings' and Much Better AI's classes. That's why the lock hooks the vanilla row.

**Mods that don't use Mod Settings** get a CET Lua lock instead. Much Better AI keeps its settings in a CET menu and publishes each one as a TweakDB value (`MBAI.NativeSettings.<Key>`), which its scripts read. While a fix is on, `bin/x64/plugins/cyber_engine_tweaks/mods/LinksCompat/init.lua` keeps those values at the locked setting: once after loading, then once a second. Much Better AI's own menu still shows its switches, but a change there is undone within a second.

## Checking

Both scripts compile cleanly with the redscript compiler (`scc`) against a full mod setup, with Mod Settings' declarations included. Whether a fix took effect is visible in the target mod's own Mod Settings page.
