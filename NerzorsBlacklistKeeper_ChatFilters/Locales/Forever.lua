local NBK = _G.NBK
if not NBK then return end

local function forever(locale, strings)
    NBK:RegisterFlavorStrings("forever", locale, strings)
end

forever("enUS", {
    ["One name per line. Use Name-Realm to pin a specific realm; bare names match any realm."]
        = "One name per line, with first and second name.",
    ["Search name, realm..."] = "Search name...",
})
forever("deDE", {
    ["One name per line. Use Name-Realm to pin a specific realm; bare names match any realm."]
        = "Ein Name pro Zeile, mit Haupt- und Zweitname.",
    ["Search name, realm..."] = "Name suchen...",
})
forever("itIT", {
    ["One name per line. Use Name-Realm to pin a specific realm; bare names match any realm."]
        = "Un nome per riga, con nome principale e secondo nome.",
    ["Search name, realm..."] = "Cerca nome...",
})
forever("frFR", {
    ["One name per line. Use Name-Realm to pin a specific realm; bare names match any realm."]
        = "Un nom par ligne, avec nom principal et second nom.",
    ["Search name, realm..."] = "Rechercher un nom...",
})
forever("ptBR", {
    ["One name per line. Use Name-Realm to pin a specific realm; bare names match any realm."]
        = "Um nome por linha, com nome principal e segundo nome.",
    ["Search name, realm..."] = "Buscar nome...",
})
forever("esMX", {
    ["One name per line. Use Name-Realm to pin a specific realm; bare names match any realm."]
        = "Un nombre por línea, con nombre principal y segundo nombre.",
    ["Search name, realm..."] = "Buscar nombre...",
})
forever("ruRU", {
    ["One name per line. Use Name-Realm to pin a specific realm; bare names match any realm."]
        = "Одно имя на строку, с основным и вторым именем.",
    ["Search name, realm..."] = "Поиск: имя...",
})
