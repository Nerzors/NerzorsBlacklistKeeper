local NBK = _G.NBK
if not NBK then return end

-- Locals for NerzorsBlacklistKeeper_RememberMe
-- French (French) localization for TRP3_NBK by Sanoca - marécage-de-zangar.
-- Note: tested and created for version 2.0.0-dev.0.46.0

NBK:RegisterLocaleStrings("frFR", {
    ["Remember Me"]            = "À retenir",
    ["Remembered"]             = "Retenu",

    ["Add to Remember Me"]      = "Ajouter à la liste À retenir",
    ["Edit Remember Me entry"]  = "Modifier l'entrée À retenir",
    ["Remove from Remember Me"] = "Retirer de la liste À retenir",
    ["Remove %s-%s from Remember Me?"] = "Retirer %s-%s de la liste À retenir ?",

    ["Rating"]         = "Note",
    ["Default rating"] = "Note par défaut",
    ["%d ★"]           = "%d ★",

    ["Show in unit tooltips"]     = "Afficher dans les infobulles des unités",
    ["Prompt after Mythic+ runs"] = "Demander après les donjons Mythique+",
    ["Clear Remember Me..."]      = "Vider la liste À retenir...",
    ["Clear all %d Remember Me entries?"] = "Supprimer les %d entrées de la liste À retenir ?",
    ["Cleared %d Remember Me entries."]   = "%d entrées de la liste À retenir supprimées.",

    ["No entries yet - finish a Mythic+ run to remember your party-mates."]
        = "Aucune entrée pour le moment - terminez un donjon Mythique+ pour retenir les membres de votre groupe.",

    ["Mythic+ run finished"] = "Donjon Mythique+ terminé",
    ["%s +%d - %s"]          = "%s +%d - %s",
    ["timed"]                = "dans le temps imparti",
    ["depleted"]             = "temps dépassé",
    ["Rate your party-mates"] = "Notez les membres de votre groupe",
    ["Done"]                 = "Terminé",

    ["%s-%s is on the Blacklist. Remove from Blacklist?"]
        = "%s-%s figure sur la liste noire. Le retirer de la liste noire ?",
    ["%s-%s is in Remember Me. Remove from Remember Me?"]
        = "%s-%s figure dans la liste À retenir. Le retirer de cette liste ?",

    ["Added %s-%s to Remember Me."]   = "%s-%s ajouté à la liste À retenir.",
    ["Removed %s-%s from Remember Me."] = "%s-%s retiré de la liste À retenir.",
})