local NBK = _G.NBK
if not NBK then return end

local NUL = LibStub("NerzorsUILib-1.0")

local IgnoreAllChars = NBK:GetModule("IgnoreAllChars")
if not IgnoreAllChars then return end

local ALL = "*"

local function firstSeen(row, charKey)
    local ig = NBK.db and NBK.db.ignore
    local all = ig and ig.chars or {}
    local best
    for key in pairs(row.on) do
        if (not charKey or key == charKey) and not row.gone[key] then
            local c = all[key]
            local rec = c and c.names and c.names[row.key]
            if rec and rec.first and (not best or rec.first < best) then best = rec.first end
        end
    end
    return best
end

function IgnoreAllChars:ExportEntries(charKey)
    local out = {}
    for _, row in ipairs(self:GetRows()) do
        if not row.deleted then
            local on = false
            if charKey == ALL then
                on = row.onCount > row.goneCount
            else
                on = row.on[charKey] == true and not row.gone[charKey]
            end
            if on then
                out[row.key] = { name = row.name, realm = row.realm,
                                 first = firstSeen(row, charKey ~= ALL and charKey or nil) }
            end
        end
    end
    return out
end

local function collapse(text)
    if type(text) ~= "string" then return "" end
    if text:find("||", 1, true) then text = NBK:UnescapeFromDisplay(text) end
    return text
end

function IgnoreAllChars:ParseIgnoreText(text)
    local parsed = NBK:ParseImport(collapse(text))
    if not parsed.magic then return { ok = false, error = "header", rows = {}, skipped = 0 } end
    if parsed.list ~= "ignore" then return { ok = false, error = "type", rows = {}, skipped = 0 } end
    local byKey = {}
    for _, row in ipairs(self:GetRows()) do byKey[row.key] = row end
    local rows, seen, skipped = {}, {}, parsed.skipped or 0
    for _, e in ipairs(parsed.entries) do
        local key = NBK:NormalizeKey(e.name, e.realm)
        if key and not seen[key] then
            seen[key] = true
            local row = self:AsRow(key, e.name, e.realm, byKey)

            if row.deleted or (row.deletedAt and row.onCount == 0) then
                skipped = skipped + 1
            else
                rows[#rows + 1] = { row = row, first = e.first or 0 }
            end
        end
    end
    table.sort(rows, function(a, b)
        local fa, fb = a.first > 0 and a.first or math.huge, b.first > 0 and b.first or math.huge
        if fa ~= fb then return fa < fb end
        return (a.row.name or ""):lower() < (b.row.name or ""):lower()
    end)
    local out = {}
    for i, r in ipairs(rows) do out[i] = r.row end
    return { ok = true, rows = out, skipped = skipped }
end

NBK:RegisterListType("ignore", {
    label  = "Ignore list",
    hidden = true,
    getEntries = function(opts)
        return IgnoreAllChars:ExportEntries((opts and opts.charKey) or IgnoreAllChars:CurrentCharKey())
    end,
    entryKey = function(e) return NBK:NormalizeKey(e.name, e.realm) end,
    hasEntry = function(e)
        local IS = NBK:GetModule("IgnoreSync")
        return IS ~= nil and IS:IsIgnored(e.name, e.realm)
    end,
    serializeRow = function(e) return { e.name, e.realm, tostring(e.first or 0) } end,
    parseRow = function(fields)
        local name, realm = fields[1], fields[2]
        if not name or name == "" or not realm or realm == "" then return nil end
        return { name = name, realm = realm, first = tonumber(fields[3]) or 0 }
    end,

    applyEntry = function(e)
        local IS = NBK:GetModule("IgnoreSync")
        if not IS or IS:IsIgnored(e.name, e.realm) then return "skipped" end
        return IS:Add(e.name, e.realm) and "added" or "skipped"
    end,
    countEntries = function()
        local n = 0
        for _ in pairs(IgnoreAllChars:ExportEntries(ALL)) do n = n + 1 end
        return n
    end,
    openImport = function(text) IgnoreAllChars:ShowImportDialog(text) end,
})

local ex = {}

local function refreshExport()
    local L = NBK.L
    local text, count = NBK:ExportString({ list = "ignore", charKey = ex.source })
    ex.box:SetText(NBK:EscapeForDisplay(text or ""))
    ex.count:SetText(L["%d players"]:format(count or 0))
end

local function buildExport()
    if ex.f then return ex.f end
    local L, theme = NBK.L, NUL:GetTheme()
    local f = NUL:Window({
        name   = "NBKIgnoreExportDialog",
        title  = L["Export ignore list"],
        width  = 560, height = 440,
        strata = "DIALOG",
    })
    ex.f = f
    local content = f.content

    local fromLabel = NUL:CreateLabel(content, { text = L["From:"], wrap = false, role = "field" })
    fromLabel:SetPoint("TOPLEFT", 0, -5)
    ex.from = NUL:Dropdown(content, {
        width = 260, height = 24,
        onSelect = function(key)
            ex.source = key
            refreshExport()
        end,
    })
    ex.from:SetPoint("LEFT", fromLabel, "RIGHT", 8, 0)
    ex.count = NUL:CreateLabel(content, { text = "", color = theme.colors.text.muted, wrap = false })
    ex.count:SetPoint("LEFT", ex.from, "RIGHT", 10, 0)

    local hint = NUL:CreateLabel(content, {
        text = L["Click the box below, press Ctrl+A, then Ctrl+C to copy."],
        size = "sm", color = theme.colors.text.muted, justifyH = "LEFT",
    })
    hint:SetPoint("TOPLEFT", 0, -34)
    hint:SetPoint("RIGHT", content, "RIGHT", 0, 0)

    ex.box = NUL:EditBox(content, { multiline = true, maxLetters = 0 })
    ex.box:ClearAllPoints()
    ex.box:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -8)
    ex.box:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 36)
    if ex.box.editBox and ex.box.editBox.SetMaxBytes then ex.box.editBox:SetMaxBytes(0) end

    local selectBtn = NUL:Button(content, {
        label = L["Select all"], height = 26, style = "accent",
        onClick = function()
            local eb = ex.box.editBox
            if eb then eb:SetFocus(); eb:HighlightText() end
        end,
    })
    selectBtn:SetPoint("BOTTOMLEFT", 0, 0)
    local closeBtn = NUL:Button(content, {
        label = L["Close"], height = 26, onClick = function() f:Hide() end,
    })
    closeBtn:SetPoint("BOTTOMRIGHT", 0, 0)
    return f
end

function IgnoreAllChars:ShowExportDialog(source)
    local L = NBK.L
    local f = buildExport()
    local opts = { { key = ALL, label = L["All characters"] } }
    for _, ch in ipairs(self:GetCharacters()) do
        opts[#opts + 1] = { key = ch.key, label = ("%s  (%d)"):format(IgnoreAllChars.CharLabel(ch), ch.count or 0) }
    end
    ex.from:SetOptions(opts)
    ex.source = source or self:CurrentCharKey()
    local known = false
    for _, o in ipairs(opts) do if o.key == ex.source then known = true end end
    if not known then ex.source = ALL end
    ex.from:SetValue(ex.source)
    refreshExport()
    f:Show()
end

local im = {}

local function reparse(text)
    local L, c = NBK.L, NUL:GetTheme().colors
    local d = im.d
    im.rows = {}
    if not text or text:match("^%s*$") then
        im.status:SetText(L["Paste an exported ignore list above."])
        NUL.SetFontColor(im.status, c.text.muted)
        d:SetTargets({}, nil)
        return
    end
    local p = IgnoreAllChars:ParseIgnoreText(text)
    if not p.ok then
        im.status:SetText(p.error == "type" and L["This text is not an ignore list."]
                                             or L["Invalid input - missing !NBK1! header."])
        NUL.SetFontColor(im.status, c.state.danger)
        d:SetTargets({}, nil)
        return
    end
    im.rows = p.rows
    local msg = L["%d players in the text"]:format(#p.rows)
    if p.skipped > 0 then msg = msg .. "  " .. L["Skipped: %d"]:format(p.skipped) end
    im.status:SetText(msg)
    NUL.SetFontColor(im.status, c.text.primary)

    d:SetTargets(IgnoreAllChars:PlanTargets(p.rows), nil, { [IgnoreAllChars:CurrentCharKey()] = true })
end

local function buildImport()
    if im.d then return im.d end
    local L = NBK.L
    im.d = IgnoreAllChars:_TargetDialog({
        name = "NBKIgnoreImportDialog", title = L["Import ignore list"],
        height = 500, buttonKey = "Import (%d)",
        buildTop = function(d, content)
            local theme = NUL:GetTheme()
            im.box = NUL:EditBox(content, {
                multiline = true, maxLetters = 0,
                onTextChanged = function(text) if im.ready then reparse(text) end end,
            })
            im.box:ClearAllPoints()
            im.box:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            im.box:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
            im.box:SetHeight(110)
            if im.box.editBox and im.box.editBox.SetMaxBytes then im.box.editBox:SetMaxBytes(0) end
            im.status = NUL:CreateLabel(content, { text = "", justifyH = "LEFT", wrap = false })
            im.status:SetPoint("TOPLEFT", im.box, "BOTTOMLEFT", 0, -8)
            im.status:SetPoint("RIGHT", content, "RIGHT", 0, 0)
            local hint = NUL:CreateLabel(content, {
                text = L["Adds the players in the text to the ticked characters. Nothing is removed there. On this character it happens right away, on the others at their next login."],
                size = "sm", color = theme.colors.text.muted, justifyH = "LEFT",
            })
            hint:SetPoint("TOPLEFT", im.status, "BOTTOMLEFT", 0, -6)
            hint:SetPoint("RIGHT", content, "RIGHT", 0, 0)
            return hint
        end,
        onApply = function(d)
            local L2 = NBK.L
            local done, planned, noRoom = IgnoreAllChars:ApplyTargets(d.targets, d.ticked)
            NBK:Print(L2["Import - ignored here: %d, planned for other characters: %d"]:format(done, planned))
            if noRoom > 0 then NBK:Print(L2["Did not fit (ignore list full): %d"]:format(noRoom)) end
            local core = NBK:GetModule("IgnoreManager")
            if core and core.RefreshTab then core:RefreshTab() else IgnoreAllChars:Refresh() end
        end,
    })
    im.ready = true
    return im.d
end

function IgnoreAllChars:ShowImportDialog(text)
    local d = buildImport()
    d:ClearTicks()
    im.box:SetText(text or "")
    reparse(text or "")
    d.list:ScrollToTop()
    d.f:Show()
end
