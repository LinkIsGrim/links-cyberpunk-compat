// Ripperdoc Service Charge + Live A Little: keep Vik's debt at 33,000.
//
// Ripperdoc Service Charge rewrites EconomicAssignment.q001_victor_debt.overrideValue every
// session from its UpdateVictorDebt system's OnAttach: 55,000 plus the equip cost of three
// implants by default, or vanilla 21,000 when its debt option is off. Either way it would undo
// the 33,000 from r6/tweaks/LinksCompat/live_a_little.yaml.
//
// Redscript can't wrap a method of another mod's class, so this system writes 33,000 back
// instead: in OnAttach (attach order between systems isn't guaranteed) and again in
// OnPlayerAttach, which runs after every system's OnAttach.
module LinksCompat

public class LinksCompatVikDebt extends ScriptableSystem {
    private func OnAttach() -> Void {
        LinksCompatVikDebt.Apply();
    }

    private func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
        LinksCompatVikDebt.Apply();
    }

    public static func Apply() -> Void {
        let id = t"EconomicAssignment.q001_victor_debt.overrideValue";
        TweakDBManager.SetFlat(id, 33000);
        TweakDBManager.UpdateRecord(id);
    }
}
