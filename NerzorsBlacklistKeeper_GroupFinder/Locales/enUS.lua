local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("enUS", {
    ["Group Finder warnings"]                                   = true,
    ["Enable Group Finder warnings"]                            = true,
    ["Flag blacklisted leaders in search results"]              = true,
    ["Warn before applying to a blacklisted leader"]            = true,
    ["Warn when a blacklisted player applies to my group"]      = true,
    ["LFG applicant |cff%s%s|r-%s is blacklisted (%s)"]         = true,
}, true)
