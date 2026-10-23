local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("ruRU", {
    ["Recent party-mates"]                                      = "Недавние союзники по группе",
    ["Tracks the last %d unique party-mates (party only - not raid)."]
        = "Хранит последних разных союзников по группе (до %d; только группа, без рейдов).",
    ["Recents (%d / %d)"]                                       = "Недавние группы (%d / %d)",

    ["Storage"]         = "Хранение",
    ["Account-wide"]    = "Для всей учётной записи",
    ["Per-character"]   = "Для каждого персонажа",
    ["Maximum entries"] = "Максимум записей",

    ["Remove from recents"]                  = "Удалить из недавних",
    ["Remove %s-%s from recents?"]           = "Удалить %s-%s из недавних?",
    ["Clear recents..."]                     = "Очистить недавние...",
    ["Clear all %d recents entries?"]        = "Удалить все недавние записи (%d)?",
    ["Cleared %d recents entries."]          = "Удалено недавних записей: %d.",
})
