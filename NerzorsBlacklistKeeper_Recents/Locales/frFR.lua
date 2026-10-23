local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("frFR", {
    ["Recent party-mates"]                                      = "Coéquipiers récents",
    ["Tracks the last %d unique party-mates (party only - not raid)."]
        = "Mémorise vos %d derniers coéquipiers différents (groupe uniquement, pas en raid).",
    ["Recents (%d / %d)"]                                       = "Groupes récents (%d / %d)",

    ["Storage"]         = "Enregistrement",
    ["Account-wide"]    = "Pour tout le compte",
    ["Per-character"]   = "Par personnage",
    ["Maximum entries"] = "Nombre maximal d'entrées",

    ["Remove from recents"]                  = "Retirer des récents",
    ["Remove %s-%s from recents?"]           = "Retirer %s-%s des récents ?",
    ["Clear recents..."]                     = "Vider les récents...",
    ["Clear all %d recents entries?"]        = "Supprimer les %d entrées récentes ?",
    ["Cleared %d recents entries."]          = "Entrées récentes supprimées : %d.",
})
