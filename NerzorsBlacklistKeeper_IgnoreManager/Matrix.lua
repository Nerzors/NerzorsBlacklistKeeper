local NBK = _G.NBK
if not NBK then return end

local NUL = LibStub("NerzorsUILib-1.0")

local IgnoreAllChars = NBK:GetModule("IgnoreAllChars")
if not IgnoreAllChars then return end

local ROW_HEIGHT    = 26
local HEADER_HEIGHT = 34
local GAP           = 4
local LEFT_PAD      = 8

local CHECK_W, CLASS_W, NAME_W, BL_W, CHAR_W = 20, 26, 176, 90, 86
local MAX_COLS      = 12
local SCROLL_GUTTER = 22
local CAP           = 50

local ui = { page = 1, visible = {}, rows = {}, allRows = {}, goneRows = {} }
IgnoreAllChars.selected = {}

local X_CHECK = LEFT_PAD
local X_CLASS = X_CHECK + CHECK_W + GAP
local X_NAME  = X_CLASS + CLASS_W + GAP
local X_BL    = X_NAME + NAME_W + GAP
local X_CHARS = X_BL + BL_W + GAP

local function charX(i) return X_CHARS + (i - 1) * (CHAR_W + GAP) end

local function columnsFor(width)
    local n = math.floor((width - X_CHARS - SCROLL_GUTTER + GAP) / (CHAR_W + GAP))
    return math.max(1, math.min(MAX_COLS, n))
end

local function classHex(class) return class and NBK:GetClassHex(class) or "ffffff" end

local function charLabel(ch)
    local s = ("|cff%s%s|r"):format(classHex(ch.class), ch.name or "?")
    return ch.current and ("• " .. s) or s
end

local function charTooltip(ch)
    local L, theme = NBK.L, NUL:GetTheme()
    local lines = {
        L["Snapshot from %s"]:format(ch.scannedAt and NBK:FormatDateTime(ch.scannedAt) or "-"),
        L["Ignore list: %d / %d"]:format(ch.count or 0, CAP),
    }
    if ch.current then lines[#lines + 1] = L["This character"] end
    if (ch.planned or 0) > 0 then lines[#lines + 1] = L["Planned changes: %d"]:format(ch.planned) end
    if ch.stale then
        lines[#lines + 1] = ("|cff%s%s|r"):format(NUL.ToHex(theme.colors.state.warning),
            L["Older than 30 days - log in on this character to update it."])
    end
    return table.concat(lines, "\n")
end

local function deletedLine(e)
    return ("|cff%s%s|r"):format(NUL.ToHex(NUL:GetTheme().colors.state.warning),
        NBK.L["No longer exists (reported by the game on %s)"]:format(NBK:FormatDate(e.deletedAt)))
end

local function rowTooltip(e)
    local L = NBK.L
    local lines = {}
    if e.deleted then lines[1] = deletedLine(e) end
    lines[#lines + 1] = L["Ignored on: %d / %d"]:format(e.onCount, #(ui.chars or {}))
    for _, ch in ipairs(ui.chars or {}) do
        if e.on[ch.key] then lines[#lines + 1] = "  " .. charLabel(ch) .. NBK:RealmSuffix(ch.realm) end
    end
    if e.bl then
        local accent = NUL.ToHex(NUL:GetTheme().colors.accent.primary)
        lines[#lines + 1] = " "
        lines[#lines + 1] = ("|cff%s%s|r"):format(accent, L["Blacklisted"])
        lines[#lines + 1] = ("%s: %s"):format(L["Added"], NBK:FormatDate(e.bl.addedAt))
        local reason = e.bl.reason ~= "" and NBK:ReasonText(e.bl.reason) or L["no reason logged"]
        lines[#lines + 1] = ("%s: %s"):format(L["Reason"], reason)
    end
    return table.concat(lines, "\n")
end

local function cellJob(e, ch)
    if ch.current or e.gone[ch.key] then return nil end
    return IgnoreAllChars:GetPlanned(ch.key, e.key)
end

local function locked(e, ch) return e.deleted or e.gone[ch.key] == true end

local function cellTooltip(e, ch)
    local L, theme = NBK.L, NUL:GetTheme()
    local ignored, job = e.on[ch.key] == true, cellJob(e, ch)
    local lines = { charLabel(ch) .. NBK:RealmSuffix(ch.realm) }
    if e.gone[ch.key] then
        lines[2] = ("|cff%s%s|r"):format(NUL.ToHex(theme.colors.state.warning),
            L["No longer exists - the game removes it at this character's next login."])
        return table.concat(lines, "\n")
    end
    lines[2] = ignored and L["Ignored"] or L["Not ignored"]
    if e.deleted then
        lines[3] = deletedLine(e)
        return table.concat(lines, "\n")
    end
    if job then
        lines[#lines + 1] = job.op == "del" and L["Planned: remove at next login"]
                                             or L["Planned: ignore at next login"]
        if job.failed then
            lines[#lines + 1] = ("|cff%s%s|r"):format(NUL.ToHex(theme.colors.state.warning),
                job.failed == "full" and L["Last attempt failed: the ignore list is full."]
                                      or L["Last attempt failed."])
        end
    end
    local hint
    if ch.current then
        hint = ignored and L["Click to remove now"] or L["Click to ignore now"]
    elseif job then
        hint = L["Click to cancel"]
    else
        hint = ignored and L["Click to remove at next login"] or L["Click to ignore at next login"]
    end
    lines[#lines + 1] = ("|cff%s%s|r"):format(NUL.ToHex(theme.colors.text.muted), hint)
    return table.concat(lines, "\n")
end

local function paintCell(cell, e, ch)
    local t = NUL:GetTheme()
    local ignored, job = e.on[ch.key] == true, cellJob(e, ch)
    local fill, edge
    if e.gone[ch.key] then
        fill, edge = NUL.WithAlpha(t.colors.text.muted, 0.35), t.colors.text.muted
    elseif ignored and job and job.op == "del" then
        fill, edge = t.colors.state.danger, t.colors.state.danger
    elseif ignored then
        fill, edge = t.colors.accent.primary, t.colors.accent.primary
    elseif job and job.op == "add" then
        edge = job.failed and t.colors.state.warning or t.colors.accent.primary
    end
    cell.box:SetShown(edge ~= nil)
    if edge then
        NUL.SetTextureColor(cell.boxFill, fill or NUL.WithAlpha(edge, 0))
        NUL:RecolorBorder(cell.boxEdges, edge)
    end
    NUL.SetTextureColor(cell.hl, t.colors.bg.hover)
end

function IgnoreAllChars:_OnCellClick(e, ch)
    if locked(e, ch) then return end
    local ignored = e.on[ch.key] == true
    if not ch.current then
        self:TogglePlanned(ch.key, e, ignored)
        self:Refresh()
        return
    end

    if ignored then
        local tab = NBK:GetModule("IgnoreTab")
        if tab and tab.ConfirmRemove then tab:ConfirmRemove({ e }) end
        return
    end
    local IS, core = NBK:GetModule("IgnoreSync"), NBK:GetModule("IgnoreManager")
    if not IS then return end
    if (core and core:Count() or 0) >= CAP then
        NBK:Print(NBK.L["Could not ignore %s - the ignore list is full."]
            :format(NBK:DisplayName(e.name, e.realm)))
        return
    end
    IS:Add(e.name, e.realm)
end

local function buildHeader(parent)
    local L, theme = NBK.L, NUL:GetTheme()
    local header = CreateFrame("Frame", nil, parent)
    header:SetHeight(HEADER_HEIGHT)
    NUL:FillBackground(header, theme.colors.bg.panel)

    local function fixedLabel(text, x)
        local fs = NUL:CreateLabel(header, {
            text = text, size = "sm", color = theme.colors.text.muted, justifyH = "LEFT", wrap = false,
        })
        fs:SetPoint("LEFT", header, "LEFT", x, 0)
        return fs
    end
    fixedLabel(L["Name"], X_NAME)
    fixedLabel(L["Blacklist"], X_BL)

    header.cells = {}
    for i = 1, MAX_COLS do
        local cell = CreateFrame("Frame", nil, header)
        cell:SetSize(CHAR_W, HEADER_HEIGHT)
        cell:SetPoint("LEFT", header, "LEFT", charX(i), 0)
        cell.name = NUL:CreateLabel(cell, { text = "", size = "sm", justifyH = "LEFT", wrap = false })
        cell.name:SetPoint("TOPLEFT", 0, -3); cell.name:SetPoint("TOPRIGHT", 0, -3)
        cell.date = NUL:CreateLabel(cell, { text = "", size = "xs", justifyH = "LEFT", wrap = false })
        cell.date:SetPoint("BOTTOMLEFT", 0, 4); cell.date:SetPoint("BOTTOMRIGHT", 0, 4)
        cell:EnableMouse(true)
        cell:SetScript("OnEnter", function(self)
            if not self.ch then return end
            NUL:ShowTooltipMultiline(self, {
                title = NBK:DisplayName(self.ch.name, self.ch.realm),
                body  = charTooltip(self.ch),
            })
        end)
        cell:SetScript("OnLeave", function() NUL:HideTooltip() end)
        header.cells[i] = cell
    end
    return header
end

local function paintHeader()
    local theme = NUL:GetTheme()
    for i, cell in ipairs(ui.header.cells) do
        local ch = ui.visible[i]
        cell.ch = ch
        cell:SetShown(ch ~= nil)
        if ch then
            cell.name:SetText(charLabel(ch))
            cell.date:SetText(ch.scannedAt and NBK:FormatDate(ch.scannedAt) or "-")
            NUL.SetFontColor(cell.date, ch.stale and theme.colors.state.warning or theme.colors.text.muted)
        end
    end
end

local function rowBuilder(row)
    local theme = NUL:GetTheme()
    local check = NUL:Checkbox(row, { size = "small" })
    check:SetPoint("LEFT", row, "LEFT", X_CHECK, 0)
    local class = NBK.UI:CreateClassIcon(row, 18)
    class:SetPoint("LEFT", row, "LEFT", X_CLASS, 0)
    local name = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
    name:SetPoint("LEFT", row, "LEFT", X_NAME, 0)
    name:SetWidth(NAME_W)
    local bl = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
    bl:SetPoint("LEFT", row, "LEFT", X_BL, 0)
    bl:SetWidth(BL_W)

    local cells = {}
    for i = 1, MAX_COLS do
        local cell = CreateFrame("Button", nil, row)
        cell:SetSize(CHAR_W, ROW_HEIGHT)
        cell:SetPoint("LEFT", row, "LEFT", charX(i), 0)
        cell.hl = cell:CreateTexture(nil, "HIGHLIGHT")
        cell.hl:SetAllPoints()
        local box = CreateFrame("Frame", nil, cell)
        box:SetSize(10, 10)
        box:SetPoint("LEFT", cell, "LEFT", 4, 0)
        cell.box      = box
        cell.boxFill  = NUL:FillBackground(box, theme.colors.accent.primary)
        cell.boxEdges = NUL:AddBorder(box, theme.colors.accent.primary, 1)
        cell:SetScript("OnLeave", function() NUL:HideTooltip() end)
        cells[i] = cell
    end

    row:EnableMouse(true)

    return function(r, e)
        local t = NUL:GetTheme()
        check:SetChecked(IgnoreAllChars.selected[e.key] == true)
        check:SetOnChange(function(on) IgnoreAllChars:SetSelected(e.key, on) end)
        class:SetClass(e.class)
        if e.deleted then
            name:SetText(("|cff%s%s|r"):format(NUL.ToHex(t.colors.text.muted), NBK:DisplayName(e.name, e.realm)))
        else
            name:SetText(NBK:DisplayName(e.name, e.realm, classHex(e.class)))
        end
        if e.bl then
            bl:SetText(NBK:FormatDate(e.bl.addedAt))
            NUL.SetFontColor(bl, t.colors.accent.primary)
        else
            bl:SetText("-")
            NUL.SetFontColor(bl, t.colors.text.muted)
        end
        for i, cell in ipairs(cells) do
            local ch = ui.visible[i]
            cell:SetShown(ch ~= nil)
            if ch then
                paintCell(cell, e, ch)

                cell:SetEnabled(not locked(e, ch))
                cell:SetScript("OnClick", function() IgnoreAllChars:_OnCellClick(e, ch) end)
                cell:SetScript("OnEnter", function(self)
                    NUL:ShowTooltipMultiline(self, {
                        title = NBK:DisplayName(e.name, e.realm),
                        body  = cellTooltip(e, ch),
                    })
                end)
            end
        end
        r:SetScript("OnEnter", function(self)
            NUL:ShowTooltipMultiline(self, {
                title = NBK:DisplayName(e.name, e.realm),
                body  = rowTooltip(e),
            })
        end)
        r:SetScript("OnLeave", function() NUL:HideTooltip() end)
    end
end

function IgnoreAllChars:_BuildView(parent)
    local L, theme = NBK.L, NUL:GetTheme()
    local f = CreateFrame("Frame", nil, parent)
    f:SetAllPoints()
    ui.view = f

    ui.search = NUL:EditBox(f, {
        width = 260, height = 26,
        placeholder = L["Search name, realm, reason..."],
        onTextChanged = function() IgnoreAllChars:Refresh() end,
    })
    ui.search:SetPoint("TOPLEFT")

    ui.next = NUL:IconButton(f, {
        icon = "arrow-right.png", size = 20, plain = true,
        onClick = function() ui.page = ui.page + 1; IgnoreAllChars:Refresh() end,
    })
    ui.next:SetPoint("RIGHT", f, "TOPRIGHT", 0, -13)
    ui.pageLabel = NUL:CreateLabel(f, { text = "", color = theme.colors.text.muted, wrap = false })
    ui.pageLabel:SetPoint("RIGHT", ui.next, "LEFT", -4, 0)
    ui.prev = NUL:IconButton(f, {
        icon = "arrow-right.png", size = 20, plain = true,
        onClick = function() ui.page = ui.page - 1; IgnoreAllChars:Refresh() end,
    })
    ui.prev.icon:SetTexCoord(1, 0, 0, 1)
    ui.prev:SetPoint("RIGHT", ui.pageLabel, "LEFT", -4, 0)

    ui.count = NUL:CreateLabel(f, { text = "", color = theme.colors.text.muted, wrap = false })

    ui.hint = NUL:CreateLabel(f, {
        text  = L["Log in once on each character so the overview is complete; a date in the warning colour is older than 30 days. Click a cell to change it - on other characters the change waits for their next login."],
        size  = "sm",
        color = theme.colors.text.muted,
    })
    ui.hint:SetPoint("TOPLEFT", ui.search, "BOTTOMLEFT", 2, -6)
    ui.hint:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    ui.hint:SetJustifyH("LEFT")

    ui.gone = CreateFrame("Frame", nil, f)
    ui.gone:SetHeight(22)
    ui.gone:SetPoint("TOPLEFT", ui.hint, "BOTTOMLEFT", -2, -6)
    ui.gone:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    ui.goneLabel = NUL:CreateLabel(ui.gone, { text = "", wrap = false })
    ui.goneLabel:SetPoint("LEFT", 0, 0)
    local cleanBtn = NUL:Button(ui.gone, {
        label = L["Clean up"], width = 110, height = 22,
        onClick = function() IgnoreAllChars:ConfirmForgetDeleted(ui.goneRows) end,
    })
    cleanBtn:SetPoint("RIGHT", 0, 0)

    local bar = CreateFrame("Frame", nil, f)
    bar:SetHeight(26)
    ui.bar = bar

    ui.selAll = NUL:Button(bar, {
        label = L["Select all"], width = 110, height = 22,
        onClick = function() IgnoreAllChars:_ToggleSelectAll() end,
    })
    ui.selAll:SetPoint("LEFT", 0, 0)

    local ignoreBtn = NUL:Button(bar, {
        label = L["Ignore everywhere"], width = 140, height = 22, style = "accent",
        tooltip = L["Ignores the selected players on every character: right away on this one, at their next login on the others."],
        onClick = function() IgnoreAllChars:ConfirmEverywhere(IgnoreAllChars:SelectedRows(), "add") end,
    })
    ignoreBtn:SetPoint("LEFT", ui.selAll, "RIGHT", 6, 0)

    local removeBtn = NUL:Button(bar, {
        label = L["Remove everywhere"], width = 140, height = 22, style = "danger",
        tooltip = L["Removes the selected players from every character's ignore list: right away on this one, at their next login on the others."],
        onClick = function() IgnoreAllChars:ConfirmEverywhere(IgnoreAllChars:SelectedRows(), "del") end,
    })
    removeBtn:SetPoint("LEFT", ignoreBtn, "RIGHT", 6, 0)

    ui.selCount = NUL:CreateLabel(bar, { text = "", color = theme.colors.text.muted, wrap = false })
    ui.selCount:SetPoint("RIGHT", bar, "RIGHT", 0, 0)

    ui.header = buildHeader(f)
    ui.header:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -6)
    ui.header:SetPoint("RIGHT")

    ui.list = NUL:ScrollList(f, { rowHeight = ROW_HEIGHT, rowBuilder = rowBuilder })
    ui.list.container:SetPoint("TOPLEFT", ui.header, "BOTTOMLEFT", 0, -2)
    ui.list.container:SetPoint("BOTTOMRIGHT")

    ui.header:SetScript("OnSizeChanged", function() IgnoreAllChars:Refresh() end)

    self:Refresh()
    return f
end

local function layoutColumns(chars)
    local perPage = columnsFor(ui.header:GetWidth())
    local pages   = math.max(1, math.ceil(#chars / perPage))
    ui.page = math.max(1, math.min(ui.page, pages))

    local first = (ui.page - 1) * perPage + 1
    wipe(ui.visible)
    for i = first, math.min(#chars, first + perPage - 1) do
        ui.visible[#ui.visible + 1] = chars[i]
    end

    local paged = pages > 1
    ui.prev:SetShown(paged); ui.next:SetShown(paged); ui.pageLabel:SetShown(paged)
    ui.prev:SetEnabled(ui.page > 1)
    ui.next:SetEnabled(ui.page < pages)
    ui.pageLabel:SetText(("%d–%d / %d"):format(first, first + #ui.visible - 1, #chars))

    ui.count:ClearAllPoints()
    if paged then
        ui.count:SetPoint("RIGHT", ui.prev, "LEFT", -12, 0)
    else
        ui.count:SetPoint("RIGHT", ui.view, "TOPRIGHT", 0, -13)
    end
end

function IgnoreAllChars:SetSelected(key, on)
    self.selected[key] = on and true or nil
    self:_UpdateBar()
end

function IgnoreAllChars:SelectedRows()
    local out = {}
    for _, e in ipairs(ui.allRows) do
        if self.selected[e.key] then out[#out + 1] = e end
    end
    return out
end

local function allVisibleSelected()
    for _, e in ipairs(ui.rows) do
        if not IgnoreAllChars.selected[e.key] then return false end
    end
    return #ui.rows > 0
end

function IgnoreAllChars:_ToggleSelectAll()
    local on = not allVisibleSelected()
    for _, e in ipairs(ui.rows) do self.selected[e.key] = on or nil end
    self:Refresh()
end

function IgnoreAllChars:_UpdateBar()
    if not ui.selCount then return end
    local L = NBK.L
    ui.selCount:SetText(L["%d selected"]:format(#self:SelectedRows()))
    ui.selAll:SetLabel(allVisibleSelected() and L["Select none"] or L["Select all"])
end

function IgnoreAllChars:Refresh()
    if not ui.list then return end
    local L = NBK.L

    ui.chars = self:GetCharacters()
    ui.allRows = self:GetRows(ui.chars)

    local present = {}
    for _, e in ipairs(ui.allRows) do present[e.key] = true end
    for key in pairs(self.selected) do
        if not present[key] then self.selected[key] = nil end
    end

    local filter = (ui.search and ui.search:GetText() or ""):lower()
    local byRealm = not NBK:IsForever()
    local rows = {}
    for _, e in ipairs(ui.allRows) do
        local reason = e.bl and NBK:ReasonText(e.bl.reason) or ""
        if filter == ""
           or (e.name or ""):lower():find(filter, 1, true)
           or (byRealm and (e.realm or ""):lower():find(filter, 1, true))
           or reason:lower():find(filter, 1, true) then
            rows[#rows + 1] = e
        end
    end
    ui.rows = rows

    ui.goneRows = {}
    for _, e in ipairs(ui.allRows) do
        if e.goneCount > 0 then ui.goneRows[#ui.goneRows + 1] = e end
    end
    local showGone = #ui.goneRows > 0
    ui.gone:SetShown(showGone)
    ui.goneLabel:SetText(L["Players that no longer exist: %d"]:format(#ui.goneRows))
    NUL.SetFontColor(ui.goneLabel, NUL:GetTheme().colors.state.warning)
    ui.bar:ClearAllPoints()
    if showGone then
        ui.bar:SetPoint("TOPLEFT", ui.gone, "BOTTOMLEFT", 0, -6)
    else
        ui.bar:SetPoint("TOPLEFT", ui.hint, "BOTTOMLEFT", -2, -6)
    end
    ui.bar:SetPoint("RIGHT", ui.view, "RIGHT", 0, 0)

    ui.count:SetText(L["Characters: %d"]:format(#ui.chars))
    layoutColumns(ui.chars)
    paintHeader()
    ui.list:SetData(rows)
    self:_UpdateBar()
end
