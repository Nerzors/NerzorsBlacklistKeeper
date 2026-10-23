local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("itIT", {

    ["Remembered"]                   = "Preferito",

    ["Add to Remember Me"]           = "Aggiungi ai Preferiti",
    ["Edit Remember Me entry"]       = "Modifica la voce dei Preferiti",
    ["Remove from Remember Me"]      = "Rimuovi dai Preferiti",
    ["Remove %s-%s from Remember Me?"] = "Rimuovere %s-%s dai Preferiti?",

    ["Rating"]                       = "Valutazione",
    ["Default rating"]               = "Valutazione predefinita",
    ["%d ★"]                         = "%d ★",

    ["Show in unit tooltips"]        = "Mostra nei tooltip",
    ["Prompt after Mythic+ runs"]    = "Chiedi dopo le spedizioni Mitiche+",
    ["Clear Remember Me..."]         = "Svuota i Preferiti...",
    ["Clear all %d Remember Me entries?"] = "Eliminare tutte le %d voci dei Preferiti?",
    ["Cleared %d Remember Me entries."]   = "Voci dei Preferiti eliminate: %d.",

    ["No entries yet - finish a Mythic+ run to remember your party-mates."]
        = "Ancora nessuna voce: completa una spedizione Mitica+ per ricordare i tuoi compagni di gruppo.",

    ["Mythic+ run finished"]         = "Spedizione Mitica+ completata",
    ["%s +%d - %s"]                  = "%s +%d - %s",
    ["timed"]                        = "in tempo",
    ["depleted"]                     = "fuori tempo",
    ["Rate your party-mates"]        = "Valuta i tuoi compagni di gruppo",

    ["%s-%s is on the Blacklist. Remove from Blacklist?"]   = "%s-%s è nella lista nera. Rimuoverlo dalla lista nera?",
    ["%s-%s is in Remember Me. Remove from Remember Me?"]   = "%s-%s è nei Preferiti. Rimuoverlo dai Preferiti?",

    ["Added %s-%s to Remember Me."]  = "%s-%s aggiunto ai Preferiti.",
    ["Removed %s-%s from Remember Me."] = "%s-%s rimosso dai Preferiti.",

    ["invalid name/realm"]           = "nome/reame non valido",
})
