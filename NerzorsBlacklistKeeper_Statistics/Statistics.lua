local NBK = _G.NBK
if not NBK then return end

local NUL = LibStub("NerzorsUILib-1.0")

local Statistics = NBK:RegisterModule("Statistics")

local TOP_N       = 8
local MONTHS_BACK = 12
local DAY         = 86400

local function L(key, fallback)
    local s = NBK.L and NBK.L[key]
    return s or fallback or key
end

local function classColor(classFile)
    if not classFile then return nil end
    local hex = NBK.GetClassHex and NBK:GetClassHex(classFile)
    if not hex or hex == "" then return nil end
    return NUL.hex(hex)
end

local function classLabel(classFile)
    if not classFile then return L("Unknown", "Unknown") end
    local names = _G.LOCALIZED_CLASS_NAMES_MALE
    return (names and names[classFile]) or classFile
end

local function trim(s)
    if type(s) ~= "string" then return nil end
    return s:match("^%s*(.-)%s*$")
end

local function topN(counts, n, colorOf)
    local arr = {}
    for key, value in pairs(counts) do
        arr[#arr + 1] = {
            label = key,
            value = value,
            color = colorOf and colorOf(key) or nil,
        }
    end
    table.sort(arr, function(a, b)
        if a.value == b.value then return tostring(a.label) < tostring(b.label) end
        return a.value > b.value
    end)
    for i = #arr, (n or TOP_N) + 1, -1 do arr[i] = nil end
    return arr
end

local function buildMonthBuckets()
    local now  = date("*t", time())
    local keys, order = {}, {}
    for back = MONTHS_BACK - 1, 0, -1 do
        local m, y = now.month - back, now.year
        while m <= 0 do m = m + 12; y = y - 1 end
        local key = ("%04d-%02d"):format(y, m)
        keys[key] = 0
        order[#order + 1] = {
            key   = key,

            label = date("%b", time({ year = y, month = m, day = 1, hour = 12 })),
        }
    end
    return keys, order
end

local function computeEntries(stats)
    local entries = (NBK.GetEntries and NBK:GetEntries()) or {}
    local now     = time()
    local cutoff  = now - 30 * DAY

    local monthCounts, monthOrder = buildMonthBuckets()
    local reasons, zones, classes = {}, {}, {}
    local encounters = {}
    local total, added30, encTotal = 0, 0, 0

    for _, e in pairs(entries) do
        total = total + 1

        if e.addedAt then
            if e.addedAt >= cutoff then added30 = added30 + 1 end
            local d   = date("*t", e.addedAt)
            local key = ("%04d-%02d"):format(d.year, d.month)
            if monthCounts[key] then monthCounts[key] = monthCounts[key] + 1 end
        end

        local reason = trim(e.reason)
        if not reason or reason == "" then reason = L("No reason", "No reason") end
        reasons[reason] = (reasons[reason] or 0) + 1

        local zone = trim(e.zone)
        if not zone or zone == "" then zone = L("Unknown", "Unknown") end
        zones[zone] = (zones[zone] or 0) + 1

        local cls = e.class or false
        classes[cls] = (classes[cls] or 0) + 1

        local n = e.encounterCount or 0
        encTotal = encTotal + n
        if n > 0 then
            encounters[#encounters + 1] = {
                label = (e.name or "?") .. "-" .. (e.realm or ""),
                value = n,
                color = classColor(e.class),
            }
        end
    end

    local perMonth = {}
    for i, m in ipairs(monthOrder) do
        perMonth[i] = { label = m.label, value = monthCounts[m.key] or 0 }
    end

    local byClass = {}
    for cls, count in pairs(classes) do
        byClass[#byClass + 1] = {
            label = classLabel(cls or nil),
            value = count,
            color = classColor(cls or nil),
        }
    end
    table.sort(byClass, function(a, b)
        if a.value == b.value then return a.label < b.label end
        return a.value > b.value
    end)
    for i = #byClass, TOP_N + 1, -1 do byClass[i] = nil end

    table.sort(encounters, function(a, b)
        if a.value == b.value then return a.label < b.label end
        return a.value > b.value
    end)
    for i = #encounters, TOP_N + 1, -1 do encounters[i] = nil end

    stats.total       = total
    stats.added30     = added30
    stats.encounters  = encTotal
    stats.perMonth    = perMonth
    stats.topReasons  = topN(reasons, TOP_N)
    stats.topZones    = topN(zones, TOP_N)
    stats.byClass     = byClass
    stats.topEncounters = encounters
end

local function computeChat(stats)
    local chat = {}

    local cf = NBK.GetAddonDB and NBK:GetAddonDB("ChatFilters")
    if cf and type(cf.stats) == "table" then
        chat.censored    = cf.stats.censored    or 0
        chat.hidden      = cf.stats.hidden      or 0
        chat.whitelisted = cf.stats.whitelisted or 0
        chat.hasFilters  = true
    end

    local mh = NBK.GetModule and NBK:GetModule("MessageHistory")
    if mh and mh.GetPlayers then
        local channelNames = {
            SAY      = L("Say", "Say"),
            YELL     = L("Yell", "Yell"),
            EMOTE    = L("Emote", "Emote"),
            PARTY    = L("Party", "Party"),
            RAID     = L("Raid", "Raid"),
            INSTANCE = L("Instance", "Instance"),
            GUILD    = L("Guild", "Guild"),
            OFFICER  = L("Officer", "Officer"),
            WHISPER  = L("Whisper", "Whisper"),
            CHANNEL  = L("Channel", "Channel"),
        }
        local byChannel, archived, players = {}, 0, 0
        for _, p in pairs(mh:GetPlayers()) do
            local msgs = p.messages or {}
            if #msgs > 0 then players = players + 1 end
            for _, m in ipairs(msgs) do
                archived = archived + 1

                local key = (m.ch == "CHANNEL" and m.cn) or channelNames[m.ch] or m.ch or "?"
                byChannel[key] = (byChannel[key] or 0) + 1
            end
        end
        chat.archived   = archived
        chat.msgPlayers = players
        chat.byChannel  = topN(byChannel, TOP_N)
        chat.hasHistory = true
    end

    stats.chat = chat
end

function Statistics:Compute()
    local stats = {}
    computeEntries(stats)
    computeChat(stats)
    self._stats = stats
    return stats
end

function Statistics:GetStats()
    return self._stats or self:Compute()
end
