// UI lock: grey out and label rows that Link's Compatibility controls.
//
// Hooks the vanilla settings row (SettingsSelectorController.Setup). Mod Settings builds its
// rows from subclasses that call super.Setup first, so every Mod Settings row passes here.
// (Hook annotations "can't be used on modded methods or classes" - redscript hook-annotation
// reference on wiki.redmodding.org; confirmed with the compiler.) Vanilla rows are untouched:
// only variables whose group path is "/mods/<locked mod>/..." are locked.
import LinksCompat.*

@wrapMethod(SettingsSelectorController)
public func Setup(entry: ref<ConfigVar>, isPreGame: Bool) -> Void {
    wrappedMethod(entry, isPreGame);
    if LinksCompat.IsLocked(entry) {
        this.LinksCompatLockRow();
    }
}

@addMethod(SettingsSelectorController)
public func LinksCompatLockRow() -> Void {
    let root = this.GetRootWidget();
    root.SetInteractive(false);
    root.SetOpacity(0.45);
    inkTextRef.SetText(this.m_LabelText, inkTextRef.GetText(this.m_LabelText) + "  [locked by Link's Compatibility]");
}
