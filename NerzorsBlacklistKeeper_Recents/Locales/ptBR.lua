local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("ptBR", {
    ["Recent party-mates"]                                      = "Colegas de grupo recentes",
    ["Tracks the last %d unique party-mates (party only - not raid)."]
        = "Guarda os últimos %d colegas de grupo diferentes (só grupo, não raide).",
    ["Recents (%d / %d)"]                                       = "Grupos recentes (%d / %d)",

    ["Storage"]         = "Armazenamento",
    ["Account-wide"]    = "Para a conta toda",
    ["Per-character"]   = "Por personagem",
    ["Maximum entries"] = "Máximo de entradas",

    ["Remove from recents"]                  = "Remover dos recentes",
    ["Remove %s-%s from recents?"]           = "Remover %s-%s dos recentes?",
    ["Clear recents..."]                     = "Limpar recentes...",
    ["Clear all %d recents entries?"]        = "Apagar todas as %d entradas recentes?",
    ["Cleared %d recents entries."]          = "Entradas recentes apagadas: %d.",
})
