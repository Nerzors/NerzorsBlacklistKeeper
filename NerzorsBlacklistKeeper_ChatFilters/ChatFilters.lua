local NBK = _G.NBK
if not NBK then return end

NBK:RegisterAddonDB({
    addonName = "NerzorsBlacklistKeeper_ChatFilters",
    key       = "ChatFilters",
    svName    = "NerzorsBlacklistKeeperChatFiltersDB",
    version   = 1,
    defaults  = {
        enabled       = true,
        mode          = "censor",
        wholeWord     = false,
        caseSensitive = false,
        channels = {
            SAY              = true,
            YELL             = true,
            EMOTE            = false,
            PARTY            = true,
            PARTY_LEADER     = true,
            RAID             = true,
            RAID_LEADER      = true,
            RAID_WARNING     = true,
            INSTANCE         = true,
            INSTANCE_LEADER  = true,
            GUILD            = true,
            OFFICER          = false,
            WHISPER          = true,
            CHANNEL          = true,
        },
        words     = {},
        whitelist = {},
        stats = {
            censored    = 0,
            hidden      = 0,
            whitelisted = 0,
            lastReset   = nil,
        },
    },
})

local ChatFilters = NBK:RegisterModule("ChatFilters")

local EVENT_TO_CHANNEL = {
    CHAT_MSG_SAY                     = "SAY",
    CHAT_MSG_YELL                    = "YELL",
    CHAT_MSG_EMOTE                   = "EMOTE",
    CHAT_MSG_TEXT_EMOTE              = "EMOTE",
    CHAT_MSG_PARTY                   = "PARTY",
    CHAT_MSG_PARTY_LEADER            = "PARTY_LEADER",
    CHAT_MSG_RAID                    = "RAID",
    CHAT_MSG_RAID_LEADER             = "RAID_LEADER",
    CHAT_MSG_RAID_WARNING            = "RAID_WARNING",
    CHAT_MSG_INSTANCE_CHAT           = "INSTANCE",
    CHAT_MSG_INSTANCE_CHAT_LEADER    = "INSTANCE_LEADER",
    CHAT_MSG_GUILD                   = "GUILD",
    CHAT_MSG_OFFICER                 = "OFFICER",
    CHAT_MSG_WHISPER                 = "WHISPER",
    CHAT_MSG_CHANNEL                 = "CHANNEL",
}

local function escapePattern(s)
    return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

local function buildPattern(word, wholeWord, caseSensitive)
    local w = escapePattern(caseSensitive and word or word:lower())
    if wholeWord then
        return "%f[%w_]" .. w .. "%f[^%w_]"
    end
    return w
end

local compiled = nil
local whitelistFull  = {}
local whitelistShort = {}

local function rebuildCache()
    local db = NBK:GetAddonDB("ChatFilters") or {}
    local list = {}
    if type(db.words) == "table" then
        for _, w in ipairs(db.words) do
            if type(w) == "string" and w ~= "" then
                table.insert(list, {
                    raw     = w,
                    pattern = buildPattern(w, db.wholeWord, db.caseSensitive),
                    len     = #w,
                })
            end
        end
    end
    table.sort(list, function(a, b) return a.len > b.len end)
    compiled = list

    wipe(whitelistFull)
    wipe(whitelistShort)
    if type(db.whitelist) == "table" then
        for _, raw in ipairs(db.whitelist) do
            if type(raw) == "string" then
                local trimmed = raw:match("^%s*(.-)%s*$")
                if trimmed and trimmed ~= "" then
                    local lower = trimmed:lower()
                    if lower:find("-", 1, true) then
                        whitelistFull[lower] = true
                    else
                        whitelistShort[lower] = true
                    end
                end
            end
        end
    end
end

local function isWhitelisted(sender)
    if not sender or sender == "" then return false end
    local s = sender:lower()
    if whitelistFull[s] then return true end
    local short = s:match("^([^-]+)") or s
    return whitelistShort[short] == true
end

local function messageHits(msg, caseSensitive)
    if not compiled or #compiled == 0 then return false end
    local haystack = caseSensitive and msg or msg:lower()
    for _, w in ipairs(compiled) do
        if haystack:find(w.pattern) then return true end
    end
    return false
end

local function censorMessage(msg, caseSensitive)
    if not compiled or #compiled == 0 then return msg, false end
    local haystack = caseSensitive and msg or msg:lower()
    local hit = false
    for _, w in ipairs(compiled) do
        local start = 1
        while true do
            local s, e = haystack:find(w.pattern, start)
            if not s then break end
            local stars = string.rep("*", e - s + 1)
            msg      = msg:sub(1, s - 1)      .. stars .. msg:sub(e + 1)
            haystack = haystack:sub(1, s - 1) .. stars .. haystack:sub(e + 1)
            start = e + 1
            hit = true
        end
    end
    return msg, hit
end

local function bumpStat(db, key)
    db.stats = db.stats or { censored = 0, hidden = 0, whitelisted = 0 }
    db.stats[key] = (db.stats[key] or 0) + 1
end

local function filterFn(_, event, msg, sender, ...)
    local db = NBK:GetAddonDB("ChatFilters")
    if not db or db.enabled == false then return false end
    if type(msg) ~= "string" or msg == "" then return false end

    local chanKey = EVENT_TO_CHANNEL[event]
    if not chanKey or not db.channels or db.channels[chanKey] == false then
        return false
    end

    if isWhitelisted(sender) then
        if messageHits(msg, db.caseSensitive) then
            bumpStat(db, "whitelisted")
        end
        return false
    end

    if db.mode == "hide" then
        if messageHits(msg, db.caseSensitive) then
            bumpStat(db, "hidden")
            return true
        end
        return false
    end

    local new, hit = censorMessage(msg, db.caseSensitive)
    if hit then
        bumpStat(db, "censored")
        return false, new, sender, ...
    end
    return false
end

local _hooked = false
local function hookFilters()
    if _hooked then return end
    for ev in pairs(EVENT_TO_CHANNEL) do
        ChatFrame_AddMessageEventFilter(ev, filterFn)
    end
    _hooked = true
end

function ChatFilters:Refresh()
    rebuildCache()
end

local function tr(L, key, fallback)
    return (L and L[key]) or fallback or key
end

local function buildChatFiltersTab(parent)
    local Config = NBK:GetModule("Config")
    local NUL    = LibStub("NerzorsUILib-1.0")
    local L      = NBK.L
    local theme  = NUL:GetTheme()

    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    local function db() return NBK:GetAddonDB("ChatFilters") or {} end
    local function saveField(key, v)
        local d = NBK:GetAddonDB("ChatFilters")
        if d then d[key] = v end
        rebuildCache()
    end

    local y = 0
    local _, ny = Config:AddSectionLabel(panel, y, "Chat filters"); y = ny

    local cbEnabled = NUL:Checkbox(panel, {
        label   = L["Enable chat word filter"],
        checked = db().enabled ~= false,
        onChange = function(v) saveField("enabled", v) end,
    })
    cbEnabled:SetPoint("TOPLEFT", 0, y); y = y - 26

    local modeLbl = NUL:CreateLabel(panel, {
        text  = L["Filter mode"],
        color = theme.colors.text.muted,
    })
    modeLbl:SetPoint("TOPLEFT", 0, y); y = y - 18

    local modeDD = NUL:Dropdown(panel, {
        width   = 220,
        height  = 24,
        options = {
            { key = "censor", label = L["Censor (replace with ***)"] },
            { key = "hide",   label = L["Hide (drop message)"] },
        },
        value    = db().mode or "censor",
        onSelect = function(v) saveField("mode", v) end,
    })
    modeDD:SetPoint("TOPLEFT", 0, y); y = y - 32

    local cbWhole = NUL:Checkbox(panel, {
        label    = L["Match whole words only"],
        checked  = db().wholeWord and true or false,
        onChange = function(v) saveField("wholeWord", v) end,
    })
    cbWhole:SetPoint("TOPLEFT", 0, y); y = y - 26

    local cbCase = NUL:Checkbox(panel, {
        label    = L["Case sensitive"],
        checked  = db().caseSensitive and true or false,
        onChange = function(v) saveField("caseSensitive", v) end,
    })
    cbCase:SetPoint("TOPLEFT", 0, y); y = y - 30

    local _, ny2 = Config:AddSectionLabel(panel, y, "Channels"); y = ny2

    local CHANNELS = {
        { key = "SAY",             labelKey = "Say" },
        { key = "YELL",            labelKey = "Yell" },
        { key = "EMOTE",           labelKey = "Emote" },
        { key = "PARTY",           labelKey = "Party" },
        { key = "PARTY_LEADER",    labelKey = "Party leader" },
        { key = "RAID",            labelKey = "Raid" },
        { key = "RAID_LEADER",     labelKey = "Raid leader" },
        { key = "RAID_WARNING",    labelKey = "Raid warning" },
        { key = "INSTANCE",        labelKey = "Instance" },
        { key = "INSTANCE_LEADER", labelKey = "Instance leader" },
        { key = "GUILD",           labelKey = "Guild" },
        { key = "OFFICER",         labelKey = "Officer" },
        { key = "WHISPER",         labelKey = "Whisper" },
        { key = "CHANNEL",         labelKey = "Public channels" },
    }

    local ROW_H = 22
    local gridHeight = math.ceil(#CHANNELS / 2) * ROW_H
    local gridFrame = CreateFrame("Frame", nil, panel)
    gridFrame:SetPoint("TOPLEFT",  0, y)
    gridFrame:SetPoint("TOPRIGHT", 0, y)
    gridFrame:SetHeight(gridHeight)
    local grid = NUL:Grid(gridFrame, { cols = 2, rowGap = 0, colGap = 0 })

    for _, c in ipairs(CHANNELS) do
        local ch = db().channels
        local cb = NUL:Checkbox(gridFrame, {
            label   = L[c.labelKey] or c.labelKey,
            checked = (not ch or ch[c.key] ~= false),
            onChange = function(v)
                local d = NBK:GetAddonDB("ChatFilters")
                if d then
                    d.channels = d.channels or {}
                    d.channels[c.key] = v and true or false
                end
            end,
        })
        grid:Add(cb)
    end
    grid:Layout()
    y = y - gridHeight - 8

    local function managedSection(sectionKey, hintKey, hintFallback, dbField, addPlaceholder, areaHeight)
        local _, nextY = Config:AddSectionLabel(panel, y, sectionKey); y = nextY

        local hint = NUL:CreateLabel(panel, {
            text     = tr(L, hintKey, hintFallback),
            size     = "sm",
            color    = theme.colors.text.muted,
            justifyH = "LEFT",
        })
        hint:SetPoint("TOPLEFT",  0, y)
        hint:SetPoint("TOPRIGHT", 0, y)
        y = y - 20

        local listArea = CreateFrame("Frame", nil, panel)
        listArea:SetPoint("TOPLEFT",  0, y)
        listArea:SetPoint("TOPRIGHT", 0, y)
        listArea:SetHeight(areaHeight)

        Config:BuildManagedList(listArea, {
            addPlaceholder = addPlaceholder,
            get = function()
                local d = NBK:GetAddonDB("ChatFilters")
                if not d then return {} end
                if type(d[dbField]) ~= "table" then d[dbField] = {} end
                return d[dbField]
            end,
            onChange = function() rebuildCache() end,
        })

        y = y - areaHeight - 10
    end

    managedSection(
        "Blocked words",
        "Messages containing any of these words/phrases get filtered.",
        "Messages containing any of these words/phrases get filtered.",
        "words",
        tr(L, "Word or phrase...", "Word or phrase..."),
        170)

    managedSection(
        tr(L, "Whitelist (sender exclusions)", "Whitelist (sender exclusions)"),
        "Senders here bypass all filters. Name-Realm pins a realm; a bare name matches any realm.",
        "Senders here bypass all filters. Name-Realm pins a realm; a bare name matches any realm.",
        "whitelist",
        tr(L, "name[-realm]", "name[-realm]"),
        150)

    local _, ny5 = Config:AddSectionLabel(panel, y, tr(L, "Statistics", "Statistics")); y = ny5

    local statCensored    = NUL:CreateLabel(panel, { text = "" })
    statCensored:SetPoint("TOPLEFT", 0, y); y = y - 18

    local statHidden      = NUL:CreateLabel(panel, { text = "" })
    statHidden:SetPoint("TOPLEFT", 0, y); y = y - 18

    local statWhitelisted = NUL:CreateLabel(panel, { text = "" })
    statWhitelisted:SetPoint("TOPLEFT", 0, y); y = y - 22

    local function refreshStats()
        local s = db().stats or {}
        statCensored:SetText(   tr(L, "Censored: %d",    "Censored: %d"   ):format(s.censored    or 0))
        statHidden:SetText(     tr(L, "Hidden: %d",      "Hidden: %d"     ):format(s.hidden      or 0))
        statWhitelisted:SetText(tr(L, "Whitelisted: %d", "Whitelisted: %d"):format(s.whitelisted or 0))
    end
    refreshStats()
    panel:HookScript("OnShow", refreshStats)

    local resetBtn = NUL:Button(panel, {
        label = tr(L, "Reset statistics", "Reset statistics"),
        height = 24,
        onClick = function()
            local d = NBK:GetAddonDB("ChatFilters")
            if d then
                d.stats = { censored = 0, hidden = 0, whitelisted = 0, lastReset = time() }
            end
            refreshStats()
        end,
    })
    resetBtn:SetPoint("TOPLEFT", 0, y)
    y = y - 30

    local mh = NBK:GetModule("MessageHistory")
    if mh and mh.BuildConfigSection then
        local _, ny = Config:AddDivider(panel, y); y = ny
        y = mh:BuildConfigSection(panel, y)
    end

    panel.lastY = y
    return panel
end

function ChatFilters:OnEnable()
    rebuildCache()
    hookFilters()

    local Config = NBK:GetModule("Config")
    if Config and Config.RegisterTab then
        Config:RegisterTab({
            key = "ChatFilters", labelKey = "Chat filters", build = buildChatFiltersTab,
            order = 22, icon = "tab-chatfilters.png", category = "modules",
        })
    end
end
