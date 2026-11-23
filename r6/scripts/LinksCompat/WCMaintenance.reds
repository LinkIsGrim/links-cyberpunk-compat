// Weapon Conditioning: cheaper maintenance, money only at the ripperdoc, and a Technical Ability bonus.
//
// Weapon Conditioning keeps its settings in Redscript Configuration Framework (RCF). RCF's public API
// (DVRCF.SetFloat / SetBool) writes a mod's value and saves it to that mod's RCF file, the same as its
// menu does. This system re-applies the values below every few seconds while the toggles are on, and
// only writes when a value differs, so a change in Weapon Conditioning's own menu is undone shortly after.
//
// Values (toggle "Cheaper, money-only cyberarm maintenance"):
//   arm.MaterialReduction_Maintenance_onArm = 0     no crafting components for cyberarm maintenance
//   arm.MoneyReduction_Maintenance          = 0.2   (WC default 0.4) x wear fraction x RSC upgrade price
//   arm.enableSelfMaintenance               = off   (with 0 materials, do-it-yourself would be free)
// Technical Ability (toggle "Technical Ability makes maintenance cheaper and gear last longer"), per point
// above 3, capped at 20:
//   maintenance cost  -2.5% per point (x0.575 at 20): arm money factor and weapon maintenance materials
//   wear rate         -2%   per point (x0.66 at 20):  weapon.DurabilityCost_Global, arm.DurabilityCost_Global_onArm
//
// Weapon Conditioning bakes the maintenance material multipliers into per-item-type configs at session
// start, so after a change this rebuilds those configs (WeaponConditioningSystem.SetItemConditionConfigNonStatic,
// forced), as Weapon Conditioning itself does in OnSessionReady.
module LinksCompat

@if(ModuleExists("WeaponConditioning.Config"))
import RedscriptConfigFramework.*
@if(ModuleExists("WeaponConditioning.Config"))
import WeaponConditioning.Config.*

@if(ModuleExists("WeaponConditioning.Config"))
public class LinksCompatWCMaintenance extends ScriptableSystem {
    private let m_gen: Int32 = 0;   // one tick loop per session: older loops stop

    private func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
        this.m_gen += 1;
        this.Schedule(3.0, this.m_gen);
    }

    public func Schedule(delay: Float, gen: Int32) -> Void {
        let cb = new LinksCompatWCTick();
        cb.sys = this;
        cb.gen = gen;
        GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(cb, delay, false);
    }

    public func Tick(gen: Int32) -> Void {
        if gen != this.m_gen {
            return;
        }
        this.Apply();
        this.Schedule(5.0, gen);
    }

    private func Apply() -> Void {
        let gi = this.GetGameInstance();
        let reg = DVRCF_Registry.Get(gi);
        if !IsDefined(reg) || !IsDefined(reg.GetEntry("WeaponConditioning")) {
            return;  // Weapon Conditioning hasn't registered with RCF yet (it does in OnSessionReady)
        }
        let cheap = LinksCompat.On(n"wcCheapMaintenance");
        let tech = LinksCompat.On(n"wcTechBonus");
        if !cheap && !tech {
            return;
        }
        let pts = 0.0;
        if tech {
            let player = GetPlayer(gi);
            if !IsDefined(player) {
                return;
            }
            let ta = GameInstance.GetStatsSystem(gi).GetStatValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatType.TechnicalAbility);
            pts = ClampF(ta - 3.0, 0.0, 17.0);
        }
        let costF = 1.0 - 0.025 * pts;
        let wearF = 1.0 - 0.02 * pts;
        // Weapon Conditioning's own defaults, used when the cheap-maintenance toggle is off.
        let armMoney = cheap ? 0.2 : 0.4;
        let changed = false;
        if cheap {
            changed = this.SetF(gi, "arm.MaterialReduction_Maintenance_onArm", 0.0) || changed;
            changed = this.SetB(gi, "arm.enableSelfMaintenance", false) || changed;
        }
        changed = this.SetF(gi, "arm.MoneyReduction_Maintenance", armMoney * costF) || changed;
        if tech {
            changed = this.SetF(gi, "weapon.MaterialReduction_Maintenance", 0.8 * costF) || changed;
            changed = this.SetF(gi, "weapon.DurabilityCost_Global", wearF) || changed;
            changed = this.SetF(gi, "arm.DurabilityCost_Global_onArm", wearF) || changed;
        }
        if changed {
            let wc = WeaponConditioningSystem.GetSystem();
            if IsDefined(wc) {
                wc.SetItemConditionConfigNonStatic(mm_extraItemTypes.Weapons, wc.GetConfigWC().CreateExtraItemConditioningConfig(), true);
                wc.SetItemConditionConfigNonStatic(mm_extraItemTypes.ArmCyberware, wc.GetConfigArms().CreateExtraItemConditioningConfig(), true);
            }
        }
    }

    private func SetF(gi: GameInstance, key: String, value: Float) -> Bool {
        if AbsF(DVRCF.GetFloat(gi, "WeaponConditioning", key) - value) < 0.0005 {
            return false;
        }
        DVRCF.SetFloat(gi, "WeaponConditioning", key, value);
        return true;
    }

    private func SetB(gi: GameInstance, key: String, value: Bool) -> Bool {
        if Equals(DVRCF.GetBool(gi, "WeaponConditioning", key), value) {
            return false;
        }
        DVRCF.SetBool(gi, "WeaponConditioning", key, value);
        return true;
    }
}

@if(ModuleExists("WeaponConditioning.Config"))
public class LinksCompatWCTick extends DelayCallback {
    public let sys: wref<LinksCompatWCMaintenance>;
    public let gen: Int32;

    public func Call() -> Void {
        if IsDefined(this.sys) {
            this.sys.Tick(this.gen);
        }
    }
}
