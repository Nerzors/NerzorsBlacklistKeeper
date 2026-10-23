local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("ruRU", {

    ["Enable sharing (send & receive)"]      = "Включить обмен (отправка и получение)",
    ["Accept shares from"]                   = "Принимать списки от",
    ["anyone"]                               = "всех",
    ["guild"]                                = "гильдии",
    ["friends"]                              = "друзей",
    ["nobody"]                               = "никого",
    ["Auto-open import preview on receive"]  = "Сразу открывать просмотр при получении",
    ["Announce in chat when sharing"]        = "Сообщать в чат об отправке",
    ["New entries shareable by default"]     = "Новые записи - для обмена по умолчанию",
    ["Export only shareable entries"]        = "Экспортировать только записи для обмена",
    ["Debug (verbose send/receive log)"]     = "Отладка (подробный журнал отправки и получения)",
    ["Share with"]                           = "Поделиться с",
    ["name[-realm]"]                         = "имя[-сервер]",
    ["Whisper"]                              = "Шепнуть",
    ["Guild"]                                = "Гильдия",

    ["%d shareable entries exported."]       = "Экспортировано записей для обмена: %d.",
    ["%d private entries held back."]        = "Не экспортировано личных записей: %d.",
    ["Shared %d entries with %s."]           = "Записи (%d) отправлены: %s.",
    ["Skipped %d oversized entries."]        = "Пропущено слишком больших записей: %d.",
    ["%s shared %d blacklist entries."]      = "%s поделился записями блэклиста: %d.",
    ["%s sent an empty share."]              = "%s отправил пустой список.",
    ["Use /nbk share show to review."]       = "Введите /nbk share show, чтобы просмотреть.",
    ["from %s"]                              = "от %s",

    ["share via whisper"]                    = "поделиться шёпотом",
    ["broadcast to guild"]                   = "отправить гильдии",

    ["Tip: addon-whispers need the recipient online + a recent contact relationship (friend / guildmate / group / recent /w). If they see nothing, send them a normal whisper first or use Guild channel."]
        = "Совет: для шёпота между модификациями получатель должен быть в сети и недавно с вами контактировать (друг / член гильдии / группа / недавний шёпот). Если ничего не приходит, сначала отправьте ему обычный шёпот или используйте канал гильдии.",

    ["Auto-Sync"]                            = "Auto-Sync",
    ["Auto-Sync new blacklist entries"]      = "Автоматически отправлять новые записи блэклиста",
    ["Send to"]                              = "Отправлять",
    ["Friends"]                              = "Друзьям",
    ["Specific characters"]                  = "Выбранным персонажам",
    ["Tick the characters that should receive auto-pushes (Name-Realm)."]
        = "Отметьте персонажей, которые будут автоматически получать новые записи (Имя-Сервер).",
    ["Name-Realm"]                           = "Имя-Сервер",

    ["Auto-Sync blacklist push"]             = "Auto-Sync: запись блэклиста",
    ["%s wants to share an entry:"]          = "%s хочет поделиться записью:",
    ["%s auto-shared %s-%s."]                = "%s автоматически отправил %s-%s.",
    ["Reason: %s"]                           = "Причина: %s",
    ["Decline"]                              = "Отказаться",
    ["From"]                                 = "От",
    ["%s shared %d entries (%s)."]           = "%s поделился записями: %d (%s).",

    ["missing target"]                       = "не указан получатель",
    ["not in a guild"]                       = "вы не в гильдии",
    ["not in a group"]                       = "вы не в группе",
    ["sync disabled"]                        = "обмен отключён",
    ["no shareable entries (all marked private)"] = "нет записей для обмена (все личные)",
    ["list is empty"]                        = "список пуст",
    ["no pending share"]                     = "нет ожидающих списков",
})
