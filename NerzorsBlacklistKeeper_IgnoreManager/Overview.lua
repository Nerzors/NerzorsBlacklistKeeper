local NBK = _G.NBK
if not NBK then return end

local NUL = LibStub("NerzorsUILib-1.0")

local IgnoreAllChars = NBK:GetModule("IgnoreAllChars")
if not IgnoreAllChars then return end

local ROW_HEIGHT    = 26
local CHAR_ROW_H    = 34
local HEADER_HEIGHT = 20
local GAP           = 4
local LEFT_PAD      = 8
local SCROLL_GUTTER = 22
local CAP           = 50

local CHECK_W, CLASS_W, ON_W, BL_W = 20, 26, 96, 80
local X_CHECK = LEFT_PAD
local X_CLASS = X_CHECK + CHECK_W + GAP
local X_NAME  = X_CLASS + CLASS_W + GAP
local R_BL    = LEFT_PAD
local R_ON    = R_BL + BL_W + GAP
local R_NAME  = R_ON + ON_W + GAP

local DETAIL_W   = 320
local PANE_GAP   = 8
local DETAIL_PAD = 8
local BTN_H      = 24

local DETAIL_TOP       = 60
local DETAIL_REASON_H = 16

local ui = { rows = {}, allRows = {}, goneRows = {}, chars = {}, order = {} }
IgnoreAllChars.selected = {}

local function classHex(class) return class and NBK:GetClassHex(class) or "ffffff" end

local function colored(color, text) return ("|cff%s%s|r"):format(NUL.ToHex(color), text) end

local function charLabel(ch)
    return ("|cff%s%s|r"):format(classHex(ch.class), ch.name or "?") .. NBK:RealmSuffix(ch.realm)
end

local function idle(e, ch)
    return not e.on[ch.key] and not e.gone[ch.key]
       and (ch.current or IgnoreAllChars:GetPlanned(ch.key, e.key) == nil)
end

local function detailOrder(e)
    local groups = { {}, {}, {} }
    for _, ch in ipairs(ui.chars) do
        local g = ch.current and 1 or (idle(e, ch) and 3 or 2)
        groups[g][#groups[g] + 1] = ch.key
    end
    local order = {}
    for _, g in ipairs(groups) do
        for _, key in ipairs(g) do order[#order + 1] = key end
    end
    return order
end

local function onText(e)
    if e.onCount == 1 then
        for _, ch in ipairs(ui.chars) do
            if e.on[ch.key] then return ch.name or "?" end
        end
    end
    return ("%d / %d"):format(e.onCount, #ui.chars)
end

local function deletedLine(e)
    return colored(NUL:GetTheme().colors.state.warning,
        NBK.L["No longer exists (reported by the game on %s)"]:format(NBK:FormatDate(e.deletedAt)))
end

local function jobFor(e, ch)
    if ch.current or e.gone[ch.key] then return nil end
    return IgnoreAllChars:GetPlanned(ch.key, e.key)
end

local function locked(e, ch) return e.deleted or e.gone[ch.key] == true end

local function wanted(e, ch)
    local job = jobFor(e, ch)
    if job then return job.op == "add" end
    return e.on[ch.key] == true
end

local function stateText(e, ch)
    local L, t = NBK.L, NUL:GetTheme()
    if e.gone[ch.key] then return L["No longer exists"], t.colors.state.warning end
    local job = jobFor(e, ch)
    if job then
        if job.failed then
            return (job.failed == "full") and L["Last attempt failed: the ignore list is full."]
                                           or L["Last attempt failed."], t.colors.state.warning
        end
        return (job.op == "del") and L["Planned: remove at next login"]
                                  or L["Planned: ignore at next login"], t.colors.accent.primary
    end
    if e.on[ch.key] then return L["Ignored"], t.colors.text.primary end
    return L["Not ignored"], t.colors.text.muted
end

local function charTooltip(e, ch)
    local L, t = NBK.L, NUL:GetTheme()
    local lines = {
        L["Snapshot from %s"]:format(ch.scannedAt and NBK:FormatDateTime(ch.scannedAt) or "-"),
        L["Ignore list: %d / %d"]:format(ch.count or 0, CAP),
    }
    if ch.current then lines[#lines + 1] = L["This character"] end
    if (ch.planned or 0) > 0 then lines[#lines + 1] = L["Planned changes: %d"]:format(ch.planned) end
    if ch.stale then
        lines[#lines + 1] = colored(t.colors.state.warning,
            L["Older than 30 days - log in on this character to update it."])
    end
    lines[#lines + 1] = " "
    if e.gone[ch.key] then
        lines[#lines + 1] = colored(t.colors.state.warning,
            L["No longer exists - the game removes it at this character's next login."])
    elseif e.deleted then
        lines[#lines + 1] = deletedLine(e)
    else
        local job = jobFor(e, ch)
        if job and job.failed then
            lines[#lines + 1] = (job.op == "del") and L["Planned: remove at next login"]
                                                   or L["Planned: ignore at next login"]
        end
        local ignored, hint = e.on[ch.key] == true, nil
        if ch.current then
            hint = ignored and L["Click to remove now"] or L["Click to ignore now"]
        elseif job then
            hint = L["Click to cancel"]
        else
            hint = ignored and L["Click to remove at next login"] or L["Click to ignore at next login"]
        end
        lines[#lines + 1] = colored(t.colors.text.muted, hint)
    end
    if not ch.current then
        lines[#lines + 1] = colored(t.colors.text.muted, L["Shift-right-click: remove this character from the Ignore Manager"])
    end
    return table.concat(lines, "\n")
end

function IgnoreAllChars:_ToggleChar(e, ch)
    if not e or not ch or locked(e, ch) then return end
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

function IgnoreAllChars:ImportRows(rows)
    local L, IS = NBK.L, NBK:GetModule("IgnoreSync")
    if not IS or not IS.ImportNames then return 0 end
    if #rows == 0 then
        NBK:Print(L["Select at least one player first."])
        return 0
    end
    local fulls = {}
    for _, row in ipairs(rows) do
        if not row.bl and not row.deleted then
            fulls[#fulls + 1] = (row.name or "") .. "-" .. (row.realm or "")
        end
    end
    if #fulls == 0 then
        NBK:Print(L["Nothing to import - the selected players are already on the blacklist."])
        return 0
    end
    local added = IS:ImportNames(fulls)
    NBK:Print(L["Imported %d player(s) from the ignore list."]:format(added))
    local lw = NBK:GetModule("ListWindow")
    if lw and lw.Refresh then lw:Refresh() end

    local core = NBK:GetModule("IgnoreManager")
    if core and core.RefreshTab then core:RefreshTab() else self:Refresh() end
    return added
end

local function buildListHeader(parent)
    local L, theme = NBK.L, NUL:GetTheme()
    local header = CreateFrame("Frame", nil, parent)
    header:SetHeight(HEADER_HEIGHT)
    NUL:Surface(header, "header")

    local function label(text)
        return NUL:CreateLabel(header, {
            text = text, size = "sm", color = theme.colors.text.muted, justifyH = "LEFT", wrap = false,
            role = "column",
        })
    end
    local name = label(L["Name"])
    name:SetPoint("LEFT", header, "LEFT", X_NAME, 0)

    local on = label(L["Ignored"])
    on:SetPoint("LEFT", header, "RIGHT", -(SCROLL_GUTTER + 2 + R_ON + ON_W), 0)
    on:SetWidth(ON_W)
    local bl = label(L["Blacklist"])
    bl:SetPoint("LEFT", header, "RIGHT", -(SCROLL_GUTTER + 2 + R_BL + BL_W), 0)
    bl:SetWidth(BL_W)
    return header
end

local function playerRowBuilder(row)
    local theme = NUL:GetTheme()
    local check = NUL:Checkbox(row, { size = "small" })
    check:SetPoint("LEFT", row, "LEFT", X_CHECK, 0)
    local class = NBK.UI:CreateClassIcon(row, 18)
    class:SetPoint("LEFT", row, "LEFT", X_CLASS, 0)
    local name = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
    name:SetPoint("LEFT", row, "LEFT", X_NAME, 0)
    name:SetPoint("RIGHT", row, "RIGHT", -R_NAME, 0)
    local on = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
    on:SetPoint("LEFT", row, "RIGHT", -(R_ON + ON_W), 0)
    on:SetWidth(ON_W)
    local bl = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
    bl:SetPoint("LEFT", row, "RIGHT", -(R_BL + BL_W), 0)
    bl:SetWidth(BL_W)

    local picked = row:CreateTexture(nil, "ARTWORK")
    picked:SetPoint("TOPLEFT", 0, 0)
    picked:SetPoint("BOTTOMLEFT", 0, 0)
    picked:SetWidth(3)
    picked:Hide()
    local tint = row:CreateTexture(nil, "BORDER")
    tint:SetAllPoints()
    tint:Hide()

    row:HookScript("OnEnter", function(self)
        local e = self._entry
        if e and e.deleted then
            NUL:ShowTooltipMultiline(self, {
                title = NBK:DisplayName(e.name, e.realm), body = deletedLine(e),
            })
        end
    end)
    row:HookScript("OnLeave", function() NUL:HideTooltip() end)

    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetScript("OnClick", function(self, button)
        local e = self._entry
        if not e then return end
        IgnoreAllChars:_Pick(e.key)
        if button == "RightButton" then
            NUL:ShowMenu(self, IgnoreAllChars:_PlayerMenuItems(e), { anchor = "cursor" })
        end
    end)
    row:SetScript("OnDoubleClick", function(self, button)
        local e = self._entry
        if button == "LeftButton" and e and e.bl then
            NUL:HideMenu()
            local bt = NBK:GetModule("BlacklistTab")
            if bt then bt:_ShowEditDialog(e.bl) end
        end
    end)

    return function(r, e)
        local t = NUL:GetTheme()
        check:SetChecked(IgnoreAllChars.selected[e.key] == true)
        check:SetOnChange(function(v) IgnoreAllChars:SetSelected(e.key, v) end)
        class:SetClass(e.class)
        if e.deleted then
            name:SetText(colored(t.colors.text.muted, NBK:DisplayName(e.name, e.realm)))
        else
            name:SetText(NBK:DisplayName(e.name, e.realm, classHex(e.class)))
        end
        on:SetText(onText(e))
        NUL.SetFontColor(on, e.deleted and t.colors.text.muted or t.colors.text.primary)
        if e.bl then
            bl:SetText(NBK:FormatDate(e.bl.addedAt))
            NUL.SetFontColor(bl, t.colors.accent.primary)
        else
            bl:SetText("-")
            NUL.SetFontColor(bl, t.colors.text.muted)
        end
        local isPicked = e.key == ui.pickedKey
        NUL.SetTextureColor(picked, t.colors.accent.primary)
        NUL.SetTextureColor(tint, NUL.WithAlpha(t.colors.accent.primary, 0.14))
        picked:SetShown(isPicked)
        tint:SetShown(isPicked)
    end
end

local function charRowBuilder(row)
    local theme = NUL:GetTheme()
    local check = NUL:Checkbox(row, { size = "small" })
    check:SetPoint("LEFT", row, "LEFT", 6, 0)
    local name = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
    name:SetPoint("TOPLEFT", row, "TOPLEFT", 28, -4)
    name:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    local date = NUL:CreateLabel(row, { text = "", size = "sm", justifyH = "RIGHT", wrap = false })
    date:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -6, 4)
    date:SetWidth(64)
    local state = NUL:CreateLabel(row, { text = "", size = "sm", justifyH = "LEFT", wrap = false })

    row:HookScript("OnEnter", function(self)
        local ch, e = self._entry, ui.picked
        if ch and e then
            NUL:ShowTooltipMultiline(self, { title = charLabel(ch), body = charTooltip(e, ch), anchor = "LEFT" })
        end
    end)
    row:HookScript("OnLeave", function() NUL:HideTooltip() end)

    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            if IsShiftKeyDown() then
                NUL:HideTooltip()
                IgnoreAllChars:ConfirmForgetCharacter(self._entry)
            end
            return
        end
        IgnoreAllChars:_ToggleChar(ui.picked, self._entry)
    end)

    return function(r, ch)
        local L, t = NBK.L, NUL:GetTheme()
        local e = ui.picked
        if not e then return end

        local label
        if idle(e, ch) then
            label = colored(t.colors.text.muted, (ch.name or "?") .. NBK:RealmSuffix(ch.realm))
        else
            label = charLabel(ch)
        end
        if ch.current then label = label .. "  " .. colored(t.colors.text.muted, "(" .. L["This character"] .. ")") end
        name:SetText(label)

        local text, color = stateText(e, ch)
        state:SetText(text)
        NUL.SetFontColor(state, color)

        date:SetShown(ch.stale == true)
        date:SetText(ch.scannedAt and NBK:FormatDate(ch.scannedAt) or "-")
        NUL.SetFontColor(date, t.colors.state.warning)
        state:ClearAllPoints()
        state:SetPoint("BOTTOMLEFT", r, "BOTTOMLEFT", 28, 4)
        if ch.stale then
            state:SetPoint("RIGHT", date, "LEFT", -4, 0)
        else
            state:SetPoint("RIGHT", r, "RIGHT", -6, 0)
        end

        local lock = locked(e, ch)
        check:SetChecked(wanted(e, ch))
        check:EnableMouse(not lock)
        check:SetAlpha(lock and 0.4 or 1)

        check:SetOnChange(function()
            IgnoreAllChars:_ToggleChar(e, ch)
            IgnoreAllChars:_RefreshDetail()
        end)
    end
end

local function buildDetail(parent)
    local L, theme = NBK.L, NUL:GetTheme()
    local d = CreateFrame("Frame", nil, parent)
    d:SetWidth(DETAIL_W)
    d.bg      = NUL:FillBackground(d, theme.colors.bg.panel)
    d.borders = NUL:AddBorder(d, theme.colors.border.subtle, theme.metrics.borderThickness)

    d.empty = NUL:CreateLabel(d, {
        text = L["Select a player on the left."], color = theme.colors.text.muted, justifyH = "CENTER",
    })
    d.empty:SetPoint("TOPLEFT", DETAIL_PAD, -24)
    d.empty:SetPoint("TOPRIGHT", -DETAIL_PAD, -24)

    local body = CreateFrame("Frame", nil, d)
    body:SetPoint("TOPLEFT", DETAIL_PAD, -DETAIL_PAD)
    body:SetPoint("BOTTOMRIGHT", -DETAIL_PAD, DETAIL_PAD)
    d.body = body

    d.class = NBK.UI:CreateClassIcon(body, 18)
    d.class:SetPoint("TOPLEFT", 0, -1)
    d.name = NUL:CreateLabel(body, { text = "", size = "lg", justifyH = "LEFT", wrap = false })
    d.name:SetPoint("TOPLEFT", 24, 0)
    d.name:SetPoint("RIGHT", body, "RIGHT", 0, 0)

    d.info = NUL:CreateLabel(body, { text = "", size = "sm", justifyH = "LEFT", wrap = false })
    d.info:SetPoint("TOPLEFT", 0, -24)
    d.info:SetPoint("RIGHT", body, "RIGHT", 0, 0)

    d.reason = NUL:CreateLabel(body, { text = "", size = "sm", justifyH = "LEFT", wrap = false })
    d.reason:SetPoint("TOPLEFT", 0, -40)
    d.reason:SetPoint("RIGHT", body, "RIGHT", 0, 0)

    d.on = NUL:CreateLabel(body, {
        text = "", size = "sm", color = theme.colors.text.muted, justifyH = "LEFT", wrap = false,
    })

    local w = DETAIL_W - DETAIL_PAD * 2
    d.btnIgnore = NUL:Button(body, {
        label = L["Ignore everywhere"], width = w, height = BTN_H, style = "accent", fit = false,
        tooltip = L["Ignores the selected players on every character: right away on this one, at their next login on the others."],
        onClick = function()
            if ui.picked then IgnoreAllChars:ConfirmEverywhere({ ui.picked }, "add") end
        end,
    })
    d.btnRemove = NUL:Button(body, {
        label = L["Remove everywhere"], width = w, height = BTN_H, style = "danger", fit = false,
        tooltip = L["Removes the selected players from every character's ignore list: right away on this one, at their next login on the others."],
        onClick = function()
            if ui.picked then IgnoreAllChars:ConfirmEverywhere({ ui.picked }, "del") end
        end,
    })
    d.btnImport = NUL:Button(body, {
        label = L["Import to NBK"], width = w, height = BTN_H, fit = false,
        onClick = function()
            if ui.picked then IgnoreAllChars:ImportRows({ ui.picked }) end
        end,
    })

    d.list = NUL:ScrollList(body, { rowHeight = CHAR_ROW_H, rowBuilder = charRowBuilder })
    d.list.container:SetPoint("TOPLEFT", 0, -DETAIL_TOP)
    d.list.container:SetPoint("BOTTOMRIGHT", 0, 0)
    return d
end

local function layoutDetailButtons(d, buttons, top)
    local prev
    for _, b in ipairs({ d.btnImport, d.btnRemove, d.btnIgnore }) do
        local show = buttons[b] == true
        b:SetShown(show)
        if show then
            b:ClearAllPoints()
            if prev then
                b:SetPoint("BOTTOMLEFT", prev, "TOPLEFT", 0, GAP)
            else
                b:SetPoint("BOTTOMLEFT", d.body, "BOTTOMLEFT", 0, 0)
            end
            prev = b
        end
    end
    local box = d.list.container
    box:ClearAllPoints()
    box:SetPoint("TOPLEFT", d.body, "TOPLEFT", 0, -top)
    if prev then
        box:SetPoint("BOTTOMRIGHT", prev, "TOPRIGHT", 0, 8)
    else
        box:SetPoint("BOTTOMRIGHT", d.body, "BOTTOMRIGHT", 0, 0)
    end
end

function IgnoreAllChars:_RefreshDetail()
    local d = ui.detail
    if not d then return end
    local L, t = NBK.L, NUL:GetTheme()
    local e = ui.picked
    d.body:SetShown(e ~= nil)
    d.empty:SetShown(e == nil)
    if not e then return end

    d.class:SetClass(e.class)
    d.name:ClearAllPoints()
    d.name:SetPoint("TOPLEFT", d.body, "TOPLEFT", e.class and 24 or 0, 0)
    d.name:SetPoint("RIGHT", d.body, "RIGHT", 0, 0)
    d.name:SetText(e.deleted and colored(t.colors.text.muted, NBK:DisplayName(e.name, e.realm))
                              or NBK:DisplayName(e.name, e.realm, classHex(e.class)))

    local withReason = false
    if e.deleted then
        d.info:SetText(deletedLine(e))
    elseif e.bl then
        d.info:SetText(colored(t.colors.accent.primary,
            ("%s: %s"):format(L["Blacklisted"], NBK:FormatDate(e.bl.addedAt))))
        d.reason:SetText(("%s: %s"):format(L["Reason"],
            (e.bl.reason and e.bl.reason ~= "") and NBK:ReasonText(e.bl.reason) or L["no reason logged"]))
        NUL.SetFontColor(d.reason, t.colors.text.primary)
        withReason = true
    else
        d.info:SetText(L["Not on the blacklist"])
        NUL.SetFontColor(d.info, t.colors.text.muted)
    end
    d.reason:SetShown(withReason)

    local shift = withReason and DETAIL_REASON_H or 0
    d.on:ClearAllPoints()
    d.on:SetPoint("TOPLEFT", d.body, "TOPLEFT", 0, -(42 + shift))
    d.on:SetPoint("RIGHT", d.body, "RIGHT", 0, 0)
    d.on:SetText(L["Ignored on: %d / %d"]:format(e.onCount, #ui.chars))

    layoutDetailButtons(d, {
        [d.btnIgnore] = not e.deleted,
        [d.btnRemove] = not e.deleted,
        [d.btnImport] = not e.deleted and not e.bl,
    }, DETAIL_TOP + shift)

    if ui.orderFor ~= e.key or #ui.order ~= #ui.chars then
        ui.order, ui.orderFor = detailOrder(e), e.key
    end
    local byKey, list = {}, {}
    for _, ch in ipairs(ui.chars) do byKey[ch.key] = ch end
    for _, key in ipairs(ui.order) do
        if byKey[key] then
            list[#list + 1] = byKey[key]
            byKey[key] = nil
        end
    end
    for _, ch in ipairs(ui.chars) do
        if byKey[ch.key] then list[#list + 1] = ch end
    end
    d.list:SetData(list)
end

function IgnoreAllChars:_Pick(key)
    if ui.pickedKey == key then return end
    ui.pickedKey = key
    ui.orderFor = nil
    ui.picked = nil
    for _, e in ipairs(ui.allRows) do
        if e.key == key then ui.picked = e; break end
    end
    if ui.list then ui.list:Refresh() end
    if ui.detail and ui.detail.list then ui.detail.list:ScrollToTop() end
    self:_RefreshDetail()
end

function IgnoreAllChars:_PlayerMenuItems(e)
    local L = NBK.L
    local bt = NBK:GetModule("BlacklistTab")
    local items = {}
    if not e.deleted then
        if e.bl then
            items[#items + 1] = { label = L["Edit blacklist entry"],
                                  onClick = function() if bt then bt:_ShowEditDialog(e.bl) end end }
        else
            items[#items + 1] = { label = L["Import to NBK"], onClick = function() IgnoreAllChars:ImportRows({ e }) end }
        end
        items[#items + 1] = { label = L["Ignore everywhere"],
                              onClick = function() IgnoreAllChars:ConfirmEverywhere({ e }, "add") end }
        items[#items + 1] = { label = L["Remove everywhere"],
                              onClick = function() IgnoreAllChars:ConfirmEverywhere({ e }, "del") end }
    end
    items[#items + 1] = { label = L["Copy name"],
                          onClick = function() if bt then bt.ShowCopyName(e.name, e.realm) end end }
    return items
end

function IgnoreAllChars:_ToolItems()
    local L = NBK.L
    return {
        { label = L["Copy list..."], onClick = function() IgnoreAllChars:ShowCopyDialog() end,
          tooltip = L["Adds the players ignored on one character to others."] },
        { label = L["Clean up..."], onClick = function() IgnoreAllChars:ShowCleanup() end,
          tooltip = L["Suggests players to take off the ignore lists."] },
        { separator = true },
        { label = L["Export..."], onClick = function() IgnoreAllChars:ShowExportDialog() end,
          tooltip = L["An ignore list as text, to keep or to share."] },
        { label = L["Import..."], onClick = function() IgnoreAllChars:ShowImportDialog() end,
          tooltip = L["Puts the players of an exported ignore list on your characters."] },
    }
end

function IgnoreAllChars:_BuildView(parent)
    local L, theme = NBK.L, NUL:GetTheme()
    local f = CreateFrame("Frame", nil, parent)
    f:SetAllPoints()
    ui.view = f

    ui.search = NUL:EditBox(f, {
        width = 260, height = 26,
        placeholder = L["Search name, realm, reason..."],
        clearButton = true, clearTooltip = L["Clear search"],
        onTextChanged = function() IgnoreAllChars:Refresh() end,
    })
    ui.search:SetPoint("TOPLEFT")

    ui.tools = NUL:MenuButton(f, {
        label = L["Tools"], width = 110, height = 26,
        items = function() return IgnoreAllChars:_ToolItems() end,
    })
    ui.tools:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)

    ui.count = NUL:CreateLabel(f, { text = "", color = theme.colors.text.muted, wrap = false })
    ui.count:SetPoint("RIGHT", ui.tools, "LEFT", -10, 0)

    ui.hint = NUL:CreateLabel(f, {
        text  = L["Click a player to see and change every character on the right."],
        size  = "sm",
        color = theme.colors.text.muted,
        wrap  = false,
    })
    ui.hint:SetPoint("TOPLEFT", ui.search, "BOTTOMLEFT", 2, -6)
    ui.hint:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    ui.hint:SetJustifyH("LEFT")
    local hintHover = CreateFrame("Frame", nil, f)
    hintHover:SetAllPoints(ui.hint)
    hintHover:EnableMouse(true)
    NUL:AttachTooltip(hintHover,
        L["Log in once on each character so the overview is complete. On the character you are logged in with a change happens right away, on the others at their next login."],
        { anchor = "BOTTOM" })

    ui.gone = CreateFrame("Frame", nil, f)
    ui.gone:SetHeight(22)
    ui.gone:SetPoint("TOPLEFT", ui.hint, "BOTTOMLEFT", -2, -6)
    ui.gone:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    ui.goneLabel = NUL:CreateLabel(ui.gone, { text = "", wrap = false })
    ui.goneLabel:SetPoint("LEFT", 0, 0)
    local cleanBtn = NUL:Button(ui.gone, {
        label = L["Clean up"], width = 110, height = 22,
        onClick = function() IgnoreAllChars:ShowCleanup("gone") end,
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

    local importBtn = NUL:Button(bar, {
        label = L["Import to NBK"], width = 130, height = 22,
        onClick = function() IgnoreAllChars:ImportRows(IgnoreAllChars:SelectedRows()) end,
    })
    importBtn:SetPoint("LEFT", removeBtn, "RIGHT", 6, 0)

    ui.selCount = NUL:CreateLabel(bar, { text = "", color = theme.colors.text.muted, wrap = false })
    ui.selCount:SetPoint("RIGHT", bar, "RIGHT", 0, 0)

    ui.detail = buildDetail(f)
    ui.detail:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -6)
    ui.detail:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)

    ui.header = buildListHeader(f)
    ui.header:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -6)
    ui.header:SetPoint("RIGHT", ui.detail, "LEFT", -PANE_GAP, 0)

    ui.list = NUL:ScrollList(f, { rowHeight = ROW_HEIGHT, rowBuilder = playerRowBuilder })
    ui.list.container:SetPoint("TOPLEFT", ui.header, "BOTTOMLEFT", 0, -2)
    ui.list.container:SetPoint("BOTTOMRIGHT", ui.detail, "BOTTOMLEFT", -PANE_GAP, 0)

    self:Refresh()
    return f
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
    for _, e in ipairs(ui.allRows) do present[e.key] = e end
    for key in pairs(self.selected) do
        if not present[key] then self.selected[key] = nil end
    end

    local filterText = ui.search and ui.search:GetText() or ""
    local filter = filterText:lower()
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

    local picked = ui.pickedKey and present[ui.pickedKey]
    local shown = false
    if picked then
        for _, e in ipairs(rows) do
            if e == picked then shown = true; break end
        end
    end
    if not shown then picked = rows[1] end
    ui.picked    = picked
    ui.pickedKey = picked and picked.key or nil

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
    ui.list:SetEmptyText(NBK:EmptyListText(filterText,
        L["No character has anyone on its ignore list yet."]))
    ui.list:SetData(rows)
    self:_UpdateBar()
    self:_RefreshDetail()
end
