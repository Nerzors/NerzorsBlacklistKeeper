local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("itIT", {

    ["Enable sharing (send & receive)"]      = "Attiva la condivisione (invio e ricezione)",
    ["Accept shares from"]                   = "Accetta condivisioni da",
    ["anyone"]                               = "chiunque",
    ["guild"]                                = "gilda",
    ["friends"]                              = "amici",
    ["nobody"]                               = "nessuno",
    ["Auto-open import preview on receive"]  = "Apri automaticamente l'anteprima alla ricezione",
    ["Announce in chat when sharing"]        = "Annuncia in chat quando condividi",
    ["New entries shareable by default"]     = "Nuove voci condivisibili in automatico",
    ["Export only shareable entries"]        = "Esporta solo le voci condivisibili",
    ["Debug (verbose send/receive log)"]     = "Debug (registro dettagliato di invio/ricezione)",
    ["Share with"]                           = "Condividi con",
    ["name[-realm]"]                         = "nome[-reame]",
    ["Whisper"]                              = "Sussurra",
    ["Guild"]                                = "Gilda",

    ["%d shareable entries exported."]       = "Voci condivisibili esportate: %d.",
    ["%d private entries held back."]        = "Voci private non esportate: %d.",
    ["Shared %d entries with %s."]           = "%d voci condivise con %s.",
    ["Skipped %d oversized entries."]        = "Voci troppo grandi saltate: %d.",
    ["%s shared %d blacklist entries."]      = "%s ha condiviso %d voci della lista nera.",
    ["%s sent an empty share."]              = "%s ha inviato una condivisione vuota.",
    ["Use /nbk share show to review."]       = "Usa /nbk share show per controllarla.",
    ["from %s"]                              = "da %s",

    ["share via whisper"]                    = "condividi con un sussurro",
    ["broadcast to guild"]                   = "invia alla gilda",

    ["Tip: addon-whispers need the recipient online + a recent contact relationship (friend / guildmate / group / recent /w). If they see nothing, send them a normal whisper first or use Guild channel."]
        = "Suggerimento: i sussurri tra add-on richiedono che il destinatario sia online e che ci sia un contatto recente (amico / membro di gilda / gruppo / sussurro recente). Se non riceve nulla, inviagli prima un normale sussurro o usa il canale di gilda.",

    ["Auto-Sync"]                            = "Auto-Sync",
    ["Auto-Sync new blacklist entries"]      = "Condividi automaticamente le nuove voci della lista nera",
    ["Send to"]                              = "Invia a",
    ["Friends"]                              = "Amici",
    ["Specific characters"]                  = "Personaggi specifici",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Spunta i personaggi che devono ricevere automaticamente le nuove voci (Nome-Reame).",
    ["Name-Realm"]                           = "Nome-Reame",

    ["Auto-Sync blacklist push"]             = "Auto-Sync: voce della lista nera",
    ["%s wants to share an entry:"]          = "%s vuole condividere una voce:",
    ["%s auto-shared %s-%s."]                = "%s ha condiviso automaticamente %s-%s.",
    ["Reason: %s"]                           = "Motivo: %s",
    ["Decline"]                              = "Rifiuta",
    ["From"]                                 = "Da",
    ["%s shared %d entries (%s)."]           = "%s ha condiviso %d voci (%s).",

    ["missing target"]                       = "destinatario mancante",
    ["not in a guild"]                       = "non sei in una gilda",
    ["not in a group"]                       = "non sei in un gruppo",
    ["sync disabled"]                        = "condivisione disattivata",
    ["no shareable entries (all marked private)"] = "nessuna voce condivisibile (tutte private)",
    ["list is empty"]                        = "la lista è vuota",
    ["no pending share"]                     = "nessuna condivisione in sospeso",
})
