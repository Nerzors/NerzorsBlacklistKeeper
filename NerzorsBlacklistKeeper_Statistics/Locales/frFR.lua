local NBK = _G.NBK
if not NBK then return end

-- Locals for NerzorsBlacklistKeeper_Statistics
-- French (French) localization for TRP3_NBK by Sanoca - marécage-de-zangar.
-- Note: tested and created for version 2.0.0-dev.0.44.0

NBK:RegisterLocaleStrings("frFR", {

    ["Statistics"]         = "Statistiques",
    ["Entries per month"]  = "Entrées par mois",
    ["Top reasons"]        = "Principaux motifs",
    ["Top zones"]          = "Zones les plus fréquentes",
    ["Top realms"]         = "Royaumes les plus fréquents",
    ["By class"]           = "Par classe",
    ["Most encountered"]   = "Joueurs les plus rencontrés",
    ["Chat impact"]        = "Impact sur le chat",

    ["Entries"]            = "Entrées",
    ["New (30 days)"]      = "Nouvelles (30 jours)",
    ["Encounters"]         = "Rencontres",
    ["Messages"]           = "Messages",

    ["Censored"]           = "Censurés",
    ["Hidden"]             = "Masqués",
    ["Archived"]           = "Archivés",

    ["No reason"]          = "Sans motif",
    ["Unknown"]            = "Inconnu",
    ["No data yet"]        = "Aucune donnée pour le moment",

    ["Statistics needs an updated Data folder"] =
        "Statistiques : veuillez mettre à jour le dossier NerzorsBlacklistKeeper_Data.",

    ["Say"]                = "Dire",
    ["Yell"]               = "Crier",
    ["Emote"]              = "Émote",
    ["Party"]              = "Groupe",
    ["Raid"]               = "Raid",
    ["Instance"]           = "Instance",
    ["Officer"]            = "Officier",
    ["Channel"]            = "Canal",
})