local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("esMX", {

    ["Remembered"]                   = "Favorito",

    ["Add to Remember Me"]           = "Añadir a Favoritos",
    ["Edit Remember Me entry"]       = "Editar favorito",
    ["Remove from Remember Me"]      = "Quitar de Favoritos",
    ["Remove %s-%s from Remember Me?"] = "¿Quitar a %s-%s de Favoritos?",

    ["Rating"]                       = "Valoración",
    ["Default rating"]               = "Valoración predeterminada",
    ["%d ★"]                         = "%d ★",

    ["Show in unit tooltips"]        = "Mostrar en las descripciones emergentes",
    ["Prompt after Mythic+ runs"]    = "Preguntar tras los calabozos míticos+",
    ["Clear Remember Me..."]         = "Vaciar Favoritos...",
    ["Clear all %d Remember Me entries?"] = "¿Borrar los %d favoritos?",
    ["Cleared %d Remember Me entries."]   = "Favoritos borrados: %d.",

    ["No entries yet - finish a Mythic+ run to remember your party-mates."]
        = "Aún no hay entradas: completa un calabozo mítico+ para recordar a tus compañeros de grupo.",

    ["Mythic+ run finished"]         = "Calabozo mítico+ completado",
    ["%s +%d - %s"]                  = "%s +%d - %s",
    ["timed"]                        = "a tiempo",
    ["depleted"]                     = "fuera de tiempo",
    ["Rate your party-mates"]        = "Valora a tus compañeros de grupo",

    ["%s-%s is on the Blacklist. Remove from Blacklist?"]   = "%s-%s está en la lista negra. ¿Quitarlo de la lista negra?",
    ["%s-%s is in Remember Me. Remove from Remember Me?"]   = "%s-%s está en Favoritos. ¿Quitarlo de Favoritos?",

    ["Added %s-%s to Remember Me."]  = "%s-%s añadido a Favoritos.",
    ["Removed %s-%s from Remember Me."] = "%s-%s quitado de Favoritos.",

    ["invalid name/realm"]           = "nombre/reino no válido",
})
