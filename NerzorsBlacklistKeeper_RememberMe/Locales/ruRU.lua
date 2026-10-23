local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("ruRU", {

    ["Remembered"]                   = "В избранном",

    ["Add to Remember Me"]           = "Добавить в избранное",
    ["Edit Remember Me entry"]       = "Изменить запись избранного",
    ["Remove from Remember Me"]      = "Удалить из избранного",
    ["Remove %s-%s from Remember Me?"] = "Удалить %s-%s из избранного?",

    ["Rating"]                       = "Оценка",
    ["Default rating"]               = "Оценка по умолчанию",
    ["%d ★"]                         = "%d ★",

    ["Show in unit tooltips"]        = "Показывать в подсказках",
    ["Prompt after Mythic+ runs"]    = "Предлагать оценку после «Эпохального+»",
    ["Clear Remember Me..."]         = "Очистить избранное...",
    ["Clear all %d Remember Me entries?"] = "Удалить все записи избранного (%d)?",
    ["Cleared %d Remember Me entries."]   = "Удалено записей избранного: %d.",

    ["No entries yet - finish a Mythic+ run to remember your party-mates."]
        = "Записей пока нет: пройдите «Эпохальный+», чтобы запомнить союзников по группе.",

    ["Mythic+ run finished"]         = "«Эпохальный+» пройден",
    ["%s +%d - %s"]                  = "%s +%d - %s",
    ["timed"]                        = "в срок",
    ["depleted"]                     = "не в срок",
    ["Rate your party-mates"]        = "Оцените союзников по группе",

    ["%s-%s is on the Blacklist. Remove from Blacklist?"]   = "%s-%s в блэклисте. Удалить из блэклиста?",
    ["%s-%s is in Remember Me. Remove from Remember Me?"]   = "%s-%s в избранном. Удалить из избранного?",

    ["Added %s-%s to Remember Me."]  = "%s-%s добавлен в избранное.",
    ["Removed %s-%s from Remember Me."] = "%s-%s удалён из избранного.",

    ["invalid name/realm"]           = "неверное имя или сервер",
})
