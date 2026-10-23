local NBK = _G.NBK
if not NBK then return end

local MessageHistory = NBK:RegisterModule("MessageHistory")

local MAX_PER_PLAYER = 500

local SETTINGS_DEFAULTS = { enabled = true, retentionDays = 30 }

local function historySettings()
    local db = NBK:GetAddonDB("ChatFilters")
    if not db then return SETTINGS_DEFAULTS end
    if type(db.history) ~= "table" then db.history = {} end
    local h = db.history
    if h.enabled       == nil then h.enabled       = SETTINGS_DEFAULTS.enabled end
    if h.retentionDays == nil then h.retentionDays = SETTINGS_DEFAULTS.retentionDays end
    return h
end

local function store()
    if type(_G.NerzorsBlacklistKeeperChatHistoryDB) ~= "table" then
        _G.NerzorsBlacklistKeeperChatHistoryDB = { version = 1, players = {} }
    end
    local db = _G.NerzorsBlacklistKeeperChatHistoryDB
    if type(db.players) ~= "table" then db.players = {} end
    return db
end

local function playerKey(name, realm)
    return ((name or "") .. "-" .. (realm or "")):lower()
end

local EVENT_CHANNEL = {
    CHAT_MSG_SAY                  = "SAY",
    CHAT_MSG_YELL                 = "YELL",
    CHAT_MSG_EMOTE                = "EMOTE",
    CHAT_MSG_TEXT_EMOTE           = "EMOTE",
    CHAT_MSG_PARTY                = "PARTY",
    CHAT_MSG_PARTY_LEADER         = "PARTY",
    CHAT_MSG_RAID                 = "RAID",
    CHAT_MSG_RAID_LEADER          = "RAID",
    CHAT_MSG_RAID_WARNING         = "RAID",
    CHAT_MSG_INSTANCE_CHAT        = "INSTANCE",
    CHAT_MSG_INSTANCE_CHAT_LEADER = "INSTANCE",
    CHAT_MSG_GUILD                = "GUILD",
    CHAT_MSG_OFFICER              = "OFFICER",
    CHAT_MSG_WHISPER              = "WHISPER",
    CHAT_MSG_CHANNEL              = "CHANNEL",
}

local function channelLabel(msg)
    local L = NBK.L
    local ch = msg.ch
    if ch == "CHANNEL" then
        return msg.cn or (L["Channel"] or "Channel")
    end
    local map = {
        SAY      = L["Say"]      or "Say",
        YELL     = L["Yell"]     or "Yell",
        EMOTE    = L["Emote"]    or "Emote",
        PARTY    = L["Party"]    or "Party",
        RAID     = L["Raid"]     or "Raid",
        INSTANCE = L["Instance"] or "Instance",
        GUILD    = L["Guild"]    or "Guild",
        OFFICER  = L["Officer"]  or "Officer",
        WHISPER  = L["Whisper"]  or "Whisper",
    }
    return map[ch] or ch or "?"
end

local function record(name, realm, chToken, channelName, text)
    if not name or not text then return end
    local db  = store()
    local key = playerKey(name, realm)
    local p   = db.players[key]
    if not p then
        local entry = NBK:GetPlayer(name, realm)
        p = {
            name     = name,
            realm    = realm,
            class    = entry and entry.class or nil,
            messages = {},
            count    = 0,
        }
        db.players[key] = p
    elseif not p.class then
        local entry = NBK:GetPlayer(name, realm)
        if entry and entry.class then p.class = entry.class end
    end

    local now = time()
    table.insert(p.messages, {
        t   = now,
        ch  = chToken,
        cn  = (chToken == "CHANNEL") and channelName or nil,
        msg = text,
    })
    p.lastAt = now
    p.count  = #p.messages

    while #p.messages > MAX_PER_PLAYER do
        table.remove(p.messages, 1)
    end
    p.count = #p.messages
end

function MessageHistory:RecordFromFilter(name, realm, event, text, channelBaseName)
    if historySettings().enabled == false then return end
    if type(text) ~= "string" then return end
    local chToken = EVENT_CHANNEL[event]
    if not chToken then return end
    if not name then return end

    record(name, realm, chToken, channelBaseName, text)

    if self._tabBuilt then self:RefreshTab() end
end

function MessageHistory:Prune()
    local days = historySettings().retentionDays or 30
    if days <= 0 then return end
    local cutoff = time() - days * 86400
    local db = store()
    for key, p in pairs(db.players) do
        local msgs = p.messages or {}

        while msgs[1] and (msgs[1].t or 0) < cutoff do
            table.remove(msgs, 1)
        end
        p.count = #msgs
        if #msgs == 0 then
            db.players[key] = nil
        end
    end
end

function MessageHistory:HasHistory(name, realm)
    local p = store().players[playerKey(name, realm)]
    return p ~= nil and #(p.messages or {}) > 0
end

function MessageHistory:GetPlayer(name, realm)
    return store().players[playerKey(name, realm)]
end

function MessageHistory:ClearPlayer(name, realm)
    store().players[playerKey(name, realm)] = nil
end

function MessageHistory:ClearAll()
    local db = store()
    db.players = {}
end

function MessageHistory:GetPlayers()
    return store().players
end

function MessageHistory:CountPlayers()
    local n = 0
    for _, p in pairs(store().players) do
        if #(p.messages or {}) > 0 then n = n + 1 end
    end
    return n
end

local function sortedPlayers(filter)
    filter = filter and filter:lower() or ""
    local out = {}
    for _, p in pairs(store().players) do
        if #(p.messages or {}) > 0 then
            local hay = ((p.name or "") .. "-" .. (p.realm or "")):lower()
            if filter == "" or hay:find(filter, 1, true) then
                out[#out + 1] = p
            end
        end
    end
    table.sort(out, function(a, b)
        local la, lb = a.lastAt or 0, b.lastAt or 0
        if la == lb then return (a.name or "") < (b.name or "") end
        return la > lb
    end)
    return out
end

local function fmtDate(ts)
    return NBK:FormatDate(ts)
end

local function fmtDateTime(ts)
    return NBK:FormatDateTime(ts)
end

local detail = {}

local function buildDetailWindow()
    if detail.frame then return detail.frame end
    local NUL = LibStub("NerzorsUILib-1.0")
    local L   = NBK.L

    local f = NUL:Window({
        name   = "NBKChatHistoryDetail",
        title  = L["Saved messages"] or "Saved messages",
        width  = 560, height = 440,
        strata = "DIALOG",
    })
    detail.frame = f
    f:SetPositionKey("ChatHistoryDetail", NBK.db)
    f:MakeResizable({ minW = 420, minH = 300, maxW = 1000, maxH = 900 })
    f:RestorePosition()

    local content = f.content

    local header = NUL:CreateLabel(content, { text = "", justifyH = "LEFT" })
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    detail.header = header

    local clearBtn = NUL:Button(content, {
        label = L["Clear messages"] or "Clear messages",
        width = 150, height = 26, style = "danger",
        onClick = function()
            if not detail.current then return end
            local p = detail.current
            NUL:Confirm({
                text = (L["Delete all saved messages from %s-%s?"]
                        or "Delete all saved messages from %s-%s?")
                        :format(p.name or "?", p.realm or ""),
                onAccept = function()
                    MessageHistory:ClearPlayer(p.name, p.realm)
                    f:Hide()
                    MessageHistory:RefreshTab()
                end,
            })
        end,
    })
    clearBtn:SetPoint("BOTTOMRIGHT", 0, 0)

    local wrap = CreateFrame("Frame", nil, content)
    wrap:SetPoint("TOPLEFT",     header,   "BOTTOMLEFT", 0, -8)
    wrap:SetPoint("BOTTOMRIGHT", clearBtn, "TOPRIGHT",   0,  8)
    detail.bg      = NUL:FillBackground(wrap, NUL:GetTheme().colors.bg.elevated)
    detail.borders = NUL:AddBorder(wrap, nil, NUL:GetTheme().metrics.borderThickness)

    local scroll = CreateFrame("ScrollFrame", nil, wrap, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 2, -2)
    scroll:SetPoint("BOTTOMRIGHT", -22, 2)
    local stack = CreateFrame("Frame", nil, scroll)
    stack:SetSize(1, 1)
    scroll:SetScrollChild(stack)
    NUL:_AttachThemedScrollBar(scroll, wrap)

    detail.scroll = scroll
    detail.stack  = stack
    detail.rows   = {}

    scroll:HookScript("OnSizeChanged", function(_, w)
        if w and w > 1 then stack:SetWidth(w) end

        if detail._reflowQueued then return end
        detail._reflowQueued = true
        C_Timer.After(0.08, function()
            detail._reflowQueued = false
            if detail.frame and detail.frame:IsShown() then MessageHistory:_LayoutDetail() end
        end)
    end)

    return f
end

local TIME_W, CHAN_W, GUTTER, BLOCK_GAP = 78, 72, 6, 4

function MessageHistory:_LayoutDetail()
    local NUL   = LibStub("NerzorsUILib-1.0")
    local stack = detail.stack
    if not stack then return end

    local theme = NUL:GetTheme()
    local width = detail.scroll and detail.scroll:GetWidth() or 0
    if width < 32 then width = 460 end
    stack:SetWidth(width)

    local bodyX = 8 + TIME_W + GUTTER + CHAN_W + GUTTER
    local bodyW = math.max(120, width - bodyX - 8)
    local y     = 4

    for i, msg in ipairs(detail.msgs or {}) do
        local block = detail.rows[i]
        if not block then
            block = CreateFrame("Frame", nil, stack)
            block.stripe = block:CreateTexture(nil, "BACKGROUND")
            block.stripe:SetAllPoints()
            block.time = NUL:CreateLabel(block, { size = "sm", justifyH = "LEFT", wrap = false })
            block.chan = NUL:CreateLabel(block, { size = "sm", justifyH = "LEFT", wrap = false })
            block.body = NUL:CreateLabel(block, { justifyH = "LEFT" })
            block.body:SetWordWrap(true)
            detail.rows[i] = block
        end

        block:ClearAllPoints()
        block:SetPoint("TOPLEFT",  stack, "TOPLEFT",  0, -y)
        block:SetPoint("TOPRIGHT", stack, "TOPRIGHT", 0, -y)

        NUL.SetFontColor(block.time, theme.colors.text.muted)
        NUL.SetFontColor(block.chan, theme.colors.accent.primary)
        NUL.SetFontColor(block.body, theme.colors.text.primary)
        block.time:SetText(fmtDateTime(msg.t))
        block.chan:SetText(channelLabel(msg))
        block.body:SetText(msg.msg or "")

        block.time:ClearAllPoints()
        block.time:SetPoint("TOPLEFT", block, "TOPLEFT", 8, -3)
        block.time:SetWidth(TIME_W)
        block.chan:ClearAllPoints()
        block.chan:SetPoint("TOPLEFT", block, "TOPLEFT", 8 + TIME_W + GUTTER, -3)
        block.chan:SetWidth(CHAN_W)
        block.body:ClearAllPoints()
        block.body:SetPoint("TOPLEFT", block, "TOPLEFT", bodyX, -3)

        block.body:SetWidth(bodyW)

        local h = math.max(22, math.ceil(block.body:GetStringHeight() or 16) + 8)
        block:SetHeight(h)

        if i % 2 == 0 then
            NUL.SetTextureColor(block.stripe, NUL.WithAlpha(theme.colors.bg.panel, 0.5))
        else
            NUL.SetTextureColor(block.stripe, NUL.WithAlpha(theme.colors.bg.panel, 0))
        end

        block:Show()
        y = y + h + BLOCK_GAP
    end

    for i = #(detail.msgs or {}) + 1, #detail.rows do
        detail.rows[i]:Hide()
    end

    stack:SetHeight(math.max(1, y))
end

function MessageHistory:ShowDetail(name, realm)
    local p = self:GetPlayer(name, realm)
    if not p then return end
    local NUL = LibStub("NerzorsUILib-1.0")
    local L   = NBK.L
    local f   = buildDetailWindow()
    detail.current = p

    local hex = (p.class and NBK:GetClassHex(p.class)) or "ffffff"
    f:SetTitle((L["Saved messages"] or "Saved messages"))
    detail.header:SetText(("|cff%s%s|r-%s   |cff888c99(%d)|r"):format(
        hex, p.name or "?", p.realm or "", #(p.messages or {})))

    local msgs = {}
    for _, m in ipairs(p.messages or {}) do msgs[#msgs + 1] = m end
    table.sort(msgs, function(a, b) return (a.t or 0) < (b.t or 0) end)

    detail.msgs = msgs
    f:Show()
    self:_LayoutDetail()

    C_Timer.After(0, function()
        if detail.frame and detail.frame:IsShown() then self:_LayoutDetail() end
    end)
end

local ROW_HEIGHT = 26
local OPTIONS_W  = 60

local tabUI = {}

local function buildOptionsCell(row)
    local NUL = LibStub("NerzorsUILib-1.0")
    local f = CreateFrame("Frame", nil, row)
    f:SetSize(OPTIONS_W, 26)

    local viewBtn = NUL:IconButton(f, {
        icon    = "notes.png",
        size    = 24,
        plain   = true,
        tooltip = NBK.L["View messages"] or "View messages",
    })
    viewBtn:SetPoint("LEFT", f, "LEFT", 0, 0)
    f.view = viewBtn

    local rmBtn = NUL:IconButton(f, {
        icon    = "app-close.png",
        size    = 24,
        style   = "danger",
        plain   = true,
        tooltip = NBK.L["Delete history"] or "Delete history",
    })
    rmBtn:SetPoint("LEFT", f, "LEFT", 28, 0)
    f.remove = rmBtn

    return f
end

local function makeRowBuilder()
    local NUL = LibStub("NerzorsUILib-1.0")
    local UI  = NBK.UI
    return function(row)
        local theme = NUL:GetTheme()
        local cells = {}

        cells.class = UI:CreateClassIcon(row, 18)
        cells.name  = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
        cells.count = NUL:CreateLabel(row, { text = "", color = theme.colors.accent.primary, justifyH = "LEFT" })
        cells.seen  = NUL:CreateLabel(row, { text = "", color = theme.colors.text.muted, justifyH = "LEFT", wrap = false })
        cells.opts  = buildOptionsCell(row)

        local function layout(totalWidth)
            local x = 8
            cells.class:ClearAllPoints(); cells.class:SetPoint("LEFT", row, "LEFT", x, 0); x = x + 22 + 4
            cells.name:ClearAllPoints();  cells.name:SetWidth(220); cells.name:SetPoint("LEFT", row, "LEFT", x, 0); x = x + 220 + 4
            cells.count:ClearAllPoints(); cells.count:SetWidth(90);  cells.count:SetPoint("LEFT", row, "LEFT", x, 0); x = x + 90 + 4

            local fixedRight = OPTIONS_W + 8
            local seenW = math.max(80, totalWidth - x - fixedRight - 4)
            cells.seen:ClearAllPoints(); cells.seen:SetWidth(seenW); cells.seen:SetPoint("LEFT", row, "LEFT", x, 0); x = x + seenW + 4

            cells.opts:ClearAllPoints(); cells.opts:SetPoint("LEFT", row, "LEFT", x, 0)
        end
        row._layout = layout
        row._cells  = cells

        return function(r, entry)
            r._layout(r:GetWidth())

            cells.class:SetClass(entry.class or "WARRIOR", "midnight")

            local hex = (entry.class and NBK:GetClassHex(entry.class)) or "ffffff"
            cells.name:SetText(("|cff%s%s|r-%s"):format(hex, entry.name or "?", entry.realm or ""))
            cells.count:SetText((NBK.L["%d msgs"] or "%d msgs"):format(#(entry.messages or {})))
            cells.seen:SetText(fmtDate(entry.lastAt))

            local function open() MessageHistory:ShowDetail(entry.name, entry.realm) end
            r:SetScript("OnClick", open)
            cells.opts.view:SetScript("OnClick", open)
            cells.opts.remove:SetScript("OnClick", function()
                LibStub("NerzorsUILib-1.0"):Confirm({
                    text = (NBK.L["Delete all saved messages from %s-%s?"]
                            or "Delete all saved messages from %s-%s?")
                            :format(entry.name or "?", entry.realm or ""),
                    onAccept = function()
                        MessageHistory:ClearPlayer(entry.name, entry.realm)
                        MessageHistory:RefreshTab()
                    end,
                })
            end)
        end
    end
end

local function buildHeader(parent, theme, columns)
    local NUL = LibStub("NerzorsUILib-1.0")
    local header = CreateFrame("Frame", nil, parent)
    header:SetHeight(20)
    NUL:FillBackground(header, theme.colors.bg.panel)

    local cells = {}
    for i, col in ipairs(columns) do
        local cell = CreateFrame("Frame", nil, header)
        cell:SetHeight(20)
        local fs = NUL:CreateLabel(cell, {
            text = col.label, size = "sm",
            color = theme.colors.text.muted, justifyH = "LEFT",
        })
        fs:SetPoint("LEFT", 0, 0); fs:SetPoint("RIGHT", 0, 0)
        cells[i] = cell
    end

    header._layout = function()
        local w = header:GetWidth()
        local fixedSum = 0
        for _, col in ipairs(columns) do
            if not col.flex then fixedSum = fixedSum + col.width end
        end
        local flexW = math.max(80, w - fixedSum - (#columns * 4) - 8)
        local x = 8
        for i, col in ipairs(columns) do
            local cell = cells[i]
            local cw = col.flex and flexW or col.width
            cell:ClearAllPoints()
            cell:SetPoint("LEFT", header, "LEFT", x, 0)
            cell:SetWidth(cw)
            x = x + cw + 4
        end
    end
    header:SetScript("OnSizeChanged", header._layout)
    return header
end

function MessageHistory:_BuildTab(parent)
    if tabUI.root then return tabUI.root end
    local NUL   = LibStub("NerzorsUILib-1.0")
    local L     = NBK.L
    local theme = NUL:GetTheme()

    local root = CreateFrame("Frame", nil, parent)
    root:SetAllPoints()
    tabUI.root = root

    local searchBox = NUL:EditBox(root, {
        width = 260, height = 26,
        placeholder = L["Search name, realm..."] or "Search name, realm...",
        onTextChanged = function() MessageHistory:RefreshTab() end,
    })
    searchBox:SetPoint("TOPLEFT")
    tabUI.searchEB = searchBox

    local countLabel = NUL:CreateLabel(root, { text = "", color = theme.colors.text.muted })
    countLabel:SetPoint("RIGHT")
    tabUI.countLabel = countLabel

    local hint = NUL:CreateLabel(root, {
        text  = L["Saved chat from muted blacklisted players."]
                or "Saved chat from muted blacklisted players.",
        size  = "sm",
        color = theme.colors.text.muted,
    })
    hint:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 2, -6)
    tabUI.hint = hint

    local columns = {
        { key = "class", label = "",                                 width = 22 },
        { key = "name",  label = L["Name"],                          width = 220 },
        { key = "count", label = L["Messages"] or "Messages",        width = 90 },
        { key = "seen",  label = L["Last seen"] or "Last seen",      width = 0, flex = true },
        { key = "opts",  label = L["Options"]   or "Options",        width = OPTIONS_W },
    }

    local header = buildHeader(root, theme, columns)
    header:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", -2, -8)
    header:SetPoint("RIGHT")
    tabUI.header = header

    local list = NUL:ScrollList(root, {
        rowHeight  = ROW_HEIGHT,
        rowBuilder = makeRowBuilder(),
    })
    list.container:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    list.container:SetPoint("BOTTOMRIGHT")
    tabUI.list = list

    if header._layout then header._layout() end
    self._tabBuilt = true
    self:RefreshTab()

    return root
end

function MessageHistory:RefreshTab()
    if not tabUI.list then return end
    local L = NBK.L
    local filter  = tabUI.searchEB and tabUI.searchEB:GetText() or ""
    local players = sortedPlayers(filter)
    tabUI.list:SetData(players)

    local total = self:CountPlayers()
    local shown = #players
    if shown == total then
        tabUI.countLabel:SetText((L["History (%d)"] or "History (%d)"):format(total))
    else
        tabUI.countLabel:SetText((L["%d / %d"] or "%d / %d"):format(shown, total))
    end
end

function MessageHistory:BuildConfigSection(panel, y)
    local NUL    = LibStub("NerzorsUILib-1.0")
    local L      = NBK.L
    local Config = NBK:GetModule("Config")
    local theme  = NUL:GetTheme()

    local _, ny = Config:AddSectionLabel(panel, y, L["Message history"] or "Message history")
    y = ny

    local cbEnabled = NUL:Checkbox(panel, {
        label   = L["Save muted players' messages"] or "Save muted players' messages",
        checked = historySettings().enabled ~= false,
        onChange = function(v) historySettings().enabled = v and true or false end,
    })
    cbEnabled:SetPoint("TOPLEFT", 0, y); y = y - 26

    local retLabel = NUL:CreateLabel(panel, {
        text = L["Keep messages for"] or "Keep messages for",
        color = theme.colors.text.muted,
    })
    retLabel:SetPoint("TOPLEFT", 0, y); y = y - 18

    local retDD = NUL:Dropdown(panel, {
        width = 220, height = 24,
        options = {
            { key = 7,   label = (L["%d days"] or "%d days"):format(7) },
            { key = 14,  label = (L["%d days"] or "%d days"):format(14) },
            { key = 30,  label = (L["%d days"] or "%d days"):format(30) },
            { key = 90,  label = (L["%d days"] or "%d days"):format(90) },
            { key = 0,   label = L["Forever"] or "Forever" },
        },
        value = historySettings().retentionDays or 30,
        onSelect = function(v)
            historySettings().retentionDays = tonumber(v) or 30
            MessageHistory:Prune()
            MessageHistory:RefreshTab()
        end,
    })
    retDD:SetPoint("TOPLEFT", 0, y); y = y - 36

    local openBtn = NUL:Button(panel, {
        label = L["Open history"] or "Open history",
        width = 150, height = 26,
        onClick = function()
            local lw = NBK:GetModule("ListWindow")
            if lw then
                lw:Show()
                lw:SwitchTab("history")
            end
        end,
    })
    openBtn:SetPoint("TOPLEFT", 0, y)

    local clearBtn = NUL:Button(panel, {
        label = L["Clear all history"] or "Clear all history",
        width = 180, height = 26, style = "danger",
        onClick = function()
            local n = MessageHistory:CountPlayers()
            NUL:Confirm({
                text = (L["Clear saved messages for all %d players?"]
                        or "Clear saved messages for all %d players?"):format(n),
                onAccept = function()
                    MessageHistory:ClearAll()
                    MessageHistory:RefreshTab()
                    NBK:Print(L["Message history cleared."] or "Message history cleared.")
                end,
            })
        end,
    })
    clearBtn:SetPoint("TOPLEFT", openBtn, "TOPRIGHT", 8, 0)
    y = y - 32

    return y
end

local function buildHistoryContextActions(rootDescription, name, realm)
    if not MessageHistory:HasHistory(name, realm) then return end
    local L = NBK.L
    rootDescription:CreateButton(L["View saved messages"] or "View saved messages", function()
        local lw = NBK:GetModule("ListWindow")
        if lw then lw:Build() end
        MessageHistory:ShowDetail(name, realm)
    end)
end

function MessageHistory:OnEnable()

    self:Prune()

    local lw = NBK:GetModule("ListWindow")
    if lw and lw.RegisterTab then
        lw:RegisterTab({
            key      = "history",
            labelKey = "Message history",
            order    = 25,
            build    = function(parent) return MessageHistory:_BuildTab(parent) end,
            refresh  = function() MessageHistory:RefreshTab() end,
            onShow   = function() MessageHistory:RefreshTab() end,
        })
    end

    local cm = NBK:GetModule("ContextMenu")
    if cm and cm.RegisterAction then
        cm:RegisterAction({
            key     = "chathistory_view",
            order   = 40,
            builder = buildHistoryContextActions,
        })
    end
end
