// Link's Cyberpunk Compatibility Mod
//
// Applies settings that other mods' authors recommend when their mods are combined, by
// writing them through Mod Settings' own API (the same calls its menu makes), so the
// values are saved in Mod Settings' user.ini as if you had changed them yourself.
//
// Every fix is a toggle on this mod's own Mod Settings page. While a toggle is on, the
// setting is LOCKED: its row in the other mod's Mod Settings page is greyed out and
// labelled, and the value is re-applied on save load and after any settings change.
// Turn the toggle off and this mod leaves that setting alone. Fixes for mods that
// aren't installed are skipped.
module LinksCompat


public class LinksCompatSettings extends ScriptableSystem {

    // --- Dark Future + Immersive Crafting Access -------------------------------------
    @runtimeProperty("ModSettings.mod", "Link's Compatibility")
    @runtimeProperty("ModSettings.category", "Dark Future")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.displayName", "Allow crafting outside the stash")
    @runtimeProperty("ModSettings.description", "Sets Dark Future's 'Limit Crafting to Stash' to Off, as Dark Future's author recommends with Immersive Crafting Access.")
    public let dfStashCraftingOff: Bool = true;

    // --- Much Better AI + your other mods (per Much Better AI's compatibility list) ----
    @runtimeProperty("ModSettings.mod", "Link's Compatibility")
    @runtimeProperty("ModSettings.category", "Much Better AI")
    @runtimeProperty("ModSettings.category.order", "20")
    @runtimeProperty("ModSettings.displayName", "Gunsensical owns enemy firing cadence")
    @runtimeProperty("ModSettings.description", "Turns off Much Better AI's Marksmanship > Firing Cadence so Gunsensical Reloaded's enemy burst timing applies.")
    public let mbaiFiringCadenceOff: Bool = true;

    @runtimeProperty("ModSettings.mod", "Link's Compatibility")
    @runtimeProperty("ModSettings.category", "Much Better AI")
    @runtimeProperty("ModSettings.displayName", "They Will Remember owns detection")
    @runtimeProperty("ModSettings.description", "Turns off Much Better AI's Stealth > Detection Speed and Camera Reports & Detection so They Will Remember's detection scaling applies.")
    public let mbaiDetectionOff: Bool = true;

    @runtimeProperty("ModSettings.mod", "Link's Compatibility")
    @runtimeProperty("ModSettings.category", "Much Better AI")
    @runtimeProperty("ModSettings.displayName", "Silent Silencers owns silent hits")
    @runtimeProperty("ModSettings.description", "Turns off Much Better AI's Stealth > Silent Hit Response so Silent Silencers and Throwing Knives' suppressed-shot and knife-hit rules apply.")
    public let mbaiSilentHitOff: Bool = true;

    private func OnAttach() -> Void {
        // keeps the toggles above in sync with the menu / user.ini
        ModSettings.RegisterListenerToClass(this);
        // delivers OnModSettingsChange() after any Accept/Reject (ModSettings.cpp NotifyListeners)
        ModSettings.RegisterListenerToModifications(this);
        LinksCompat.Apply(this);
    }

    private func OnDetach() -> Void {
        ModSettings.UnregisterListenerToModifications(this);
        ModSettings.UnregisterListenerToClass(this);
    }

    // Re-apply when settings change (e.g. a fix toggled back on, or another mod's menu
    // reset). Our own AcceptChanges re-notifies once; the second pass finds nothing to do.
    public func OnModSettingsChange() -> Void {
        LinksCompat.Apply(this);
    }
}

public abstract class LinksCompat {

    public static func OwnMod() -> CName { return n"Link's Compatibility"; }

    // Locked settings: target mod, target property, and the toggle (on our page) that owns it.
    public static func Locks() -> array<ref<LinksCompatLock>> {
        let out: array<ref<LinksCompatLock>>;
        ArrayPush(out, LinksCompatLock.Make(n"DarkFutureSettingsModName", n"stashCraftingEnabled", n"dfStashCraftingOff"));
        ArrayPush(out, LinksCompatLock.Make(LinksCompat.MbaiMod(), LinksCompat.MbaiFiringCadence(), n"mbaiFiringCadenceOff"));
        ArrayPush(out, LinksCompatLock.Make(LinksCompat.MbaiMod(), LinksCompat.MbaiDetectionSpeed(), n"mbaiDetectionOff"));
        ArrayPush(out, LinksCompatLock.Make(LinksCompat.MbaiMod(), LinksCompat.MbaiCameraReports(), n"mbaiDetectionOff"));
        ArrayPush(out, LinksCompatLock.Make(LinksCompat.MbaiMod(), LinksCompat.MbaiSilentHit(), n"mbaiSilentHitOff"));
        return out;
    }

    // Is this Mod Settings variable locked right now? Reads our toggles through Mod Settings,
    // so it also works in the main menu before any save (and our system) is loaded.
    public static func IsLocked(entry: ref<ConfigVar>) -> Bool {
        if !IsDefined(entry) {
            return false;
        }
        let path = NameToString(entry.GetGroupPath());  // "/mods/<mod>/<class>"
        for lock in LinksCompat.Locks() {
            if NotEquals(lock.mod, n"None") && Equals(entry.GetName(), lock.name)
                && StrBeginsWith(path, "/mods/" + NameToString(lock.mod) + "/")
                && LinksCompat.OwnToggle(lock.toggle) {
                return true;
            }
        }
        return false;
    }

    public static func OwnToggle(name: CName) -> Bool {
        let cats = ModSettings.GetCategories(LinksCompat.OwnMod());
        ArrayPush(cats, n"None");
        for cat in cats {
            for v in ModSettings.GetVars(LinksCompat.OwnMod(), cat) {
                if Equals(v.GetName(), name) {
                    let b = v as ModConfigVarBool;
                    return IsDefined(b) && b.GetValue();
                }
            }
        }
        return true;  // our own page not registered yet: default is on
    }

    public static func Apply(s: ref<LinksCompatSettings>) -> Void {
        let changed = false;
        if s.dfStashCraftingOff {
            changed = LinksCompat.SetBool(n"DarkFutureSettingsModName", n"stashCraftingEnabled", false) || changed;
        }
        // Much Better AI's setting names are filled in from its scripts (see MBAI_* below).
        if s.mbaiFiringCadenceOff {
            changed = LinksCompat.SetBool(LinksCompat.MbaiMod(), LinksCompat.MbaiFiringCadence(), false) || changed;
        }
        if s.mbaiDetectionOff {
            changed = LinksCompat.SetBool(LinksCompat.MbaiMod(), LinksCompat.MbaiDetectionSpeed(), false) || changed;
            changed = LinksCompat.SetBool(LinksCompat.MbaiMod(), LinksCompat.MbaiCameraReports(), false) || changed;
        }
        if s.mbaiSilentHitOff {
            changed = LinksCompat.SetBool(LinksCompat.MbaiMod(), LinksCompat.MbaiSilentHit(), false) || changed;
        }
        if changed {
            ModSettings.AcceptChanges();
        }
    }

    // Placeholders until Much Better AI's settings class has been read.
    public static func MbaiMod() -> CName { return n"None"; }
    public static func MbaiFiringCadence() -> CName { return n"None"; }
    public static func MbaiDetectionSpeed() -> CName { return n"None"; }
    public static func MbaiCameraReports() -> CName { return n"None"; }
    public static func MbaiSilentHit() -> CName { return n"None"; }

    // Requests a new value for a Mod Settings bool. Returns true when a change was requested.
    // Does nothing if the mod isn't installed or the setting doesn't exist.
    public static func SetBool(mod: CName, name: CName, value: Bool) -> Bool {
        if Equals(mod, n"None") || Equals(name, n"None") || !ArrayContains(ModSettings.GetMods(), mod) {
            return false;
        }
        let cats = ModSettings.GetCategories(mod);
        ArrayPush(cats, n"None");
        for cat in cats {
            for v in ModSettings.GetVars(mod, cat) {
                if Equals(v.GetName(), name) {
                    let b = v as ModConfigVarBool;
                    if IsDefined(b) && NotEquals(b.GetValue(), value) {
                        b.SetValue(value);
                        return true;
                    }
                    return false;
                }
            }
        }
        return false;
    }
}

public class LinksCompatLock {
    public let mod: CName;
    public let name: CName;
    public let toggle: CName;

    public static func Make(mod: CName, name: CName, toggle: CName) -> ref<LinksCompatLock> {
        let l = new LinksCompatLock();
        l.mod = mod;
        l.name = name;
        l.toggle = toggle;
        return l;
    }
}
