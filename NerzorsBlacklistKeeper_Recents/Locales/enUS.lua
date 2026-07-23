local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("enUS", {
    ["Recents"]                                                 = true,
    ["Recent party-mates"]                                      = true,
    ["Tracks the last %d unique party-mates (party only - not raid)."] = true,
    ["Recents (%d / %d)"]                                       = true,

    ["Storage"]         = true,
    ["Account-wide"]    = true,
    ["Per-character"]   = true,
    ["Maximum entries"] = true,

    ["Remove from recents"]                  = true,
    ["Remove %s-%s from recents?"]           = true,
    ["Clear recents..."]                     = true,
    ["Clear all %d recents entries?"]        = true,
    ["Cleared %d recents entries."]          = true,
}, true)
