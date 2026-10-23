local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("esMX", {
    ["Recent party-mates"]                                      = "Compañeros de grupo recientes",
    ["Tracks the last %d unique party-mates (party only - not raid)."]
        = "Guarda tus últimos %d compañeros de grupo distintos (solo grupo, no banda).",
    ["Recents (%d / %d)"]                                       = "Grupos recientes (%d / %d)",

    ["Storage"]         = "Almacenamiento",
    ["Account-wide"]    = "Para toda la cuenta",
    ["Per-character"]   = "Por personaje",
    ["Maximum entries"] = "Máximo de entradas",

    ["Remove from recents"]                  = "Quitar de recientes",
    ["Remove %s-%s from recents?"]           = "¿Quitar a %s-%s de recientes?",
    ["Clear recents..."]                     = "Vaciar recientes...",
    ["Clear all %d recents entries?"]        = "¿Borrar las %d entradas recientes?",
    ["Cleared %d recents entries."]          = "Entradas recientes borradas: %d.",
})
