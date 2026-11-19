// UI lock: grey out and label rows that Link's Compatibility controls.
//
// Hooks the vanilla settings row (SettingsSelectorController.Setup). Mod Settings builds its
// rows from subclasses that call super.Setup first, so every Mod Settings row passes here.
// (@wrapMethod here can only target the game's own classes, not other mods' - verified with
// the redscript compiler against Mod Settings' and Much Better AI's classes.) Vanilla rows are untouched:
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
