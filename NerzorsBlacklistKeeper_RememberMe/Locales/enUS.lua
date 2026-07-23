local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("enUS", {

    ["Remember Me"]                  = true,
    ["Remembered"]                   = true,

    ["Add to Remember Me"]           = true,
    ["Edit Remember Me entry"]       = true,
    ["Remove from Remember Me"]      = true,
    ["Remove %s-%s from Remember Me?"] = true,

    ["Rating"]                       = true,
    ["Default rating"]               = true,
    ["%d ★"]                         = true,

    ["Show in unit tooltips"]        = true,
    ["Prompt after Mythic+ runs"]    = true,
    ["Clear Remember Me..."]         = true,
    ["Clear all %d Remember Me entries?"] = true,
    ["Cleared %d Remember Me entries."]   = true,

    ["No entries yet - finish a Mythic+ run to remember your party-mates."] = true,

    ["Mythic+ run finished"]         = true,
    ["%s +%d - %s"]                  = true,
    ["timed"]                        = true,
    ["depleted"]                     = true,
    ["Rate your party-mates"]        = true,
    ["Done"]                         = true,

    ["%s-%s is on the Blacklist. Remove from Blacklist?"]   = true,
    ["%s-%s is in Remember Me. Remove from Remember Me?"]   = true,

    ["Added %s-%s to Remember Me."]  = true,
    ["Removed %s-%s from Remember Me."] = true,
}, true)
