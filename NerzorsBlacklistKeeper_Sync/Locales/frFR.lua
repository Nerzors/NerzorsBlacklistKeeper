local NBK = _G.NBK
if not NBK then return end

-- Locals for NerzorsBlacklistKeeper_Sync
-- French (French) localization for TRP3_NBK by Sanoca - marécage-de-zangar.
-- Note: untested and created for version 2.0.0-dev.0.46.0

NBK:RegisterLocaleStrings("frFR", {

    ["Sharing"]                              = "Partage",
    ["Enable sharing (send & receive)"]      = "Activer le partage (envoi et réception)",
    ["Accept shares from"]                   = "Accepter les partages de",
    ["anyone"]                               = "tout le monde",
    ["guild"]                                = "la guilde",
    ["friends"]                              = "les amis",
    ["nobody"]                               = "personne",
    ["Auto-open import preview on receive"]  = "Afficher automatiquement l'aperçu à la réception",
    ["Announce in chat when sharing"]        = "Annoncer les partages dans le chat",
    ["New entries shareable by default"]     = "Rendre les nouvelles entrées partageables par défaut",
    ["Export only shareable entries"]        = "Exporter uniquement les entrées partageables",
    ["Debug (verbose send/receive log)"]     = "Débogage (journal détaillé des envois et réceptions)",
    ["Share with"]                           = "Partager avec",
    ["name[-realm]"]                         = "nom[-royaume]",
    ["Whisper"]                              = "Message privé",
    ["Guild"]                                = "Guilde",

    ["%d shareable entries exported."]       = "%d entrées partageables exportées.",
    ["%d private entries held back."]        = "%d entrées privées exclues.",
    ["Shared %d entries with %s."]           = "%d entrées partagées avec %s.",
    ["Skipped %d oversized entries."]        = "%d entrées trop volumineuses ignorées.",
    ["%s shared %d blacklist entries."]      = "%s a partagé %d entrées de la liste noire.",
    ["%s sent an empty share."]              = "%s a envoyé un partage vide.",
    ["Use /nbk share show to review."]       = "Utilisez /nbk share show pour consulter le partage.",
    ["from %s"]                              = "de %s",

    ["share via whisper"]                    = "partager par message privé",
    ["broadcast to guild"]                   = "envoyer à la guilde",

    ["Tip: addon-whispers need the recipient online + a recent contact relationship (friend / guildmate / group / recent /w). If they see nothing, send them a normal whisper first or use Guild channel."]
        = "Astuce : les messages privés de l'addon nécessitent que le destinataire soit connecté et qu'une relation de contact récente existe (ami / membre de guilde / groupe / message privé récent). Si le destinataire ne reçoit rien, envoyez-lui d'abord un message privé normal ou utilisez le canal de guilde.",

    ["Auto-Sync blacklist push"]             = "Envoi automatique des entrées de la liste noire",
    ["%s wants to share an entry:"]          = "%s souhaite partager une entrée :",
    ["%s auto-shared %s-%s."]                = "%s a partagé automatiquement %s-%s.",
    ["Reason: %s"]                           = "Motif : %s",
    ["no reason logged"]                     = "aucun motif renseigné",
    ["Add to blacklist"]                     = "Ajouter à la liste noire",
    ["Decline"]                              = "Refuser",
    ["From"]                                 = "De",
    ["Reason"]                               = "Motif",
    ["Note"]                                 = "Note",
    ["%s shared %d entries (%s)."]           = "%s a partagé %d entrées (%s).",
})