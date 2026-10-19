local NBK = _G.NBK
if not NBK then return end

-- Locals for NerzorsBlacklistKeeper_Recents
-- French (French) localization for TRP3_NBK by Sanoca - marécage-de-zangar.
-- Note: tested and created for version 2.0.0-dev.0.45.0

NBK:RegisterLocaleStrings("frFR", {
    ["Recents"]            = "Groupes récents",
    ["Recent party-mates"] = "Membres de groupe récents",
    ["Tracks the last %d unique party-mates (party only - not raid)."]
                           = "Enregistre les %d derniers membres de groupe distincts (groupes uniquement, pas les raids).",
    ["Recents (%d / %d)"]  = "Groupes récents (%d / %d)",

    ["Storage"]         = "Stockage",
    ["Account-wide"]    = "Compte entier",
    ["Per-character"]   = "Par personnage",
    ["Maximum entries"] = "Nombre maximal d'entrées",

    ["Remove from recents"]            = "Retirer des groupes récents",
    ["Remove %s-%s from recents?"]     = "Retirer %s-%s des groupes récents ?",
    ["Clear recents..."]               = "Effacer les groupes récents...",
    ["Clear all %d recents entries?"]  = "Effacer les %d entrées des groupes récents ?",
    ["Cleared %d recents entries."]    = "%d entrées des groupes récents effacées.",
})