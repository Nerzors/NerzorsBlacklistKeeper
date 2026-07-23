local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("deDE", {

    ["Chat filters"]                          = "Chat-Filter",
    ["Channels"]                              = "Kanäle",
    ["Blocked words"]                         = "Gesperrte Wörter",
    ["Whitelist (sender exclusions)"]         = "Whitelist (Absender-Ausnahmen)",
    ["Statistics"]                            = "Statistik",

    ["One name per line. Use Name-Realm to pin a specific realm; bare names match any realm."] =
        "Ein Name pro Zeile. Mit Name-Realm wird ein bestimmter Realm festgelegt; einzelne Namen treffen auf jeden Realm.",
    ["Censored: %d"]                          = "Zensiert: %d",
    ["Hidden: %d"]                            = "Ausgeblendet: %d",
    ["Whitelisted: %d"]                       = "Whitelist-Treffer: %d",
    ["Reset statistics"]                      = "Statistik zurücksetzen",

    ["Enable chat word filter"]               = "Chat-Wortfilter aktivieren",
    ["Filter mode"]                           = "Filter-Modus",
    ["Censor (replace with ***)"]             = "Zensieren (durch *** ersetzen)",
    ["Hide (drop message)"]                   = "Ausblenden (Nachricht verwerfen)",
    ["Match whole words only"]                = "Nur ganze Wörter treffen",
    ["Case sensitive"]                        = "Groß-/Kleinschreibung beachten",
    ["One word or phrase per line. Edits save on Apply."] =
        "Ein Wort oder Ausdruck pro Zeile. Änderungen werden mit 'Übernehmen' gespeichert.",
    ["Apply"]                                 = "Übernehmen",
    ["Revert"]                                = "Zurücksetzen",

    ["Say"]                                   = "Sagen",
    ["Yell"]                                  = "Schreien",
    ["Emote"]                                 = "Emote",
    ["Party"]                                 = "Gruppe",
    ["Party leader"]                          = "Gruppenanführer",
    ["Raid"]                                  = "Schlachtzug",
    ["Raid leader"]                           = "Schlachtzugsanführer",
    ["Raid warning"]                          = "Schlachtzugswarnung",
    ["Instance"]                              = "Instanz",
    ["Instance leader"]                       = "Instanzanführer",
    ["Officer"]                               = "Offizier",
    ["Public channels"]                       = "Öffentliche Kanäle",
    ["Channel"]                               = "Kanal",

    ["Message history"]                       = "Nachrichtenverlauf",
    ["Saved chat from muted blacklisted players."] =
        "Gespeicherter Chat von stummgeschalteten Spielern der Blacklist.",
    ["Save muted players' messages"]          = "Nachrichten stummgeschalteter Spieler speichern",
    ["Keep messages for"]                     = "Nachrichten aufbewahren für",
    ["%d days"]                               = "%d Tage",
    ["Forever"]                               = "Für immer",
    ["Open history"]                          = "Verlauf öffnen",
    ["Clear all history"]                     = "Gesamten Verlauf löschen",
    ["Clear saved messages for all %d players?"] =
        "Gespeicherte Nachrichten aller %d Spieler löschen?",
    ["Message history cleared."]              = "Nachrichtenverlauf gelöscht.",
    ["Saved messages"]                        = "Gespeicherte Nachrichten",
    ["View messages"]                         = "Nachrichten ansehen",
    ["View saved messages"]                   = "Gespeicherte Nachrichten ansehen",
    ["Delete history"]                        = "Verlauf löschen",
    ["Clear messages"]                        = "Nachrichten löschen",
    ["Delete all saved messages from %s-%s?"] =
        "Alle gespeicherten Nachrichten von %s-%s löschen?",
    ["Messages"]                              = "Nachrichten",
    ["%d msgs"]                               = "%d Nachr.",
    ["Search name, realm..."]                 = "Name, Realm suchen...",
    ["History (%d)"]                          = "Verlauf (%d)",
})
