local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("deDE", {
    ["Group Finder warnings"]                              = "Gruppensuche-Warnungen",
    ["Enable Group Finder warnings"]                       = "Warnungen in der Gruppensuche aktivieren",
    ["Flag blacklisted leaders in search results"]         = "Gelistete Anführer in Suchergebnissen markieren",
    ["Warn before applying to a blacklisted leader"]       = "Warnen, bevor ich mich bei einem gelisteten Anführer bewerbe",
    ["Warn when a blacklisted player applies to my group"] = "Warnen, wenn ein gelisteter Spieler meiner Gruppe beitreten will",
    ["LFG applicant |cff%s%s|r-%s is blacklisted (%s)"]    = "Gruppensuche-Bewerber |cff%s%s|r-%s ist auf der Sperrliste (%s)",
})
