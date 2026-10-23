local NBK = _G.NBK
if not NBK then return end

NBK:RegisterAddonDB({
    addonName = "NerzorsBlacklistKeeper_Recents",
    key       = "Recents",
    svName    = "NerzorsBlacklistKeeperRecentsDB",
    version   = 1,
    defaults  = {
        settings = {
            scope      = "account",
            maxEntries = 15,
        },

        entries = {},
    },
})

local Recents = NBK:RegisterModule("Recents")

local function L() return NBK.L end

local function formatDate(ts)
    return NBK:FormatDate(ts)
end

local function settings()
    local db = NBK:GetAddonDB("Recents")
    return (db and db.settings) or { scope = "account", maxEntries = 15 }
end

local function charDB()
    if type(_G.NerzorsBlacklistKeeperRecentsCharDB) ~= "table" then
        _G.NerzorsBlacklistKeeperRecentsCharDB = {}
    end
    if type(_G.NerzorsBlacklistKeeperRecentsCharDB.entries) ~= "table" then
        _G.NerzorsBlacklistKeeperRecentsCharDB.entries = {}
    end
    return _G.NerzorsBlacklistKeeperRecentsCharDB
end

local function accountDB()
    return NBK:GetAddonDB("Recents")
end

function Recents:GetEntries()
    local s = settings()
    if s.scope == "char" then
        return charDB().entries
    end
    local db = accountDB()
    if not db then return {} end
    if type(db.entries) ~= "table" then db.entries = {} end
    return db.entries
end

function Recents:GetMaxEntries()
    return settings().maxEntries or 15
end

function Recents:CountEntries()
    return #self:GetEntries()
end

local function findIndex(list, name, realm)
    if not name or name == "" then return nil end
    local key = (name .. "-" .. (realm or "")):lower()
    for i, e in ipairs(list) do
        if ((e.name or "") .. "-" .. (e.realm or "")):lower() == key then
            return i, e
        end
    end
    return nil
end

Recents._seenInParty = {}

local function partyMemberKey(name, realm)
    return ((name or "") .. "-" .. (realm or "")):lower()
end

function Recents:RecordMember(name, realm, class, zone)
    if not name or name == "" then return nil end
    local list = self:GetEntries()
    local now  = time()
    local idx, entry = findIndex(list, name, realm)
    if entry then
        entry.count    = (entry.count or 1) + 1
        entry.lastSeen = now
        if class    then entry.class = class end
        if zone     then entry.zone  = zone  end
        return entry
    end

    entry = {
        name      = name,
        realm     = realm or GetNormalizedRealmName() or "",
        class     = class,
        classColor = class and NBK:GetClassHex(class) or nil,
        count     = 1,
        firstSeen = now,
        lastSeen  = now,
        zone      = zone,
    }
    table.insert(list, entry)

    local cap = self:GetMaxEntries()
    while #list > cap do
        local oldestIdx, oldestTs = 1, list[1].lastSeen or 0
        for i = 2, #list do
            local ts = list[i].lastSeen or 0
            if ts < oldestTs then
                oldestIdx, oldestTs = i, ts
            end
        end
        table.remove(list, oldestIdx)
    end

    return entry
end

function Recents:RemoveEntry(name, realm)
    local list = self:GetEntries()
    local idx = findIndex(list, name, realm)
    if not idx then return false end
    table.remove(list, idx)
    return true
end

function Recents:Clear()
    local list = self:GetEntries()
    local n = #list
    for i = n, 1, -1 do list[i] = nil end
    return n
end

function Recents:HasEntry(name, realm)
    local list = self:GetEntries()
    return findIndex(list, name, realm) ~= nil
end

function Recents:ScanParty()

    if IsInRaid() then return end
    if not IsInGroup(LE_PARTY_CATEGORY_HOME) then

        wipe(self._seenInParty)
        return
    end

    local zone = GetRealZoneText() or GetZoneText() or ""
    local myName = UnitName("player")

    local newSeen = {}

    for i = 1, GetNumGroupMembers() do
        local unit = "party" .. i
        if UnitExists(unit) and UnitIsPlayer(unit) then
            local name, realm = UnitName(unit)
            if name and name ~= "" and name ~= myName then
                if not realm or realm == "" then
                    realm = GetNormalizedRealmName()
                end
                local key = partyMemberKey(name, realm)
                newSeen[key] = true
                if not self._seenInParty[key] then
                    local _, classFile = UnitClass(unit)
                    self:RecordMember(name, realm, classFile, zone)
                    self._seenInParty[key] = true
                end
            end
        end
    end

    for key in pairs(self._seenInParty) do
        if not newSeen[key] then
            self._seenInParty[key] = nil
        end
    end
end

local ROW_HEIGHT  = 26
local OPTIONS_W   = 70

local tabUI = {}

local function sortedEntries(self_ref, filter)
    local list = self_ref:GetEntries()
    filter = filter and filter:lower() or ""
    local out = {}
    for _, e in ipairs(list) do
        if filter == ""
           or (e.name or ""):lower():find(filter, 1, true)
           or (e.realm or ""):lower():find(filter, 1, true)
           or (e.zone or ""):lower():find(filter, 1, true) then
            table.insert(out, e)
        end
    end

    table.sort(out, function(a, b)
        local la = a.lastSeen or 0
        local lb = b.lastSeen or 0
        if la == lb then return (a.name or "") < (b.name or "") end
        return la > lb
    end)
    return out
end

local function buildOptionsCell(row, theme, self_ref)
    local NUL = LibStub("NerzorsUILib-1.0")
    local f = CreateFrame("Frame", nil, row)
    f:SetSize(OPTIONS_W, 26)

    local addBtn = NUL:IconButton(f, {
        icon    = "block.png",
        size    = 24,
        plain   = true,
        tooltip = NBK.L["Add to blacklist"] or "Add to blacklist",
    })
    addBtn:SetPoint("LEFT", f, "LEFT", 0, 0)
    f.add = addBtn

    local rmBtn = NUL:IconButton(f, {
        icon    = "app-close.png",
        size    = 24,
        style   = "danger",
        plain   = true,
        tooltip = NBK.L["Remove from recents"] or "Remove from recents",
    })
    rmBtn:SetPoint("LEFT", f, "LEFT", 28, 0)
    f.remove = rmBtn

    return f
end

local function makeRowBuilder(self_ref)
    local NUL = LibStub("NerzorsUILib-1.0")
    local UI  = NBK.UI
    return function(row)
        local theme = NUL:GetTheme()
        local cells = {}

        cells.name  = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
        cells.class = UI:CreateClassIcon(row, 18)
        cells.count = NUL:CreateLabel(row, { text = "", color = theme.colors.accent.primary, justifyH = "LEFT" })
        cells.seen  = NUL:CreateLabel(row, { text = "", color = theme.colors.text.muted, justifyH = "LEFT", wrap = false })
        cells.zone  = NUL:CreateLabel(row, { text = "", size = "sm", color = theme.colors.text.muted, justifyH = "LEFT", wrap = false })
        cells.opts  = buildOptionsCell(row, theme, self_ref)

        local function layout(totalWidth)

            local x = 8
            cells.class:ClearAllPoints(); cells.class:SetPoint("LEFT", row, "LEFT", x, 0); x = x + 22 + 4

            cells.name:ClearAllPoints(); cells.name:SetWidth(170); cells.name:SetPoint("LEFT", row, "LEFT", x, 0); x = x + 170 + 4
            cells.count:ClearAllPoints(); cells.count:SetWidth(60); cells.count:SetPoint("LEFT", row, "LEFT", x, 0); x = x + 60 + 4
            cells.seen:ClearAllPoints(); cells.seen:SetWidth(100); cells.seen:SetPoint("LEFT", row, "LEFT", x, 0); x = x + 100 + 4

            local fixedRight = OPTIONS_W + 8
            local zoneW = math.max(60, totalWidth - x - fixedRight - 4)
            cells.zone:ClearAllPoints(); cells.zone:SetWidth(zoneW); cells.zone:SetPoint("LEFT", row, "LEFT", x, 0); x = x + zoneW + 4

            cells.opts:ClearAllPoints(); cells.opts:SetPoint("LEFT", row, "LEFT", x, 0)
        end
        row._layout = layout
        row._cells  = cells

        return function(r, entry)
            r._layout(r:GetWidth())

            cells.class:SetClass(entry.class or "WARRIOR", "midnight")

            local nameText
            local hex = entry.classColor or (entry.class and NBK:GetClassHex(entry.class)) or "ffffff"
            nameText = ("|cff%s%s|r-%s"):format(hex, entry.name or "?", entry.realm or "")
            cells.name:SetText(nameText)

            cells.count:SetText(("%d×"):format(entry.count or 1))
            cells.seen:SetText(formatDate(entry.lastSeen))
            cells.zone:SetText(entry.zone or "")

            cells.opts.add:SetScript("OnClick", function()

                local lw = NBK:GetModule("ListWindow")
                if lw and lw.ShowAddDialog then
                    lw:ShowAddDialog({
                        name  = (entry.name or "") .. "-" .. (entry.realm or ""),
                        class = entry.class,
                    })
                end
            end)

            cells.opts.remove:SetScript("OnClick", function()
                LibStub("NerzorsUILib-1.0"):Confirm({
                    text = (NBK.L["Remove %s-%s from recents?"] or "Remove %s-%s from recents?")
                            :format(entry.name or "?", entry.realm or ""),
                    onAccept = function()
                        Recents:RemoveEntry(entry.name, entry.realm)
                        Recents:RefreshTab()
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

            text     = col.compact and "" or col.label,
            size     = "sm",
            color    = theme.colors.text.muted,
            justifyH = "LEFT",
        })
        fs:SetPoint("LEFT", 0, 0); fs:SetPoint("RIGHT", 0, 0)
        cell._label = fs
        NBK:SetupColumnHeader(cell, col)
        cells[i] = cell
    end

    header._layout = function()
        local w = header:GetWidth()
        local fixedSum = 0
        for _, col in ipairs(columns) do
            if not col.flex then fixedSum = fixedSum + col.width end
        end
        local flexW = math.max(60, w - fixedSum - (#columns * 4) - 8)
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

function Recents:_BuildTab(parent)
    if tabUI.root then return tabUI.root end
    local NUL   = LibStub("NerzorsUILib-1.0")
    local theme = NUL:GetTheme()

    local root = CreateFrame("Frame", nil, parent)
    root:SetAllPoints()
    tabUI.root = root

    local searchBox = NUL:EditBox(root, {
        width       = 260, height = 26,
        placeholder = NBK.L["Search name, realm, reason..."],
        onTextChanged = function() Recents:RefreshTab() end,
    })
    searchBox:SetPoint("TOPLEFT")
    tabUI.searchEB = searchBox

    local countLabel = NUL:CreateLabel(root, { text = "", color = theme.colors.text.muted })
    countLabel:SetPoint("RIGHT")
    tabUI.countLabel = countLabel

    local hintText = NBK.L["Tracks the last %d unique party-mates (party only - not raid)."]
                   and (NBK.L["Tracks the last %d unique party-mates (party only - not raid)."]):format(self:GetMaxEntries())
                   or  ("Tracks the last %d unique party-mates"):format(self:GetMaxEntries())
    local hint = NUL:CreateLabel(root, {
        text  = hintText,
        size  = "sm",
        color = theme.colors.text.muted,
    })
    hint:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 2, -6)
    tabUI.hint = hint

    local columns = {
        { key = "class",  label = NBK.L["Class"] or "Class",             width = 26, compact = true },
        { key = "name",   label = NBK.L["Name"],                         width = 170 },
        { key = "count",  label = NBK.L["Encounters"] or "Encounters",   width = 60 },
        { key = "seen",   label = NBK.L["Last seen"]  or "Last seen",    width = 100 },
        { key = "zone",   label = NBK.L["Zone"]       or "Zone",         width = 0, flex = true },
        { key = "opts",   label = NBK.L["Options"]    or "Options",      width = OPTIONS_W },
    }

    local header = buildHeader(root, theme, columns)
    header:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", -2, -8)
    header:SetPoint("RIGHT")
    tabUI.header = header

    local list = NUL:ScrollList(root, {
        rowHeight  = ROW_HEIGHT,
        rowBuilder = makeRowBuilder(self),
    })
    list.container:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    list.container:SetPoint("BOTTOMRIGHT")
    tabUI.list = list

    if header._layout then header._layout() end
    self:RefreshTab()

    return root
end

function Recents:RefreshTab()
    if not tabUI.list then return end
    local filter = tabUI.searchEB and tabUI.searchEB:GetText() or ""
    local entries = sortedEntries(self, filter)
    tabUI.list:SetData(entries)

    local total = self:CountEntries()
    local cap   = self:GetMaxEntries()
    local shown = #entries
    local L = NBK.L
    if shown == total then
        tabUI.countLabel:SetText((L["Recents (%d / %d)"] or "Recents (%d / %d)"):format(total, cap))
    else
        tabUI.countLabel:SetText((L["%d / %d"]):format(shown, total))
    end

    if tabUI.hint then
        tabUI.hint:SetText(
            L["Tracks the last %d unique party-mates (party only - not raid)."]
                and (L["Tracks the last %d unique party-mates (party only - not raid)."]):format(cap)
                or  ("Tracks the last %d unique party-mates"):format(cap)
        )
    end
end

local function buildConfigTab(parent)
    local NUL    = LibStub("NerzorsUILib-1.0")
    local L      = NBK.L
    local Config = NBK:GetModule("Config")
    local theme  = NUL:GetTheme()

    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    local y = 0
    local _, ny = Config:AddSectionLabel(panel, y, "Recents"); y = ny

    local scopeLabel = NUL:CreateLabel(panel, {
        text  = L["Storage"] or "Storage",
        color = theme.colors.text.muted,
    })
    scopeLabel:SetPoint("TOPLEFT", 0, y); y = y - 18

    local scopeDD = NUL:Dropdown(panel, {
        width = 220, height = 24,
        options = {
            { key = "account", label = L["Account-wide"]  or "Account-wide" },
            { key = "char",    label = L["Per-character"] or "Per-character" },
        },
        value = settings().scope or "account",
        onSelect = function(v)
            settings().scope = (v == "char") and "char" or "account"
            Recents:RefreshTab()
        end,
    })
    scopeDD:SetPoint("TOPLEFT", 0, y); y = y - 36

    local capLabel = NUL:CreateLabel(panel, {
        text  = L["Maximum entries"] or "Maximum entries",
        color = theme.colors.text.muted,
    })
    capLabel:SetPoint("TOPLEFT", 0, y); y = y - 18

    local capDD = NUL:Dropdown(panel, {
        width = 220, height = 24,
        options = {
            { key = 10, label = "10" }, { key = 15, label = "15" },
            { key = 25, label = "25" }, { key = 50, label = "50" },
        },
        value = settings().maxEntries or 15,
        onSelect = function(v)
            settings().maxEntries = tonumber(v) or 15

            local list = Recents:GetEntries()
            while #list > (settings().maxEntries or 15) do
                local oldestIdx, oldestTs = 1, list[1].lastSeen or 0
                for i = 2, #list do
                    local ts = list[i].lastSeen or 0
                    if ts < oldestTs then oldestIdx, oldestTs = i, ts end
                end
                table.remove(list, oldestIdx)
            end
            Recents:RefreshTab()
        end,
    })
    capDD:SetPoint("TOPLEFT", 0, y); y = y - 36

    local _, ny2 = Config:AddDivider(panel, y); y = ny2

    local clearBtn = NUL:Button(panel, {
        label = L["Clear recents..."] or "Clear recents...",
        width = 180, height = 26, style = "danger",
        onClick = function()
            local n = Recents:CountEntries()
            local prompt = (L["Clear all %d recents entries?"] or "Clear all %d recents entries?"):format(n)
            NUL:Confirm({
                text = prompt,
                onAccept = function()
                    local removed = Recents:Clear()
                    NBK:Print((L["Cleared %d recents entries."] or "Cleared %d recents entries."):format(removed))
                    Recents:RefreshTab()
                end,
            })
        end,
    })
    clearBtn:SetPoint("TOPLEFT", 0, y); y = y - 32

    panel.lastY = y
    return panel
end

local function buildRecentsContextActions(rootDescription, name, realm, unit, contextData)
    if not Recents:HasEntry(name, realm) then return end
    local L = NBK.L
    rootDescription:CreateButton(L["Remove from recents"] or "Remove from recents", function()
        Recents:RemoveEntry(name, realm)
        Recents:RefreshTab()
    end)
end

local function attachRoster(self_ref)
    local f = CreateFrame("Frame")
    f:RegisterEvent("GROUP_ROSTER_UPDATE")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function() self_ref:ScanParty() end)
end

function Recents:OnEnable()

    attachRoster(self)

    local lw = NBK:GetModule("ListWindow")
    if lw and lw.RegisterTab then
        lw:RegisterTab({
            key      = "recents",
            labelKey = "Recents",
            order    = 20,
            build    = function(parent) return Recents:_BuildTab(parent) end,
            refresh  = function() Recents:RefreshTab() end,
            onShow   = function() Recents:RefreshTab() end,
        })
    end

    local Config = NBK:GetModule("Config")
    if Config and Config.RegisterTab then
        Config:RegisterTab({
            key = "Recents", labelKey = "Recents", build = buildConfigTab,
            order = 35, icon = "tab-recents.png", category = "modules",
        })
    end

    local cm = NBK:GetModule("ContextMenu")
    if cm and cm.RegisterAction then
        cm:RegisterAction({
            key     = "recents_remove",
            order   = 30,
            builder = buildRecentsContextActions,
        })
    end
end
