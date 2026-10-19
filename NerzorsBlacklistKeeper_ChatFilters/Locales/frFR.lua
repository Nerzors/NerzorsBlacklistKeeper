local NBK = _G.NBK
if not NBK then return end

-- Locals for NerzorsBlacklistKeeper_ChatFilters
-- French (French) localization for TRP3_NBK by Sanoca - marécage-de-zangar.
-- Note: tested and created for version 2.0.0-dev.0.46.0

NBK:RegisterLocaleStrings("frFR", {

    ["Chat filters"]                          = "Filtres de chat",
    ["Channels"]                              = "Canaux",
    ["Blocked words"]                         = "Mots bloqués",
    ["Whitelist (sender exclusions)"]         = "Liste blanche (expéditeurs exclus)",
    ["Statistics"]                            = "Statistiques",

    ["One name per line. Use Name-Realm to pin a specific realm; bare names match any realm."] =
        "Un nom par ligne. Utilisez Nom-Royaume pour cibler un royaume précis ; un nom seul correspond à tous les royaumes.",
    ["Censored: %d"]                          = "Censurés : %d",
    ["Hidden: %d"]                            = "Masqués : %d",
    ["Whitelisted: %d"]                      = "Autorisés par la liste blanche : %d",
    ["Reset statistics"]                      = "Réinitialiser les statistiques",

    ["Enable chat word filter"]               = "Activer le filtre de mots du chat",
    ["Filter mode"]                           = "Mode de filtrage",
    ["Censor (replace with ***)"]             = "Censurer (remplacer par ***)",
    ["Hide (drop message)"]                   = "Masquer (supprimer le message)",
    ["Match whole words only"]                = "Correspondre uniquement aux mots entiers",
    ["Case sensitive"]                        = "Respecter la casse",
    ["One word or phrase per line. Edits save on Apply."] =
        "Un mot ou une expression par ligne. Les modifications sont enregistrées en cliquant sur « Appliquer ».",
    ["Apply"]                                 = "Appliquer",
    ["Revert"]                                = "Annuler les modifications",

    ["Say"]                                   = "Dire",
    ["Yell"]                                  = "Crier",
    ["Emote"]                                 = "Émote",
    ["Party"]                                 = "Groupe",
    ["Party leader"]                          = "Chef de groupe",
    ["Raid"]                                  = "Raid",
    ["Raid leader"]                           = "Chef de raid",
    ["Raid warning"]                          = "Avertissement de raid",
    ["Instance"]                              = "Instance",
    ["Instance leader"]                       = "Chef d'instance",
    ["Officer"]                               = "Officier",
    ["Public channels"]                       = "Canaux publics",
    ["Channel"]                               = "Canal",

    ["Message history"]                       = "Historique des messages",
    ["Saved chat from muted blacklisted players."] =
        "Messages conservés des joueurs de la liste noire mis en sourdine.",
    ["Save muted players' messages"]          = "Enregistrer les messages des joueurs mis en sourdine",
    ["Keep messages for"]                     = "Conserver les messages pendant",
    ["%d days"]                               = "%d jours",
    ["Forever"]                               = "Indéfiniment",
    ["Open history"]                          = "Ouvrir l'historique",
    ["Clear all history"]                     = "Effacer tout l'historique",
    ["Clear saved messages for all %d players?"] =
        "Supprimer les messages enregistrés pour les %d joueurs ?",
    ["Message history cleared."]              = "Historique des messages effacé.",
    ["Saved messages"]                        = "Messages enregistrés",
    ["View messages"]                         = "Voir les messages",
    ["View saved messages"]                   = "Voir les messages enregistrés",
    ["Delete history"]                        = "Supprimer l'historique",
    ["Clear messages"]                        = "Effacer les messages",
    ["Delete all saved messages from %s-%s?"] =
        "Supprimer tous les messages enregistrés de %s-%s ?",
    ["Messages"]                              = "Messages",
    ["%d msgs"]                               = "%d mess.",
    ["Search name, realm..."]                 = "Rechercher un nom, un royaume...",
    ["History (%d)"]                          = "Historique (%d)",
})