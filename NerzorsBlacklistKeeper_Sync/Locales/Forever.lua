local NBK = _G.NBK
if not NBK then return end

local function forever(locale, strings)
    NBK:RegisterFlavorStrings("forever", locale, strings)
end

forever("enUS", {
    ["name[-realm]"] = "First and second name",
    ["Name-Realm"]   = "First and second name",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Tick the characters that should receive auto-pushes.",
})
forever("deDE", {
    ["name[-realm]"] = "Haupt- und Zweitname",
    ["Name-Realm"]   = "Haupt- und Zweitname",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Hake die Charaktere an, die neue Einträge automatisch bekommen sollen.",
})
forever("itIT", {
    ["name[-realm]"] = "Nome principale e secondo nome",
    ["Name-Realm"]   = "Nome principale e secondo nome",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Spunta i personaggi che devono ricevere automaticamente le nuove voci.",
})
forever("frFR", {
    ["name[-realm]"] = "Nom principal et second nom",
    ["Name-Realm"]   = "Nom principal et second nom",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Cochez les personnages qui doivent recevoir automatiquement les nouvelles entrées.",
})
forever("ptBR", {
    ["name[-realm]"] = "Nome principal e segundo nome",
    ["Name-Realm"]   = "Nome principal e segundo nome",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Marque os personagens que devem receber as novas entradas automaticamente.",
})
forever("esMX", {
    ["name[-realm]"] = "Nombre principal y segundo nombre",
    ["Name-Realm"]   = "Nombre principal y segundo nombre",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Marca los personajes que deben recibir automáticamente las entradas nuevas.",
})
forever("ruRU", {
    ["name[-realm]"] = "Основное и второе имя",
    ["Name-Realm"]   = "Основное и второе имя",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Отметьте персонажей, которые будут автоматически получать новые записи.",
})
