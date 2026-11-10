local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("deDE", {

    ["All characters"] = "Alle Charaktere",

    ["Characters: %d"] = "Charaktere: %d",
    ["Snapshot from %s"] = "Stand vom %s",
    ["Older than 30 days - log in on this character to update it."] = "Älter als 30 Tage - melde dich auf diesem Charakter an, um ihn zu aktualisieren.",
    ["Ignored on: %d / %d"] = "Ignoriert auf: %d / %d",

    ["Log in once on each character so the overview is complete; a date in the warning colour is older than 30 days. Click a cell to change it - on other characters the change waits for their next login."] = "Melde dich einmal auf jedem Charakter an, damit die Übersicht vollständig ist; ein Datum in Warnfarbe ist älter als 30 Tage. Klicke auf ein Feld, um es zu ändern - auf anderen Charakteren wartet die Änderung auf deren nächsten Login.",
    ["Ignored"] = "Ignoriert",
    ["Not ignored"] = "Nicht ignoriert",
    ["Planned: remove at next login"] = "Geplant: beim nächsten Login entfernen",
    ["Planned: ignore at next login"] = "Geplant: beim nächsten Login ignorieren",
    ["Last attempt failed: the ignore list is full."] = "Letzter Versuch fehlgeschlagen: Die Ignorieren-Liste ist voll.",
    ["Last attempt failed."] = "Letzter Versuch fehlgeschlagen.",
    ["Click to remove now"] = "Klicken: jetzt entfernen",
    ["Click to ignore now"] = "Klicken: jetzt ignorieren",
    ["Click to remove at next login"] = "Klicken: beim nächsten Login entfernen",
    ["Click to ignore at next login"] = "Klicken: beim nächsten Login ignorieren",
    ["Click to cancel"] = "Klicken: abbrechen",
    ["Planned changes: %d"] = "Geplante Änderungen: %d",
    ["Could not ignore %s - the ignore list is full."] = "%s konnte nicht ignoriert werden - die Ignorieren-Liste ist voll.",
    ["Ignore Manager - planned changes done: %d, failed: %d"] = "Ignore-Manager - geplante Änderungen erledigt: %d, fehlgeschlagen: %d",

    ["Changes to this character's ignore list are planned: %d"] = "Für diesen Charakter sind Änderungen an der Ignorieren-Liste geplant: %d",
    ["planned on %s"] = "geplant auf %s",
    ["Run planned changes automatically from now on"] = "Geplante Änderungen künftig automatisch ausführen",
    ["Run now"] = "Ausführen",
    ["Later"] = "Später",
    ["Discard"] = "Verwerfen",
    ["Planned changes discarded: %d"] = "Geplante Änderungen verworfen: %d",
    ["Run planned ignore-list changes automatically at login"] = "Geplante Änderungen an der Ignorieren-Liste beim Login automatisch ausführen",
    ["Changes you plan in the Ignore Manager for another character run at that character's next login - with this option right away, otherwise NBK asks first. The blacklist is never changed automatically."] = "Änderungen, die du im Ignore-Manager für einen anderen Charakter planst, laufen bei dessen nächstem Login - mit dieser Option sofort, sonst fragt NBK vorher nach. Die Blacklist wird dabei nie automatisch geändert.",

    ["Ignore everywhere"] = "Überall ignorieren",
    ["Remove everywhere"] = "Überall entfernen",
    ["Ignores the selected players on every character: right away on this one, at their next login on the others."] = "Ignoriert die ausgewählten Spieler auf jedem Charakter: auf diesem sofort, auf den anderen beim nächsten Login.",
    ["Removes the selected players from every character's ignore list: right away on this one, at their next login on the others."] = "Entfernt die ausgewählten Spieler von der Ignorieren-Liste jedes Charakters: auf diesem sofort, auf den anderen beim nächsten Login.",
    ["Ignore %d selected players on all characters?"] = "%d ausgewählte Spieler auf allen Charakteren ignorieren?",
    ["Remove %d selected players from all characters?"] = "%d ausgewählte Spieler von allen Charakteren entfernen?",
    ["On this character, right away: %d"] = "Auf diesem Charakter, sofort: %d",
    ["At the next login on %d other characters: %d"] = "Beim nächsten Login auf %d anderen Charakteren: %d",
    ["Planned changes cancelled: %d"] = "Geplante Änderungen aufgehoben: %d",
    ["Only %d more fit on this character's ignore list."] = "Auf die Ignorieren-Liste dieses Charakters passen nur noch %d.",
    ["Nothing to change - the selected players are already like that on every character."] = "Nichts zu ändern - die ausgewählten Spieler sind auf jedem Charakter schon so eingetragen.",
    ["Ignore everywhere - ignored here: %d, planned for other characters: %d"] = "Überall ignorieren - hier ignoriert: %d, für andere Charaktere geplant: %d",
    ["Remove everywhere - removed here: %d, planned for other characters: %d"] = "Überall entfernen - hier entfernt: %d, für andere Charaktere geplant: %d",

    ["Players that no longer exist: %d"] = "Spieler, die es nicht mehr gibt: %d",
    ["Clean up"] = "Aufräumen",
    ["No longer exists - the game removes it at this character's next login."] = "Existiert nicht mehr - das Spiel entfernt den Eintrag beim nächsten Login dieses Charakters.",
    ["No longer exists (reported by the game on %s)"] = "Existiert nicht mehr (laut Spiel, gemeldet am %s)",
    ["These players no longer exist. Other characters still have them in their saved lists; the game removes them there at the next login. Remove them from the overview now?"] = "Diese Spieler gibt es nicht mehr. Andere Charaktere haben sie noch in ihren gespeicherten Listen; das Spiel entfernt sie dort beim nächsten Login. Jetzt aus der Übersicht entfernen?",
    ["Removed from the overview: %d"] = "Aus der Übersicht entfernt: %d",
})
