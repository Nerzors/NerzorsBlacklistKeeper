local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("itIT", {
    ["Recent party-mates"]                                      = "Compagni di gruppo recenti",
    ["Tracks the last %d unique party-mates (party only - not raid)."]
        = "Tiene traccia degli ultimi %d compagni di gruppo diversi (solo gruppo, non incursioni).",
    ["Recents (%d / %d)"]                                       = "Gruppi recenti (%d / %d)",

    ["Storage"]         = "Salvataggio",
    ["Account-wide"]    = "Per tutto l'account",
    ["Per-character"]   = "Per personaggio",
    ["Maximum entries"] = "Numero massimo di voci",

    ["Remove from recents"]                  = "Rimuovi dai recenti",
    ["Remove %s-%s from recents?"]           = "Rimuovere %s-%s dai recenti?",
    ["Clear recents..."]                     = "Svuota i recenti...",
    ["Clear all %d recents entries?"]        = "Eliminare tutte le %d voci recenti?",
    ["Cleared %d recents entries."]          = "Voci recenti eliminate: %d.",
})
