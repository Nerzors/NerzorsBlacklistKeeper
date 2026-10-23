local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("enUS", {

    ["Statistics"]         = true,
    ["Entries per month"]  = true,
    ["Top reasons"]        = true,
    ["Top zones"]          = true,
    ["Top realms"]         = true,
    ["By class"]           = true,
    ["Most encountered"]   = true,
    ["Chat impact"]        = true,

    ["Entries"]            = true,
    ["New (30 days)"]      = true,
    ["Messages"]           = true,

    ["Censored"]           = true,
    ["Hidden"]             = true,
    ["Archived"]           = true,

    ["No reason"]          = true,
    ["Unknown"]            = true,
    ["No data yet"]        = true,

    ["Statistics needs an updated Data folder"] =
        "Statistics: please update the NerzorsBlacklistKeeper_Data folder.",

    ["Say"]                = true,
    ["Yell"]               = true,
    ["Emote"]              = true,
    ["Party"]              = true,
    ["Raid"]               = true,
    ["Instance"]           = true,
    ["Officer"]            = true,
    ["Channel"]            = true,
}, true)
