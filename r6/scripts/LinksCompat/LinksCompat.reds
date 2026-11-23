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

    // --- They Will Remember -------------------------------------------------------------
    @runtimeProperty("ModSettings.mod", "Link's Compatibility")
    @runtimeProperty("ModSettings.category", "They Will Remember")
    @runtimeProperty("ModSettings.category.order", "30")
    @runtimeProperty("ModSettings.displayName", "Stuns, EMPs, grapples and knockdowns interrupt calls")
    @runtimeProperty("ModSettings.description", "A ganger calling for reinforcements drops the call when stunned, EMP'd, grappled or knocked over, like when killed or hit with Comms Noise. Needs Codeware.")
    public let twrCallInterrupts: Bool = true;

    // --- More Guns More Fun + Gunsensical Reloaded --------------------------------------
    @runtimeProperty("ModSettings.mod", "Link's Compatibility")
    @runtimeProperty("ModSettings.category", "More Guns More Fun")
    @runtimeProperty("ModSettings.category.order", "40")
    @runtimeProperty("ModSettings.displayName", "Match All Guns Are Cool (Gunsensical's balance)")
    @runtimeProperty("ModSettings.description", "Gunsensical Reloaded is balanced around All Guns Are Cool: Cool's handgun and precision perks work with every gun, nothing else crosses over. Sets More Guns More Fun to exactly that: Cool rows for rifles/SMGs and shotguns/machine guns at Legend, every other row Off.")
    public let mgmfMatchAgac: Bool = true;

    // --- Weapon Conditioning (+ Ripperdoc Service Charge, EconomyPunk) -----------------
    @runtimeProperty("ModSettings.mod", "Link's Compatibility")
    @runtimeProperty("ModSettings.category", "Weapon Conditioning")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "Cheaper, money-only cyberarm maintenance")
    @runtimeProperty("ModSettings.description", "Ripperdocs maintain cyberarms for eddies only, no crafting components, at half Weapon Conditioning's default price (money factor 0.2 instead of 0.4). Do-it-yourself cyberarm maintenance is turned off, since it would be free. Upgrades still cost components.")
    public let wcCheapMaintenance: Bool = true;

    @runtimeProperty("ModSettings.mod", "Link's Compatibility")
    @runtimeProperty("ModSettings.category", "Weapon Conditioning")
    @runtimeProperty("ModSettings.displayName", "Technical Ability: cheaper maintenance, slower wear")
    @runtimeProperty("ModSettings.description", "Each Technical Ability point above 3 makes weapon and cyberarm maintenance 2.5% cheaper and wear 2% slower (at 20: 42.5% cheaper, 34% slower).")
    public let wcTechBonus: Bool = true;

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
        ArrayPush(out, LinksCompatLock.Make(n"DarkFutureSettingsModName", n"stashCraftingEnabled", n"dfStashCraftingOff", 0));
        // More Guns More Fun tiers (MF_Tier): Off = 0 ... Legend = 4. All Guns Are Cool widens only
        // Cool's handgun/precision perks to rifles, SMGs, shotguns and machine guns.
        let mgmf = n"More Guns More Fun";
        ArrayPush(out, LinksCompatLock.Make(mgmf, n"coolReflexes", n"mgmfMatchAgac", 4));
        ArrayPush(out, LinksCompatLock.Make(mgmf, n"coolBody", n"mgmfMatchAgac", 4));
        ArrayPush(out, LinksCompatLock.Make(mgmf, n"coolThrowable", n"mgmfMatchAgac", 0));
        ArrayPush(out, LinksCompatLock.Make(mgmf, n"reflexesCool", n"mgmfMatchAgac", 0));
        ArrayPush(out, LinksCompatLock.Make(mgmf, n"reflexesBody", n"mgmfMatchAgac", 0));
        ArrayPush(out, LinksCompatLock.Make(mgmf, n"reflexesThrowable", n"mgmfMatchAgac", 0));
        ArrayPush(out, LinksCompatLock.Make(mgmf, n"bodyCool", n"mgmfMatchAgac", 0));
        ArrayPush(out, LinksCompatLock.Make(mgmf, n"bodyReflexes", n"mgmfMatchAgac", 0));
        ArrayPush(out, LinksCompatLock.Make(mgmf, n"bodyThrowable", n"mgmfMatchAgac", 0));
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
        for lock in LinksCompat.Locks() {
            if LinksCompat.Field(s, lock.toggle) {
                changed = LinksCompat.SetValue(lock.mod, lock.name, lock.value) || changed;
            }
        }
        // Much Better AI isn't a Mod Settings mod; its locks are the CET script in bin/.
        if changed {
            ModSettings.AcceptChanges();
        }
    }

    // Fast toggle read for hot paths (MBAI calls its settings getters constantly): a field read
    // on our scriptable system. Before a save is loaded there's no system; default is on.
    public static func On(toggle: CName) -> Bool {
        let s = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"LinksCompat.LinksCompatSettings") as LinksCompatSettings;
        if !IsDefined(s) {
            return true;
        }
        return LinksCompat.Field(s, toggle);
    }

    public static func Field(s: ref<LinksCompatSettings>, toggle: CName) -> Bool {
        switch toggle {
            case n"mbaiFiringCadenceOff": return s.mbaiFiringCadenceOff;
            case n"mbaiDetectionOff": return s.mbaiDetectionOff;
            case n"mbaiSilentHitOff": return s.mbaiSilentHitOff;
            case n"dfStashCraftingOff": return s.dfStashCraftingOff;
            case n"twrCallInterrupts": return s.twrCallInterrupts;
            case n"mgmfMatchAgac": return s.mgmfMatchAgac;
            case n"wcCheapMaintenance": return s.wcCheapMaintenance;
            case n"wcTechBonus": return s.wcTechBonus;
            default: return true;
        }
    }

    // Requests a new value for a Mod Settings bool (0/1) or enum (the enum's value, not its
    // menu index). Returns true when a change was requested. Does nothing if the mod isn't
    // installed or the setting doesn't exist.
    public static func SetValue(mod: CName, name: CName, value: Int32) -> Bool {
        if Equals(mod, n"None") || Equals(name, n"None") || !ArrayContains(ModSettings.GetMods(), mod) {
            return false;
        }
        let cats = ModSettings.GetCategories(mod);
        ArrayPush(cats, n"None");
        for cat in cats {
            for v in ModSettings.GetVars(mod, cat) {
                if Equals(v.GetName(), name) {
                    let b = v as ModConfigVarBool;
                    if IsDefined(b) {
                        if NotEquals(b.GetValue(), value != 0) {
                            b.SetValue(value != 0);
                            return true;
                        }
                        return false;
                    }
                    let e = v as ModConfigVarEnum;
                    if IsDefined(e) && e.GetValue() != value {
                        let index = e.GetIndexFor(value);
                        if index >= 0 {
                            e.SetIndex(index);
                            return true;
                        }
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
    public let value: Int32;  // bool as 0/1, or an enum value

    public static func Make(mod: CName, name: CName, toggle: CName, value: Int32) -> ref<LinksCompatLock> {
        let l = new LinksCompatLock();
        l.mod = mod;
        l.name = name;
        l.toggle = toggle;
        l.value = value;
        return l;
    }
}
