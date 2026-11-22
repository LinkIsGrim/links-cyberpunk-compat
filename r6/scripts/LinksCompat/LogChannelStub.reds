// No-op LogChannel for mods that still call it.
//
// LogChannel only exists in the game's debug script builds; the release game doesn't declare
// it, so any mod that calls it fails the whole redscript compile ("function 'LogChannel' not
// found"). Crafting Takes Time (29897) calls it for two debug messages. This stand-in lets
// those mods compile and drops the messages.
//
// Remove this file if another mod you install also declares LogChannel (the compiler will
// report it as defined twice).

public static func LogChannel(channel: CName, text: String) -> Void {}
