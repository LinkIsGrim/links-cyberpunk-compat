// They Will Remember: stuns, EMPs, grapples, knockdowns and Cyberpsychosis interrupt a
// reinforcement call.
//
// TWR drops a call when the caller dies or is hit with Comms Noise / Memory Wipe. Hook
// annotations can't target TWR's classes, so this hooks vanilla NPCPuppet events and cancels
// the call the way TWR's own Comms Noise handler does (Wrappers.reds, OnQuickHackEffectApplied):
//     NPCDataTable.Get(id).callReinforcements = false;  ReinforcementsManager.SetCaller(null);
// TWR is reached through Codeware Reflection, so there's no compile-time dependency: if TWR
// is missing or renames these, this does nothing instead of breaking script compilation.
//
// Reflection notes (checked against Codeware's source, src/App/Reflection + lib/Red):
//  - GetClassOf(x) without `actual` resolves the *declared* type (IScriptable here), so we
//    ask for the actual class.
//  - Function lookup matches shortName or fullName. Non-`cb` script methods are stored under
//    their full name ("GetCaller;", "SetCaller;ScriptedPuppet" in final.redscripts.modded),
//    so we look up the full name first and fall back to the short one.
import LinksCompat.*

@if(ModuleExists("Codeware"))
@wrapMethod(NPCPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let result = wrappedMethod(evt);
    if IsDefined(evt) && IsDefined(evt.staticData) {
        let type = evt.staticData.StatusEffectType().Type();
        if Equals(type, gamedataStatusEffectType.Stunned) || Equals(type, gamedataStatusEffectType.EMP)
            || Equals(type, gamedataStatusEffectType.Grapple) || Equals(type, gamedataStatusEffectType.Knockdown) {
            LinksTWR.InterruptCall(this);
        }
    }
    return result;
}

@if(ModuleExists("Codeware"))
@wrapMethod(NPCPuppet)
private final func OnQuickHackEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Void {
    wrappedMethod(evt);
    if IsDefined(evt) && IsDefined(evt.staticData) && ArrayContains(evt.staticData.GameplayTags(), n"Madness") {
        LinksTWR.InterruptCall(this);  // Cyberpsychosis: the caller turns on its own squad
    }
}

@if(ModuleExists("Codeware"))
@wrapMethod(NPCPuppet)
protected cb func OnRagdollEnabledEvent(evt: ref<RagdollNotifyEnabledEvent>) -> Bool {
    let result = wrappedMethod(evt);
    LinksTWR.InterruptCall(this);
    return result;
}

@if(ModuleExists("Codeware"))
public abstract class LinksTWR {

    public static func System(game: GameInstance, name: CName) -> ref<IScriptable> {
        let container = GameInstance.GetScriptableSystemsContainer(game);
        return IsDefined(container) ? container.Get(name) : null;
    }

    // Calls `full` (or `short`) on obj's actual class. ok = false if it couldn't be called.
    public static func Call(obj: ref<IScriptable>, full: CName, short: CName, args: array<Variant>, out ok: Bool) -> Variant {
        ok = false;
        let cls = Reflection.GetClassOf(ToVariant(obj), true);
        if !IsDefined(cls) {
            return ToVariant(false);
        }
        let fn = cls.GetFunction(full);
        if !IsDefined(fn) {
            fn = cls.GetFunction(short);
        }
        if !IsDefined(fn) {
            return ToVariant(false);
        }
        return fn.Call(obj, args, ok);
    }

    public static func InterruptCall(npc: ref<ScriptedPuppet>) -> Void {
        // Alive and not defeated only: deaths and takedowns are TWR's own path, which also
        // records the call position and the squad cooldown.
        if !IsDefined(npc) || !ScriptedPuppet.IsActive(npc) || !LinksCompat.On(n"twrCallInterrupts") {
            return;
        }
        let game = npc.GetGame();
        let manager = LinksTWR.System(game, n"TheyWillRemember.Reinforcements.ReinforcementsManager");
        if !IsDefined(manager) {
            return;  // TWR not installed or no save loaded
        }
        let ok: Bool;
        let none: array<Variant>;
        let caller = FromVariant<ref<ScriptedPuppet>>(LinksTWR.Call(manager, n"GetCaller;", n"GetCaller", none, ok));
        if !ok || !IsDefined(caller) || NotEquals(caller.GetEntityID(), npc.GetEntityID()) {
            return;  // this NPC isn't TWR's current caller
        }
        // 1. the NPC no longer wants to call (TWR re-checks this before calls go through)
        let table = LinksTWR.System(game, n"TheyWillRemember.NPCDataTable");
        if IsDefined(table) {
            let data = FromVariant<ref<IScriptable>>(LinksTWR.Call(table, n"Get;EntityID", n"Get", [ToVariant(npc.GetEntityID())], ok));
            if ok && IsDefined(data) {
                let prop = Reflection.GetClassOf(ToVariant(data), true).GetProperty(n"callReinforcements");
                if IsDefined(prop) {
                    prop.SetValue(ToVariant(data), ToVariant(false));
                }
            }
        }
        // 2. drop the caller: ends the holocall, removes TWR_OnThePhone, invalidates pending
        //    call timers and starts TWR's between-calls cooldown
        let nobody: ref<ScriptedPuppet>;
        LinksTWR.Call(manager, n"SetCaller;ScriptedPuppet", n"SetCaller", [ToVariant(nobody)], ok);
    }
}
