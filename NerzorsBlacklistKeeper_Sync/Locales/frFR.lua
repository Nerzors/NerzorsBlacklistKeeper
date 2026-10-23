local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("frFR", {

    ["Enable sharing (send & receive)"]      = "Activer le partage (envoi et réception)",
    ["Accept shares from"]                   = "Accepter les partages de",
    ["anyone"]                               = "tout le monde",
    ["guild"]                                = "la guilde",
    ["friends"]                              = "mes contacts",
    ["nobody"]                               = "personne",
    ["Auto-open import preview on receive"]  = "Ouvrir l'aperçu automatiquement à la réception",
    ["Announce in chat when sharing"]        = "Annoncer le partage dans la discussion",
    ["New entries shareable by default"]     = "Nouvelles entrées partageables par défaut",
    ["Export only shareable entries"]        = "Exporter uniquement les entrées partageables",
    ["Debug (verbose send/receive log)"]     = "Débogage (journal détaillé d'envoi/réception)",
    ["Share with"]                           = "Partager avec",
    ["name[-realm]"]                         = "nom[-royaume]",
    ["Whisper"]                              = "Chuchoter",
    ["Guild"]                                = "Guilde",

    ["%d shareable entries exported."]       = "Entrées partageables exportées : %d.",
    ["%d private entries held back."]        = "Entrées privées non exportées : %d.",
    ["Shared %d entries with %s."]           = "%d entrées partagées avec %s.",
    ["Skipped %d oversized entries."]        = "Entrées trop volumineuses ignorées : %d.",
    ["%s shared %d blacklist entries."]      = "%s a partagé %d entrées de liste noire.",
    ["%s sent an empty share."]              = "%s a envoyé un partage vide.",
    ["Use /nbk share show to review."]       = "Utilisez /nbk share show pour le consulter.",
    ["from %s"]                              = "de %s",

    ["share via whisper"]                    = "partager par chuchotement",
    ["broadcast to guild"]                   = "envoyer à la guilde",

    ["Tip: addon-whispers need the recipient online + a recent contact relationship (friend / guildmate / group / recent /w). If they see nothing, send them a normal whisper first or use Guild channel."]
        = "Astuce : les chuchotements d'add-on nécessitent que le destinataire soit en ligne et que vous ayez un contact récent (contact / membre de guilde / groupe / chuchotement récent). S'il ne reçoit rien, envoyez-lui d'abord un chuchotement normal ou utilisez le canal de guilde.",

    ["Auto-Sync"]                            = "Auto-Sync",
    ["Auto-Sync new blacklist entries"]      = "Partager automatiquement les nouvelles entrées",
    ["Send to"]                              = "Envoyer à",
    ["Friends"]                              = "Contacts",
    ["Specific characters"]                  = "Personnages précis",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Cochez les personnages qui doivent recevoir automatiquement les nouvelles entrées (Nom-Royaume).",
    ["Name-Realm"]                           = "Nom-Royaume",

    ["Auto-Sync blacklist push"]             = "Auto-Sync : entrée de liste noire",
    ["%s wants to share an entry:"]          = "%s veut partager une entrée :",
    ["%s auto-shared %s-%s."]                = "%s a partagé automatiquement %s-%s.",
    ["Reason: %s"]                           = "Raison : %s",
    ["Decline"]                              = "Refuser",
    ["From"]                                 = "De",
    ["%s shared %d entries (%s)."]           = "%s a partagé %d entrées (%s).",

    ["missing target"]                       = "destinataire manquant",
    ["not in a guild"]                       = "vous n'êtes pas dans une guilde",
    ["not in a group"]                       = "vous n'êtes pas dans un groupe",
    ["sync disabled"]                        = "partage désactivé",
    ["no shareable entries (all marked private)"] = "aucune entrée partageable (toutes privées)",
    ["list is empty"]                        = "la liste est vide",
    ["no pending share"]                     = "aucun partage en attente",
})
