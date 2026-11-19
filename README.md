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
| They Will Remember: stuns, EMPs, grapples, knockdowns and Cyberpsychosis interrupt calls | *(behaviour, not a setting; see below)* | Out of the box, They Will Remember only drops a reinforcement call when the caller dies or is hit with Comms Noise / Memory Wipe. |

Much Better AI keys: Firing Cadence = `MarksmanshipCadence`; Detection Speed = `StealthDetection`; Camera Reports & Detection = `EnableSensors`; Silent Hit Response = `StealthHitResponse` (from its `nativeSettingsUI.lua` and `config.reds`).

## They Will Remember: call interrupts

While the toggle is on, a ganger who is calling for reinforcements drops the call if they're stunned, EMP'd, grappled, knocked over (ragdolled) or hit with Cyberpsychosis. The idea comes from Reinforcements System; no code is taken from it.

`TWRCallInterrupts.reds` hooks vanilla `NPCPuppet` events and cancels the call exactly the way They Will Remember's own Comms Noise handler does: it sets the NPC's `callReinforcements` to false, then calls `ReinforcementsManager.SetCaller(null)`. That ends the holocall, removes the phone status, invalidates pending call timers and starts They Will Remember's between-calls cooldown. Dead or defeated callers are left to They Will Remember, which also records the call position and the squad cooldown.

They Will Remember's classes are reached through [Codeware](https://github.com/psiberx/cp2077-codeware) Reflection, by name at runtime. There's no compile-time dependency, so if They Will Remember is missing or renames these methods, the feature does nothing instead of breaking script compilation. Without Codeware, the file compiles to nothing.

## Cyber Enemies without Audioware

Cyber Enemies plays its warning sounds (Banshee, Medusa, Gorgon) with the vanilla `AudioSystem.Play(n"banshee1", npc, ...)` call and ships them for Audioware. [AudioXL](https://www.nexusmods.com/cyberpunk2077/mods/33442) registers named sounds that this same call plays. So `red4ext/plugins/AudioXL/sounds/CyberEnemies/sounds.json` registers Cyber Enemies' names with the same gains, positioned on the NPC, and Audioware isn't needed.

The sound files are Cyber Enemies' assets, so this repo doesn't include them. After installing Cyber Enemies, run:

```bash
tools/link-cyberenemies-audio.sh <mo2-instance>
```

It copies the four files from your Cyber Enemies install into this mod's folder.

## Requirements

redscript, Mod Settings, Cyber Engine Tweaks (for the Much Better AI locks), and Codeware (for the They Will Remember call interrupts).

## Install (MO2)

Install this folder as a mod (`r6/scripts/LinksCompat/` and `bin/x64/plugins/cyber_engine_tweaks/mods/LinksCompat/`). Its position in the mod list doesn't matter.

## How the lock works

`ModSettingsLock.reds` wraps the vanilla settings row (`SettingsSelectorController.Setup`). Every Mod Settings row passes through it, because Mod Settings' row controllers call `super.Setup` first. Rows whose variable path is `/mods/<locked mod>/…` are made non-interactive and labelled.

`@wrapMethod` can only target the game's own classes, not classes added by other mods. The [redscript hook-annotation reference](https://wiki.redmodding.org/scripting-cyberpunk/redscript/language-reference/hook-annotations) says annotations "can't be used on modded methods or classes and native functions", and the compiler confirmed it against Mod Settings' and Much Better AI's classes. That's why the lock hooks the vanilla row.

**Mods that don't use Mod Settings** get a CET Lua lock instead. Much Better AI keeps its settings in a CET menu and publishes each one as a TweakDB value (`MBAI.NativeSettings.<Key>`), which its scripts read. While a fix is on, `bin/x64/plugins/cyber_engine_tweaks/mods/LinksCompat/init.lua` keeps those values at the locked setting: once after loading, then once a second. Much Better AI's own menu still shows its switches, but a change there is undone within a second.

## Checking

All scripts compile cleanly with the redscript compiler (`scc`) against a full mod setup, with Mod Settings' declarations included. Whether a fix took effect is visible in the target mod's own Mod Settings page.
