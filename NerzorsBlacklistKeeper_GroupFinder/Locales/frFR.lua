local NBK = _G.NBK
if not NBK then return end

-- Locals for NerzorsBlacklistKeeper_GroupFinder
-- French (French) localization for TRP3_NBK by Sanoca - marécage-de-zangar.
-- Note: tested and created for version 2.0.0-dev.0.46.0

NBK:RegisterLocaleStrings("frFR", {
    ["Group Finder warnings"]                              = "Alertes de recherche de groupe",
    ["Enable Group Finder warnings"]                       = "Activer les alertes de recherche de groupe",
    ["Flag blacklisted leaders in search results"]         = "Signaler les chefs de groupe sur liste noire dans les résultats de recherche",
    ["Warn before applying to a blacklisted leader"]       = "Avertir avant de postuler auprès d'un chef de groupe sur liste noire",
    ["Warn when a blacklisted player applies to my group"] = "Avertir lorsqu'un joueur sur liste noire postule pour rejoindre mon groupe",
    ["LFG applicant |cff%s%s|r-%s is blacklisted (%s)"]    = "Le candidat à la recherche de groupe |cff%s%s|r-%s figure sur la liste noire (%s)",
})