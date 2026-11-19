-- Link's Cyberpunk Compatibility Mod: CET part, for mods whose settings aren't in Mod Settings.
--
-- Much Better AI keeps its settings in a CET menu and publishes each one as a TweakDB flat
-- ("MBAI.NativeSettings.<Key>", settingsManager.lua publishFlat), which its scripts read
-- (r6/scripts/MuchBetterAI/config.reds). While a lock is on, we keep those flats at the locked
-- value: once after load and then once a second, so a change in MBAI's menu doesn't stick.
-- The toggles live on our Mod Settings page (redscript system LinksCompat.LinksCompatSettings).

local LOCKS = {
    { toggle = "mbaiFiringCadenceOff", flats = { "MBAI.NativeSettings.MarksmanshipCadence" } },
    { toggle = "mbaiDetectionOff", flats = { "MBAI.NativeSettings.StealthDetection", "MBAI.NativeSettings.EnableSensors" } },
    { toggle = "mbaiSilentHitOff", flats = { "MBAI.NativeSettings.StealthHitResponse" } },
}
local LOCKED_VALUE = false
local INTERVAL = 1.0

local function toggleOn(name)
    local ok, value = pcall(function()
        local system = Game.GetScriptableSystemsContainer():Get("LinksCompat.LinksCompatSettings")
        if system == nil then return nil end
        return system[name]
    end)
    if not ok or value == nil then return true end -- no save loaded yet: toggles default to on
    return value
end

local function enforce()
    for _, lock in ipairs(LOCKS) do
        if toggleOn(lock.toggle) then
            for _, flat in ipairs(lock.flats) do
                local current = TweakDB:GetFlat(flat)
                -- nil = MBAI not installed / not published yet: nothing to lock
                if current ~= nil and current ~= LOCKED_VALUE then
                    TweakDB:SetFlat(flat, LOCKED_VALUE, "Bool")
                end
            end
        end
    end
end

local elapsed = 0
registerForEvent("onInit", enforce)
registerForEvent("onUpdate", function(delta)
    elapsed = elapsed + delta
    if elapsed >= INTERVAL then
        elapsed = 0
        enforce()
    end
end)
