local NBK = _G.NBK
if not NBK then return end

local NUL = LibStub("NerzorsUILib-1.0")

local IgnoreAllChars = NBK:GetModule("IgnoreAllChars")
if not IgnoreAllChars then return end

local CAP         = 50
local ALMOST_FULL = 45
local MONTH       = 30 * 86400
local MONTHS      = { 3, 6, 12 }
local DEFAULT_MONTHS = 6
local ROW_H       = 26

local ui = { group = "stale", months = DEFAULT_MONTHS, ticked = {} }

local function snapshots()
    local ig = NBK.db and NBK.db.ignore
    return ig and ig.chars or {}
end

local function ignoredSince(row, charKey)
    local all, best, before = snapshots(), nil, false
    for key in pairs(row.on) do
        if not charKey or key == charKey then
            local c = all[key]
            local rec = c and c.names and c.names[row.key]
            local t = rec and rec.first
            if t then
                local b = c.firstScanAt ~= nil and t <= c.firstScanAt
                if not best or t < best then best, before = t, b end
            end
        end
    end
    return best, before
end

local function recentsLastSeen()
    local out = {}
    local R = NBK:GetModule("Recents")
    if not (R and R.GetEntries) then return out end
    for _, e in ipairs(R:GetEntries() or {}) do
        if e.name and e.lastSeen then

            local key = NBK:NormalizeKey(e.name, e.realm)
            if key and (not out[key] or out[key] < e.lastSeen) then out[key] = e.lastSeen end
        end
    end
    return out
end

local function lastSeen(row, recents)
    local t
    local function take(v) if v and (not t or v > t) then t = v end end
    if row.bl then
        take(row.bl.lastSeen)
        take(row.bl.addedAt)
    end
    take(recents[row.key])
    return t
end

local function usedOn(ch)
    local IS = NBK:GetModule("IgnoreSync")
    if ch.current and IS then return #IS:GetIgnoreList() end
    return IgnoreAllChars:PlannedUse(ch.key, ch.count)
end

function IgnoreAllChars:PlanCleanup(months, charKey, characters, rows)
    characters = characters or self:GetCharacters()
    rows = rows or self:GetRows(characters)
    local now = time()
    local cutoff = now - (months or DEFAULT_MONTHS) * MONTH
    local recents = recentsLastSeen()
    local p = { gone = {}, stale = {}, full = {}, months = months, charKey = charKey }

    for _, row in ipairs(rows) do
        if row.goneCount > 0 then p.gone[#p.gone + 1] = row end
        local onIt = not charKey or (row.on[charKey] and not row.gone[charKey])
        if onIt and not row.deleted and not (row.bl and row.bl.pinned) then
            local since, before = ignoredSince(row, charKey)
            local seen = lastSeen(row, recents)
            if since and since < cutoff and not (seen and seen >= cutoff) then
                p.stale[#p.stale + 1] = { row = row, since = since, before = before,
                                          seen = seen, onBlacklist = row.bl ~= nil }
            end
        end
    end
    table.sort(p.stale, function(a, b)
        if a.since ~= b.since then return a.since < b.since end
        return (a.row.name or ""):lower() < (b.row.name or ""):lower()
    end)

    for _, ch in ipairs(characters) do
        local used = usedOn(ch)
        if used >= ALMOST_FULL then p.full[#p.full + 1] = { char = ch, used = used } end
    end
    return p
end

function IgnoreAllChars:RemoveOnChar(charKey, rows)
    local IS   = NBK:GetModule("IgnoreSync")
    local core = NBK:GetModule("IgnoreManager")
    local removed, planned = 0, 0
    local current = charKey == self:CurrentCharKey()
    for _, row in ipairs(rows) do
        if current then
            if IS and IS:IsIgnored(row.name, row.realm) then

                if row.bl then NBK:UpdateEntry(row.name, row.realm, { ignoredByNBK = false }) end
                if core then core._removing[row.key] = true end
                if IS:Remove(row.name, row.realm) then removed = removed + 1 end
            end
        elseif row.on[charKey] then
            self:Plan(charKey, row, "del")
            planned = planned + 1
        else
            self:Unplan(charKey, row.key)
        end
    end
    return removed, planned
end

local function colored(color, text) return ("|cff%s%s|r"):format(NUL.ToHex(color), text) end
local function classHex(class) return class and NBK:GetClassHex(class) or "ffffff" end

local function charLabel(ch)
    return ("|cff%s%s|r"):format(classHex(ch.class), ch.name or "?") .. NBK:RealmSuffix(ch.realm)
end

local function charByKey(key)
    for _, ch in ipairs(ui.chars or {}) do
        if ch.key == key then return ch end
    end
end

local function sinceText(e)
    local d = NBK:FormatDate(e.since)
    return e.before and NBK.L["before %s"]:format(d) or d
end

local function entries()
    local p = ui.plan
    if ui.group == "gone" then return p.gone end
    if ui.group == "full" then return p.full end
    return p.stale
end

local function keyOf(e)
    if ui.group == "gone" then return e.key end
    if ui.group == "stale" then return e.row.key end
end

local function tickedEntries()
    local out = {}
    if ui.group == "full" then return out end
    for _, e in ipairs(entries()) do
        if ui.ticked[keyOf(e)] then out[#out + 1] = e end
    end
    return out
end

local function blacklistCount(list)
    local n, pinned = 0, 0
    for _, e in ipairs(list) do
        local row = e.row or e
        local counts = ui.group ~= "gone" or row.deleted
        if row.bl and counts then
            n = n + 1
            if row.bl.pinned then pinned = pinned + 1 end
        end
    end
    return n, pinned
end

local updateAll

local function rowTooltip(e)
    local L, c = NBK.L, NUL:GetTheme().colors
    local row = e.row or e
    local lines = {}
    local where = {}
    for _, ch in ipairs(ui.chars) do
        if row.on[ch.key] then where[#where + 1] = ch.name or "?" end
    end
    lines[#lines + 1] = L["Ignored on: %d / %d"]:format(row.onCount, #ui.chars)
    if #where > 0 then lines[#lines + 1] = colored(c.text.muted, table.concat(where, ", ")) end
    if ui.group == "gone" then
        lines[#lines + 1] = colored(c.state.warning,
            L["No longer exists (reported by the game on %s)"]:format(NBK:FormatDate(row.deletedAt)))
    else
        lines[#lines + 1] = ("%s: %s"):format(L["Ignored since"], sinceText(e))
        lines[#lines + 1] = e.seen and L["Last seen by NBK: %s"]:format(NBK:FormatDate(e.seen))
                                    or L["Never seen by NBK"]
    end
    if row.bl then
        lines[#lines + 1] = colored(c.accent.primary, ("%s: %s"):format(L["Blacklisted"], NBK:FormatDate(row.bl.addedAt)))
    end
    return table.concat(lines, "\n")
end

local function rowBuilder(row)
    local check = NUL:Checkbox(row, { size = "small" })
    check:SetPoint("LEFT", row, "LEFT", 6, 0)
    local name = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
    name:SetPoint("LEFT", row, "LEFT", 30, 0)
    name:SetWidth(190)
    local info = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
    info:SetPoint("LEFT", row, "LEFT", 226, 0)
    info:SetWidth(150)
    local mark = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
    mark:SetPoint("LEFT", row, "LEFT", 382, 0)
    mark:SetPoint("RIGHT", row, "RIGHT", -6, 0)

    row:HookScript("OnEnter", function(self)
        local e = self._entry
        if not e then return end
        if ui.group == "full" then
            NUL:ShowTooltip(self, NBK.L["Show its players not seen for a long time"], { anchor = "RIGHT" })
        else
            local r = e.row or e
            NUL:ShowTooltipMultiline(self, { title = NBK:DisplayName(r.name, r.realm, classHex(r.class)),
                                             body = rowTooltip(e), anchor = "RIGHT" })
        end
    end)
    row:HookScript("OnLeave", function() NUL:HideTooltip() end)
    row:SetScript("OnClick", function(self)
        local e = self._entry
        if not e then return end
        if ui.group == "full" then
            ui.charKey, ui.group = e.char.key, "stale"
            ui.ticked = {}
            updateAll(true)
            return
        end
        local k = keyOf(e)
        ui.ticked[k] = not ui.ticked[k] or nil
        updateAll()
    end)

    return function(r, e)
        local L, c = NBK.L, NUL:GetTheme().colors
        if ui.group == "full" then
            check:Hide()
            name:SetText(charLabel(e.char))
            info:SetText(("%d / %d"):format(e.used, CAP))
            NUL.SetFontColor(info, c.state.warning)
            mark:SetText(colored(c.accent.primary, L["Show players"]))
            return
        end
        check:Show()
        local rw = e.row or e
        name:SetText(NBK:DisplayName(rw.name, rw.realm, classHex(rw.class)))
        if ui.group == "gone" then
            info:SetText(L["Reported on %s"]:format(NBK:FormatDate(rw.deletedAt)))
        else
            info:SetText(L["Ignored since %s"]:format(sinceText(e)))
        end
        NUL.SetFontColor(info, c.text.muted)
        local parts = { colored(c.text.muted, ("%d / %d"):format(rw.onCount, #ui.chars)) }
        if rw.bl then parts[#parts + 1] = colored(c.accent.primary, L["Blacklist"]) end
        mark:SetText(table.concat(parts, "   "))
        check:SetChecked(ui.ticked[keyOf(e)] == true)
        check:SetOnChange(function()
            local k = keyOf(e)
            ui.ticked[k] = not ui.ticked[k] or nil
            updateAll()
        end)
    end
end

local GROUPS = { "gone", "stale", "full" }

local function hintText()
    local L = NBK.L
    if ui.group == "gone" then
        return L["These players no longer exist. Other characters still have them in their saved lists; the game removes them there at the next login. Remove them from the overview now?"]
    elseif ui.group == "full" then
        return L["Characters whose ignore list is almost full. Click one to see its players not seen for a long time."]
    elseif ui.charKey then
        local ch = charByKey(ui.charKey)
        return L["Players on %s not seen for a long time. Removing only takes them off this character's list."]
            :format(ch and charLabel(ch) or ui.charKey)
    end
    return L["Players ignored for a long time whom NBK hasn't seen since. Removing takes them off every character's list: here right away, on the others at their next login."]
end

local function emptyText()
    local L = NBK.L
    if ui.group == "full" then return L["No character's ignore list is almost full."] end
    return L["Nothing to clean up here."]
end

updateAll = function(reread)
    local L = NBK.L
    if reread then
        ui.chars = IgnoreAllChars:GetCharacters()
        ui.rows  = IgnoreAllChars:GetRows(ui.chars)
        ui.plan  = IgnoreAllChars:PlanCleanup(ui.months, ui.charKey, ui.chars, ui.rows)

        ui.allPlan = ui.charKey and IgnoreAllChars:PlanCleanup(ui.months, nil, ui.chars, ui.rows) or ui.plan
        if ui.group == "gone" and not next(ui.ticked) then
            for _, row in ipairs(ui.plan.gone) do ui.ticked[row.key] = true end
        end
    end
    local counts = { gone = #ui.allPlan.gone, stale = #ui.allPlan.stale, full = #ui.allPlan.full }
    local labels = {
        gone  = L["No longer exist (%d)"],
        stale = L["Not seen for a long time (%d)"],
        full  = L["List almost full (%d)"],
    }
    for _, g in ipairs(GROUPS) do
        ui.pills[g]:SetLabel(labels[g]:format(counts[g]))
        ui.pills[g]:SetSelected(ui.group == g)
    end

    ui.hint:SetText(hintText())
    local stale = ui.group == "stale"
    ui.monthsLabel:SetShown(stale)
    ui.monthsDD:SetShown(stale)
    ui.showAll:SetShown(stale and ui.charKey ~= nil)

    local list = entries()
    ui.list:SetEmptyText(emptyText())
    ui.list:SetData(list)

    local ticked = tickedEntries()
    local isFull = ui.group == "full"
    ui.selAll:SetShown(not isFull)
    ui.selCount:SetShown(not isFull)
    ui.selCount:SetText(L["%d selected"]:format(#ticked))
    local all = #list > 0
    for _, e in ipairs(list) do
        if not ui.ticked[keyOf(e)] then all = false; break end
    end
    ui.selAll:SetLabel(all and L["Select none"] or L["Select all"])

    local bl, pinned = blacklistCount(ticked)
    local askBL = not isFull and bl > 0
    if ui.alsoBL._for ~= ui.group then ui.alsoBL:SetChecked(false); ui.alsoBL._for = ui.group end
    ui.alsoBL:SetLabel(NBK:AlsoFromBlacklistLabel(bl))
    ui.alsoBL:SetShown(askBL)
    ui.pinned:SetText(L["Pinned among them: %d"]:format(pinned))
    ui.pinned:SetShown(askBL and pinned > 0)

    ui.cleanBtn:SetShown(ui.group == "gone")
    ui.removeBtn:SetShown(stale)
    ui.cleanBtn:SetLabel(L["Clean up (%d)"]:format(#ticked))
    ui.removeBtn:SetLabel(L["Remove (%d)"]:format(#ticked))
    ui.cleanBtn:SetEnabled(#ticked > 0)
    ui.removeBtn:SetEnabled(#ticked > 0)
end

local function setGroup(g)
    if ui.group == g and not ui.charKey then return end
    ui.group, ui.charKey, ui.ticked = g, nil, {}
    updateAll(true)
    ui.list:ScrollToTop()
end

local applyNow

local function apply()
    if NBK.RunAsCleanup then
        NBK:RunAsCleanup("ignoreTool", applyNow)
    else
        applyNow()
    end
end

applyNow = function()
    local ticked = tickedEntries()
    if #ticked == 0 then return end
    local also = ui.alsoBL:IsShown() and ui.alsoBL:GetChecked()
    ui.f:Hide()
    if ui.group == "gone" then
        IgnoreAllChars:ForgetDeleted(ticked, also)
        return
    end
    local rows = {}
    for _, e in ipairs(ticked) do rows[#rows + 1] = e.row end
    if not ui.charKey then

        IgnoreAllChars:ApplyEverywhere(IgnoreAllChars:PlanEverywhere(rows, "del"), also)
        return
    end
    local L = NBK.L
    local removed, planned = IgnoreAllChars:RemoveOnChar(ui.charKey, rows)
    local fromBlacklist = 0
    if also then
        for _, row in ipairs(rows) do
            if row.bl and not row.bl.pinned then
                NBK:UpdateEntry(row.name, row.realm, { ignoredByNBK = false })
                if NBK:RemovePlayer(row.name, row.realm) then fromBlacklist = fromBlacklist + 1 end
            end
        end
    end
    NBK:Print(L["Clean up - removed here: %d, planned for other characters: %d"]:format(removed, planned))
    if fromBlacklist > 0 then
        NBK:Print(L["Removed from the blacklist: %d"]:format(fromBlacklist))
        local lw = NBK:GetModule("ListWindow")
        if lw and lw.Refresh then lw:Refresh() end
    end
    local core = NBK:GetModule("IgnoreManager")
    if core and core.RefreshTab then core:RefreshTab() else IgnoreAllChars:Refresh() end
end

local function build()
    if ui.f then return ui.f end
    local L, theme = NBK.L, NUL:GetTheme()

    local f = NUL:Window({
        name   = "NBKIgnoreCleanupDialog",
        title  = L["Clean up"],
        width  = 600, height = 460,
        strata = "DIALOG",
    })
    ui.f = f

    ui.pills = {}
    local prev
    for _, g in ipairs(GROUPS) do
        local pill = NUL:Pill(f.content, { label = g, onClick = function() setGroup(g) end })
        pill:SetHeight(22)
        if prev then pill:SetPoint("LEFT", prev, "RIGHT", 6, 0) else pill:SetPoint("TOPLEFT", 0, 0) end
        ui.pills[g], prev = pill, pill
    end

    ui.hint = NUL:CreateLabel(f.content, {
        text = "", size = "sm", color = theme.colors.text.muted, justifyH = "LEFT",
    })
    ui.hint:SetPoint("TOPLEFT", 0, -32)
    ui.hint:SetPoint("RIGHT", f.content, "RIGHT", 0, 0)

    local opts = {}
    for _, m in ipairs(MONTHS) do opts[#opts + 1] = { key = m, label = L["%d months"]:format(m) } end
    ui.monthsLabel = NUL:CreateLabel(f.content, { text = L["Not seen for:"], wrap = false })
    ui.monthsLabel:SetPoint("TOPLEFT", ui.hint, "BOTTOMLEFT", 0, -12)
    ui.monthsDD = NUL:Dropdown(f.content, {
        width = 130, height = 24, options = opts, value = ui.months,
        onSelect = function(key)
            ui.months, ui.ticked = key, {}
            updateAll(true)
        end,
    })
    ui.monthsDD:SetPoint("LEFT", ui.monthsLabel, "RIGHT", 8, 0)
    ui.showAll = NUL:Button(f.content, {
        label = L["Show all characters"], width = 150, height = 24,
        onClick = function()
            ui.charKey, ui.ticked = nil, {}
            updateAll(true)
        end,
    })
    ui.showAll:SetPoint("LEFT", ui.monthsDD, "RIGHT", 10, 0)

    ui.removeBtn = NUL:Button(f.content, {
        label = L["Remove (%d)"]:format(0), width = 130, height = 26, style = "danger", onClick = apply,
    })
    ui.removeBtn:SetPoint("BOTTOMRIGHT", 0, 0)
    ui.cleanBtn = NUL:Button(f.content, {
        label = L["Clean up (%d)"]:format(0), width = 130, height = 26, style = "primary", onClick = apply,
    })
    ui.cleanBtn:SetPoint("BOTTOMRIGHT", 0, 0)
    local cancel = NUL:Button(f.content, {
        label = L["Cancel"], width = 110, height = 26, onClick = function() f:Hide() end,
    })
    cancel:SetPoint("RIGHT", ui.removeBtn, "LEFT", -6, 0)

    ui.selAll = NUL:Button(f.content, {
        label = L["Select all"], width = 110, height = 26,
        onClick = function()
            local list, all = entries(), true
            for _, e in ipairs(list) do
                if not ui.ticked[keyOf(e)] then all = false; break end
            end
            for _, e in ipairs(list) do ui.ticked[keyOf(e)] = (not all) or nil end
            updateAll()
        end,
    })
    ui.selAll:SetPoint("BOTTOMLEFT", 0, 0)
    ui.selCount = NUL:CreateLabel(f.content, { text = "", color = theme.colors.text.muted, wrap = false })
    ui.selCount:SetPoint("LEFT", ui.selAll, "RIGHT", 10, 0)

    ui.alsoBL = NUL:Checkbox(f.content, { label = "" })
    ui.alsoBL:SetPoint("BOTTOMLEFT", ui.selAll, "TOPLEFT", 0, 24)
    ui.alsoBL:SetWidth(400)
    ui.pinned = NUL:CreateLabel(f.content, {
        text = "", size = "sm", justifyH = "LEFT", color = theme.colors.text.muted,
    })
    ui.pinned:SetPoint("TOPLEFT", ui.alsoBL, "BOTTOMLEFT", 24, -2)

    ui.list = NUL:ScrollList(f.content, { rowHeight = ROW_H, rowBuilder = rowBuilder })
    ui.list.container:SetPoint("TOPLEFT", ui.monthsLabel, "BOTTOMLEFT", 0, -14)
    ui.list.container:SetPoint("BOTTOMRIGHT", ui.removeBtn, "TOPRIGHT", 0, 62)

    f:HookScript("OnShow", function()

        if C_Timer and C_Timer.After then
            C_Timer.After(0, function() if f:IsShown() then updateAll() end end)
        end
    end)
    f:HookScript("OnHide", function() NUL:HideTooltip() end)
    return f
end

function IgnoreAllChars:ShowCleanup(group)
    local f = build()
    ui.chars = self:GetCharacters()
    ui.rows  = self:GetRows(ui.chars)
    local p = self:PlanCleanup(ui.months, nil, ui.chars, ui.rows)
    ui.group = group or ((#p.gone > 0) and "gone" or "stale")
    ui.charKey, ui.ticked = nil, {}
    updateAll(true)
    ui.list:ScrollToTop()
    f:Show()
end
