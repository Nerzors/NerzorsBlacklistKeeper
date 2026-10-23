local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("frFR", {

    ["Remembered"]                   = "Favori",

    ["Add to Remember Me"]           = "Ajouter aux favoris",
    ["Edit Remember Me entry"]       = "Modifier le favori",
    ["Remove from Remember Me"]      = "Retirer des favoris",
    ["Remove %s-%s from Remember Me?"] = "Retirer %s-%s des favoris ?",

    ["Rating"]                       = "Évaluation",
    ["Default rating"]               = "Évaluation par défaut",
    ["%d ★"]                         = "%d ★",

    ["Show in unit tooltips"]        = "Afficher dans les infobulles",
    ["Prompt after Mythic+ runs"]    = "Proposer après les donjons mythiques +",
    ["Clear Remember Me..."]         = "Vider les favoris...",
    ["Clear all %d Remember Me entries?"] = "Supprimer les %d favoris ?",
    ["Cleared %d Remember Me entries."]   = "Favoris supprimés : %d.",

    ["No entries yet - finish a Mythic+ run to remember your party-mates."]
        = "Aucune entrée pour l'instant : terminez un donjon mythique + pour retenir vos coéquipiers.",

    ["Mythic+ run finished"]         = "Donjon mythique + terminé",
    ["%s +%d - %s"]                  = "%s +%d - %s",
    ["timed"]                        = "dans les temps",
    ["depleted"]                     = "hors délai",
    ["Rate your party-mates"]        = "Évaluez vos coéquipiers",

    ["%s-%s is on the Blacklist. Remove from Blacklist?"]   = "%s-%s est sur la liste noire. Le retirer de la liste noire ?",
    ["%s-%s is in Remember Me. Remove from Remember Me?"]   = "%s-%s est dans les favoris. Le retirer des favoris ?",

    ["Added %s-%s to Remember Me."]  = "%s-%s ajouté aux favoris.",
    ["Removed %s-%s from Remember Me."] = "%s-%s retiré des favoris.",

    ["invalid name/realm"]           = "nom/royaume invalide",
})
