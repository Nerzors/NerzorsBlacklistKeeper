local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("frFR", {
    ["Group Finder warnings"]                              = "Alertes de la recherche de groupe",
    ["Enable Group Finder warnings"]                       = "Activer les alertes dans la recherche de groupe",
    ["Flag blacklisted leaders in search results"]         = "Signaler les chefs sur liste noire dans les résultats",
    ["Warn before applying to a blacklisted leader"]       = "Avertir avant de postuler auprès d'un chef sur liste noire",
    ["Warn when a blacklisted player applies to my group"] = "Avertir quand un joueur sur liste noire postule à mon groupe",
    ["LFG applicant |cff%s%s|r-%s is blacklisted (%s)"]    = "Le candidat |cff%s%s|r-%s est sur la liste noire (%s)",
})
