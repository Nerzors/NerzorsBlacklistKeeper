local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("ruRU", {
    ["Group Finder warnings"]                              = "Предупреждения в поиске группы",
    ["Enable Group Finder warnings"]                       = "Включить предупреждения в поиске группы",
    ["Flag blacklisted leaders in search results"]         = "Отмечать лидеров из блэклиста в результатах поиска",
    ["Warn before applying to a blacklisted leader"]       = "Предупреждать перед заявкой к лидеру из блэклиста",
    ["Warn when a blacklisted player applies to my group"] = "Предупреждать, когда игрок из блэклиста подаёт заявку в мою группу",
    ["LFG applicant |cff%s%s|r-%s is blacklisted (%s)"]    = "Кандидат |cff%s%s|r-%s в блэклисте (%s)",
})
