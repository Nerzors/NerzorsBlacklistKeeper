local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("deDE", {

    ["Sharing"]                              = "Sync",
    ["Enable sharing (send & receive)"]      = "Teilen aktivieren (senden & empfangen)",
    ["Accept shares from"]                   = "Empfangen von",
    ["anyone"]                               = "jedem",
    ["guild"]                                = "Gilde",
    ["friends"]                              = "Freunden",
    ["nobody"]                               = "niemandem",
    ["Auto-open import preview on receive"]  = "Empfangene Liste automatisch als Vorschau öffnen",
    ["Announce in chat when sharing"]        = "Teilen im Chat bestätigen",
    ["New entries shareable by default"]     = "Neue Einträge standardmäßig teilbar",
    ["Export only shareable entries"]        = "Nur teilbare Einträge exportieren",
    ["Debug (verbose send/receive log)"]     = "Debug (ausführliches Sende-/Empfangs-Log)",
    ["Share with"]                           = "Teilen mit",
    ["name[-realm]"]                         = "Name[-Realm]",
    ["Whisper"]                              = "Flüstern",
    ["Guild"]                                = "Gilde",

    ["%d shareable entries exported."]       = "%d teilbare Einträge exportiert.",
    ["%d private entries held back."]        = "%d private Einträge zurückgehalten.",
    ["Shared %d entries with %s."]           = "%d Einträge mit %s geteilt.",
    ["Skipped %d oversized entries."]        = "%d zu große Einträge übersprungen.",
    ["%s shared %d blacklist entries."]      = "%s hat %d Einträge geteilt.",
    ["%s sent an empty share."]              = "%s hat eine leere Liste geschickt.",
    ["Use /nbk share show to review."]       = "Nutze /nbk share show, um sie zu öffnen.",
    ["from %s"]                              = "von %s",

    ["share via whisper"]                    = "per Flüstern teilen",
    ["broadcast to guild"]                   = "an die Gilde senden",

    ["Tip: addon-whispers need the recipient online + a recent contact relationship (friend / guildmate / group / recent /w). If they see nothing, send them a normal whisper first or use Guild channel."]
        = "Tipp: Addon-Flüstern braucht den Empfänger online + eine Kontakt-Beziehung (Freund / Gildenmitglied / Gruppe / kürzlich geflüstert). Wenn nichts ankommt, schicke ihm zuerst eine normale /w-Nachricht oder nutze den Gilden-Kanal.",

    ["Auto-Sync blacklist push"]             = "Auto-Sync Blacklist-Push",
    ["%s wants to share an entry:"]          = "%s möchte einen Eintrag teilen:",
    ["%s auto-shared %s-%s."]                = "%s hat %s-%s automatisch geteilt.",
    ["Reason: %s"]                           = "Grund: %s",
    ["no reason logged"]                     = "kein Grund hinterlegt",
    ["Add to blacklist"]                     = "Auf Blacklist setzen",
    ["Decline"]                              = "Ablehnen",
    ["From"]                                 = "Von",
    ["Reason"]                               = "Grund",
    ["Note"]                                 = "Notiz",
    ["%s shared %d entries (%s)."]           = "%s hat %d Einträge geteilt (%s).",
})
