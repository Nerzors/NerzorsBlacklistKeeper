local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("deDE", {
    ["Remembered"]             = "Gemerkt",

    ["Add to Remember Me"]      = "Zu Merken hinzufügen",
    ["Edit Remember Me entry"]  = "Merken-Eintrag bearbeiten",
    ["Remove from Remember Me"] = "Aus Merken entfernen",
    ["Remove %s-%s from Remember Me?"] = "%s-%s aus Merken entfernen?",

    ["Rating"]         = "Bewertung",
    ["Default rating"] = "Standard-Bewertung",
    ["%d ★"]           = "%d ★",

    ["Show in unit tooltips"]     = "Im Spieler-Tooltip anzeigen",
    ["Prompt after Mythic+ runs"] = "Nach Mythic+-Runs nachfragen",
    ["Clear Remember Me..."]      = "Merken-Liste löschen...",
    ["Clear all %d Remember Me entries?"] = "Alle %d Merken-Einträge löschen?",
    ["Cleared %d Remember Me entries."]   = "%d Merken-Einträge gelöscht.",

    ["No entries yet - finish a Mythic+ run to remember your party-mates."]
        = "Noch keine Einträge - schließe einen Mythic+-Run ab, um Gruppenmitglieder zu merken.",

    ["Mythic+ run finished"] = "Mythic+-Run abgeschlossen",
    ["%s +%d - %s"]          = "%s +%d - %s",
    ["timed"]                = "im Limit",
    ["depleted"]             = "über Zeit",
    ["Rate your party-mates"] = "Bewerte deine Gruppe",

    ["%s-%s is on the Blacklist. Remove from Blacklist?"]
        = "%s-%s steht auf der Sperrliste. Von der Sperrliste entfernen?",
    ["%s-%s is in Remember Me. Remove from Remember Me?"]
        = "%s-%s ist in Merken. Aus Merken entfernen?",

    ["Added %s-%s to Remember Me."]   = "%s-%s zu Merken hinzugefügt.",
    ["Removed %s-%s from Remember Me."] = "%s-%s aus Merken entfernt.",

    ["invalid name/realm"]            = "ungültiger Name/Realm",
})
