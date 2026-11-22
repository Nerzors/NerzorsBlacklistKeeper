local NBK = _G.NBK
if not NBK then return end

local function rekeyEntries(db)
    if type(db) ~= "table" or type(db.entries) ~= "table" then return end
    local out = {}
    for oldKey, e in pairs(db.entries) do
        local key, _, realm
        if type(e) == "table" and type(e.name) == "string" then
            key, _, realm = NBK:NormalizeKey(e.name, e.realm or "")
        end
        if not key then
            out[oldKey] = e
        else
            e.realm = realm
            local other = out[key]
            if not other then
                out[key] = e
            else
                local newer, older = e, other
                if (other.addedAt or 0) > (e.addedAt or 0) then newer, older = other, e end
                local a, b = newer.notes or "", older.notes or ""
                if b ~= "" and b ~= a then
                    newer.notes = (a ~= "") and (a .. " / " .. b) or b
                end
                out[key] = newer
            end
        end
    end
    db.entries = out
end

NBK:RegisterAddonDB({
    addonName = "NerzorsBlacklistKeeper_RememberMe",
    key       = "RememberMe",
    svName    = "NerzorsBlacklistKeeperRememberMeDB",

    version   = 2,
    migrate   = function(db, fromVer)
        if (fromVer or 1) < 2 then rekeyEntries(db) end
    end,
    defaults  = {
        settings = {
            showTooltip   = true,
            promptOnMplus = true,

            promptOnLeave       = false,
            promptOnMemberLeave = false,
            promptInRaid        = false,
            defaultRating = 4,
        },
        entries = {},
    },
})

local RememberMe = NBK:RegisterModule("RememberMe")

RememberMe.HAS_MPLUS = (NBK.IsRetail and NBK:IsRetail() or false)
    and type(C_ChallengeMode) == "table"

local function formatDate(ts)
    return NBK:FormatDate(ts)
end

local function normalizeKey(name, realm)
    return (NBK:NormalizeKey(name, realm))
end

local function splitNameRealm(input)
    if type(input) ~= "string" then return nil end
    input = (strtrim(input):gsub("%s+", " "))
    if input == "" then return nil end
    local n, r = strsplit("-", input, 2)
    n = n and strtrim(n) or ""
    if n == "" then return nil end
    if r then r = strtrim(r) end
    if r == "" then r = nil end
    return n, r
end

local function db()
    return NBK:GetAddonDB("RememberMe")
end

local function settings()
    local d = db()
    return (d and d.settings) or { showTooltip = true, promptOnMplus = true, defaultRating = 4 }
end

local function entriesTable()
    local d = db()
    if not d then return {} end
    if type(d.entries) ~= "table" then d.entries = {} end
    return d.entries
end

function RememberMe:GetEntries() return entriesTable() end

function RememberMe:CountEntries()
    local n = 0
    for _ in pairs(entriesTable()) do n = n + 1 end
    return n
end

function RememberMe:GetEntry(name, realm)
    local key = normalizeKey(name, realm)
    if not key then return nil end
    return entriesTable()[key]
end

function RememberMe:HasEntry(name, realm)
    return self:GetEntry(name, realm) ~= nil
end

local function promptBlacklistConflict(name, realm)
    local NUL = LibStub("NerzorsUILib-1.0")
    local L   = NBK.L
    if not NBK:IsBlacklisted(name, realm) then return end
    NUL:Confirm({
        text = L["%s is on the Blacklist. Remove from Blacklist?"]:format(NBK:DisplayName(name, realm)),
        onAccept = function()
            NBK:RemovePlayer(name, realm)
            local lw = NBK:GetModule("ListWindow")
            if lw and lw.Refresh then lw:Refresh() end
        end,
    })
end

local function promptRememberMeConflict(name, realm)
    local NUL = LibStub("NerzorsUILib-1.0")
    local L   = NBK.L
    if not RememberMe:HasEntry(name, realm) then return end
    NUL:Confirm({
        text = L["%s is in Remember Me. Remove from Remember Me?"]:format(NBK:DisplayName(name, realm)),
        onAccept = function() RememberMe:RemoveEntry(name, realm) end,
    })
end

function RememberMe:AddEntry(name, realm, fields)
    fields = fields or {}

    if name and name:find("-", 1, true) and not realm then
        local n, r = splitNameRealm(name)
        if not n then return nil, "invalid name" end
        name, realm = n, r
    end

    if type(name) == "string" then name = (strtrim(name):gsub("%s+", " ")) end
    if not name or name == "" then return nil, "name required" end

    local key, cleanName, cleanRealm = NBK:NormalizeKey(name, realm)
    if not key then return nil, "invalid name/realm" end
    name, realm = cleanName, cleanRealm

    local list = entriesTable()
    local entry = list[key]
    local now = time()

    if not entry then
        local s = settings()
        entry = {
            name       = name,
            realm      = realm,
            class      = fields.class,
            classColor = fields.class and NBK:GetClassHex(fields.class) or nil,
            rating     = tonumber(fields.rating) or s.defaultRating or 4,
            notes      = fields.notes or "",
            role       = fields.role,
            addedAt    = now,
            zone       = fields.zone or (GetRealZoneText() or GetZoneText() or ""),
            addedBy    = NBK:PlayerFullName() or "?",
            run        = fields.run or (NBK.CurrentRun and NBK:CurrentRun()) or nil,
        }
        list[key] = entry

        promptBlacklistConflict(name, realm)
        return entry, "added"
    end

    if fields.rating ~= nil then entry.rating = tonumber(fields.rating) or entry.rating end
    if fields.notes  ~= nil then entry.notes  = fields.notes end
    if fields.zone   ~= nil then entry.zone   = fields.zone end

    if fields.run    ~= nil then entry.run    = fields.run end
    if fields.class  ~= nil then
        entry.class      = fields.class
        entry.classColor = NBK:GetClassHex(fields.class)
    end
    return entry, "updated"
end

function RememberMe:UpdateEntry(name, realm, fields)
    local entry = self:GetEntry(name, realm)
    if not entry then return false, "no such entry" end
    fields = fields or {}
    if fields.rating ~= nil then entry.rating = tonumber(fields.rating) or entry.rating end
    if fields.notes  ~= nil then entry.notes  = fields.notes end
    if fields.zone   ~= nil then entry.zone   = fields.zone end
    if fields.role   ~= nil then entry.role   = fields.role end

    return true
end

function RememberMe:RemoveEntry(name, realm)
    local key = normalizeKey(name, realm)
    if not key then return false end
    local list = entriesTable()
    if not list[key] then return false end
    list[key] = nil
    return true
end

function RememberMe:Clear()
    local list = entriesTable()
    local n = 0
    for k in pairs(list) do list[k] = nil; n = n + 1 end
    return n
end

if NBK.RegisterListType then
    NBK:RegisterListType("rememberme", {
        label = "Remember Me",

        getEntries = function() return entriesTable() end,

        entryKey = function(entry)
            return normalizeKey(entry.name, entry.realm)
        end,

        hasEntry = function(entry)
            local key = normalizeKey(entry.name, entry.realm)
            return key ~= nil and entriesTable()[key] ~= nil
        end,

        serializeRow = function(e)
            return {
                e.name,
                e.realm,
                e.class or "",
                tostring(e.rating or 4),
                e.notes or "",
                e.role or "",
                tostring(e.addedAt or 0),
                e.zone or "",
                e.addedBy or "",
                e.run or "",
            }
        end,

        parseRow = function(fields)
            if #fields < 3 then return nil end
            local entry = {
                name    = fields[1],
                realm   = fields[2],
                class   = (fields[3] ~= "" and fields[3]) or nil,
                rating  = tonumber(fields[4]) or 4,
                notes   = fields[5] or "",
                role    = (fields[6] ~= "" and fields[6]) or nil,
                addedAt = tonumber(fields[7]) or time(),
                zone    = fields[8] or "",
                addedBy = fields[9] or "",
                run     = (fields[10] ~= nil and fields[10] ~= "") and fields[10] or nil,
            }
            entry.classColor = entry.class and NBK:GetClassHex(entry.class) or nil
            return entry
        end,

        beginApply = function(mode)
            if mode == "replace" then return RememberMe:Clear() end
            return 0
        end,

        applyEntry = function(entry, mode)
            local list = entriesTable()
            local key, _, realm = NBK:NormalizeKey(entry.name, entry.realm)
            if not key then return "skipped" end
            entry.realm = realm
            if list[key] then
                if mode == "overwrite" then
                    list[key] = entry
                    return "overwritten"
                end
                return "skipped"
            end
            list[key] = entry
            return "added"
        end,

        countEntries = function() return RememberMe:CountEntries() end,
    })
end

local function createStarRating(parent, size, readOnly)
    size = size or 18
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(size * 5 + 4 * 2, size)

    f._value     = 0
    f._stars     = {}
    f._readOnly  = readOnly and true or false

    for i = 1, 5 do
        local star = CreateFrame("Button", nil, f)
        star:SetSize(size, size)
        star:SetPoint("LEFT", f, "LEFT", (i - 1) * (size + 1), 0)

        local tex = star:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints()
        tex:SetTexture(NBK:IconPath('ratings\\star_empty.png'))
        star._tex = tex

        if not f._readOnly then
            star:SetScript("OnClick", function() f:SetValue(i) end)
            star:SetScript("OnEnter", function()

                for j, s in ipairs(f._stars) do
                    if j <= i then

                        s._tex:SetTexture(NBK:IconPath('ratings\\star.png'))
                    else

                        s._tex:SetTexture(NBK:IconPath('ratings\\star_empty.png'))
                    end
                end
            end)
            star:SetScript("OnLeave", function() f:_paint() end)
        end

        f._stars[i] = star
    end

    function f:_paint()
        local n = self._value or 0
        for i, s in ipairs(self._stars) do
            if i <= n then

                s._tex:SetTexture(NBK:IconPath('ratings\\star.png'))
            else

               s._tex:SetTexture(NBK:IconPath('ratings\\star_empty.png'))
            end
        end
    end

    function f:SetValue(n)
        n = tonumber(n) or 0
        n = math.max(0, math.min(5, n))
        local changed = self._value ~= n
        self._value = n
        self:_paint()
        if changed and self._onChange then self._onChange(n) end
    end

    function f:GetValue() return self._value end
    function f:SetOnChange(cb) self._onChange = cb end

    f:SetValue(0)
    return f
end

local function ratingString(n)
    n = tonumber(n) or 0
    n = math.max(0, math.min(5, n))

    local star      = "|T" .. NBK:IconPath('ratings\\star.png') .. ":14:14:0:0|t"
    local starEmpty = "|T" .. NBK:IconPath('ratings\\star_empty.png') .. ":14:14:0:0|t"

    return string.rep(star, n) .. string.rep(starEmpty, 5 - n)
end

local function starIcon(size)
    size = size or 12
    return ("|T%s:%d:%d:0:0|t"):format(NBK:IconPath('ratings\\star.png'), size, size)
end

local BRAND = "|cff9b59b6NBK|r"
local GREEN = "|cff5cb85c"
local DIM   = "|cff888c99"

local function onTooltipSetUnit(tooltip)
    if tooltip ~= GameTooltip then return end
    local s = settings()
    if s.showTooltip == false then return end

    if InCombatLockdown() then return end

    if not UnitExists("mouseover") then return end
    if not UnitIsPlayer("mouseover") then return end

    local name, realm = NBK:UnitPlayer("mouseover")
    if not name then return end
    realm = realm or GetNormalizedRealmName()

    local okBL, isBL = pcall(NBK.IsBlacklisted, NBK, name, realm)
    if not okBL then return end
    if isBL then return end

    local okRM, entry = pcall(RememberMe.GetEntry, RememberMe, name, realm)
    if not okRM or not entry then return end

    local L = NBK.L
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(
        BRAND .. " " .. GREEN .. (L["Remembered"] or "Remembered") .. "|r",
        ratingString(entry.rating),
        1, 1, 1, 1, 1, 1)

    if entry.notes and entry.notes ~= "" then
        tooltip:AddLine(DIM .. (L["Notes"] or "Notes") .. ":|r " .. entry.notes,
            0.85, 0.95, 0.85, true)
    end
    if entry.zone and entry.zone ~= "" then
        tooltip:AddLine(DIM .. (L["Added in"] or "Added in") .. ":|r " .. entry.zone,
            0.75, 0.8, 0.75, true)
    end
    if type(entry.run) == "string" and entry.run ~= "" then
        tooltip:AddLine(DIM .. (L["Run"] or "Run") .. ":|r " .. entry.run,
            0.75, 0.8, 0.75, true)
    end
    tooltip:Show()
end

local function buildRememberMeContextActions(rootDescription, name, realm, unit, contextData)
    local L = NBK.L
    local entry = RememberMe:GetEntry(name, realm)
    if entry then
        rootDescription:CreateButton(L["Edit Remember Me entry"] or "Edit Remember Me entry", function()
            RememberMe:ShowEditDialog(entry)
        end)
        rootDescription:CreateButton(L["Remove from Remember Me"] or "Remove from Remember Me", function()
            LibStub("NerzorsUILib-1.0"):Confirm({
                text = L["Remove %s from Remember Me?"]:format(NBK:DisplayName(name, realm)),
                onAccept = function()
                    RememberMe:RemoveEntry(name, realm)
                    local lw = NBK:GetModule("ListWindow")
                    if lw and lw.Refresh then lw:Refresh() end
                end,
            })
        end)
    else
        rootDescription:CreateButton(L["Add to Remember Me"] or "Add to Remember Me", function()
            local class
            if unit and UnitExists(unit) and UnitIsPlayer(unit) then
                local _, classFile = UnitClass(unit)
                class = classFile
            end
            RememberMe:ShowAddDialog({
                name  = NBK:DisplayName(name, realm),
                class = class,
            })
        end)
    end
end

local dialogState = {}

local function buildDialog(globalName, titleKey)
    local NUL = LibStub("NerzorsUILib-1.0")
    local L   = NBK.L
    local theme = NUL:GetTheme()
    local W = 440

    local f = NUL:Window({
        name   = globalName,
        title  = L[titleKey] or titleKey,
        width  = W,
        height = 430,
        strata = "DIALOG",
    })
    f:SetFrameLevel(200)
    f:SetPositionKey(globalName, NBK.db)
    f:RestorePosition()

    local content = f.content
    local y = 0

    local nameLabel = NUL:CreateLabel(content, {
        text  = (L["Name"] or "Name") .. " (Name-Realm)",
        color = theme.colors.text.muted,
        role  = "field",
    })
    nameLabel:SetPoint("TOPLEFT", 0, y); y = y - 16

    local nameBox = NUL:EditBox(content, { width = W - 24, height = 26 })
    nameBox:SetPoint("TOPLEFT", 0, y); y = y - 34

    local ratingLabel = NUL:CreateLabel(content, {
        text  = L["Rating"] or "Rating",
        color = theme.colors.text.muted,
        role  = "field",
    })
    ratingLabel:SetPoint("TOPLEFT", 0, y); y = y - 18

    local stars = createStarRating(content, 22, false)
    stars:SetPoint("TOPLEFT", 0, y); y = y - 32

    local notesLabel = NUL:CreateLabel(content, {
        text  = L["Notes"] or "Notes",
        color = theme.colors.text.muted,
        role  = "field",
    })
    notesLabel:SetPoint("TOPLEFT", 0, y); y = y - 16

    local notesBox = NUL:EditBox(content, {
        width      = W - 24,
        height     = 70,
        multiline  = true,
        maxLetters = 1000,
    })
    notesBox:SetPoint("TOPLEFT", 0, y); y = y - 78

    local roleLabel = NUL:CreateLabel(content, {
        text  = L["Role"] or "Role",
        color = theme.colors.text.muted,
        role  = "field",
    })
    roleLabel:SetPoint("TOPLEFT", 0, y); y = y - 18

    local roleDD = NUL:Dropdown(content, {
        width = 180, height = 24,
        options = {
            { key = "",        label = L["(no role)"] or "(no role)" },
            { key = "TANK",    label = L["Tank"]      or "Tank"      },
            { key = "HEALER",  label = L["Healer"]    or "Healer"    },
            { key = "DAMAGER", label = L["DPS"]       or "DPS"       },
        },
        value = "",
    })
    roleDD:SetPoint("TOPLEFT", 0, y); y = y - 34

    local cancel = NUL:Button(content, {
        label = L["Cancel"],
        width = 80, height = 24,
        onClick = function() f:Hide() end,
    })
    cancel:SetPoint("BOTTOMRIGHT", 0, 0)

    local accept = NUL:Button(content, {
        label = L["OK"],
        width = 80, height = 24, style = "accent",
    })
    accept:SetPoint("BOTTOMRIGHT", cancel, "BOTTOMLEFT", -6, 0)

    f._nameEB, f._notesEB, f._stars, f._roleDD = nameBox, notesBox, stars, roleDD
    f.acceptButton = accept

    function f:SetValues(values)
        values = values or {}
        self._nameEB:SetText(values.name or "")
        self._nameEB:SetCursorPosition(0)
        self._notesEB:SetText(values.notes or "")
        self._notesEB:SetCursorPosition(0)
        self._stars:SetValue(values.rating or settings().defaultRating or 4)
        if self._roleDD then self._roleDD:SetValue(values.role or "") end
    end

    function f:GetValues()
        local role = self._roleDD and self._roleDD:GetValue() or ""
        return {
            name   = self._nameEB:GetText(),
            notes  = self._notesEB:GetText(),
            rating = self._stars:GetValue(),
            role   = (role ~= "" and role) or nil,
        }
    end

    function f:SetOnAccept(cb)
        accept:SetScript("OnClick", function()
            local values = self:GetValues()
            local ok, err = cb(values)
            if ok ~= false then self:Hide() end

            if err then NBK:Print(NBK.L[err]) end
        end)
    end

    function f:SetNameEditable(editable)
        local eb = self._nameEB.editBox
        if editable then
            eb:EnableMouse(true)
            NUL.SetFontColor(eb, theme.colors.text.primary)
            eb:SetScript("OnEditFocusGained", nil)
        else
            NUL.SetFontColor(eb, theme.colors.text.muted)
            eb:SetScript("OnEditFocusGained", function(self) self:ClearFocus() end)
        end
    end

    return f
end

function RememberMe:ShowAddDialog(prefill)
    if not dialogState.add then
        dialogState.add = buildDialog("NBKRememberMeAddDialog", "Add to Remember Me")
    end
    local d = dialogState.add
    d:SetNameEditable(true)
    d:SetValues(prefill or {})
    d:SetOnAccept(function(values)
        if not values.name or values.name == "" then return false, "name required" end
        local n, r = splitNameRealm(values.name)
        if not n then return false, "invalid name" end
        local entry, status = self:AddEntry(n, r, {
            rating = values.rating,
            notes  = values.notes,
            role   = values.role,
            class  = (prefill and prefill.class) or nil,
            run    = (prefill and prefill.run) or nil,
        })
        if not entry then return false, status end
        self:RefreshTab()
        local lw = NBK:GetModule("ListWindow")
        if lw and lw.Refresh then lw:Refresh() end
        return true
    end)
    d:Show()
end

function RememberMe:ShowEditDialog(entry)
    if not dialogState.edit then
        dialogState.edit = buildDialog("NBKRememberMeEditDialog", "Edit Remember Me entry")
    end
    local d = dialogState.edit
    d:SetNameEditable(false)
    d:SetValues({
        name   = NBK:DisplayName(entry.name, entry.realm),
        notes  = entry.notes,
        rating = entry.rating,
        role   = entry.role,
    })
    d:SetOnAccept(function(values)
        self:UpdateEntry(entry.name, entry.realm, {
            rating = values.rating,
            notes  = values.notes,
        })

        local saved = self:GetEntry(entry.name, entry.realm)
        if saved then saved.role = values.role end
        self:RefreshTab()
        return true
    end)
    d:Show()
end

local ROW_HEIGHT = 26
local OPTIONS_W  = 70

local RUN_MIN_W   = 90
local RUN_MAX_W   = 220
local NOTES_MIN_W = 120

local tabUI = {}

local function runWidthFor(runs, measure, rowWidth, label)
    local want = (label and measure(label) or 0) + 16
    for _, r in ipairs(runs) do
        local w = measure(r) + 12
        if w > want then want = w end
    end
    want = math.ceil(want)
    if want < RUN_MIN_W then want = RUN_MIN_W end
    if want > RUN_MAX_W then want = RUN_MAX_W end
    if rowWidth and rowWidth > 0 then

        local room = rowWidth - (26 + 170 + 80 + 80 + OPTIONS_W) - (7 * 4) - 8 - NOTES_MIN_W
        if want > room then want = math.max(RUN_MIN_W, math.floor(room)) end
    end
    return want
end
RememberMe._runWidthFor = runWidthFor

local function lc(s) return (s or ""):lower() end

local function sortedEntries(filter, sortKey, sortDir)
    local out = {}
    filter = filter and filter:lower() or ""

    local byRealm = not NBK:IsForever()
    for _, e in pairs(entriesTable()) do
        if filter == ""
           or (e.name or ""):lower():find(filter, 1, true)
           or (byRealm and (e.realm or ""):lower():find(filter, 1, true))
           or (e.notes or ""):lower():find(filter, 1, true)
           or (e.zone or ""):lower():find(filter, 1, true)
           or (e.run or ""):lower():find(filter, 1, true) then
            table.insert(out, e)
        end
    end
    sortKey = sortKey or "rating"
    local asc = sortDir == "asc"
    table.sort(out, function(a, b)
        local va, vb
        if sortKey == "rating" then
            va, vb = a.rating or 0, b.rating or 0
        elseif sortKey == "added" then
            va, vb = a.addedAt or 0, b.addedAt or 0
        elseif sortKey == "name" then
            va, vb = lc(a.name), lc(b.name)
        elseif sortKey == "class" then
            va, vb = lc(a.class), lc(b.class)
        elseif sortKey == "zone" then
            va, vb = lc(a.zone), lc(b.zone)
        elseif sortKey == "run" then
            va, vb = lc(a.run), lc(b.run)
        else
            va, vb = lc(a.name), lc(b.name)
        end
        if va == vb then return lc(a.name) < lc(b.name) end
        if asc then return va < vb end
        return va > vb
    end)
    return out
end

local function buildOptionsCell(row, theme)
    local NUL = LibStub("NerzorsUILib-1.0")
    local f = CreateFrame("Frame", nil, row)
    f:SetSize(OPTIONS_W, 26)

    f.edit = NUL:IconButton(f, {
        icon    = "edit.png",
        size    = 24,
        plain   = true,
        tooltip = NBK.L["Edit"] or "Edit",
    })
    f.edit:SetPoint("LEFT", f, "LEFT", 0, 0)

    f.remove = NUL:IconButton(f, {
        icon    = "app-close.png",
        size    = 24,
        style   = "danger",
        plain   = true,
        tooltip = NBK.L["Remove"] or "Remove",
    })
    f.remove:SetPoint("LEFT", f, "LEFT", 28, 0)

    return f
end

local function makeRowBuilder()
    local NUL = LibStub("NerzorsUILib-1.0")
    local UI  = NBK.UI
    return function(row)
        local theme = NUL:GetTheme()
        local cells = {}

        cells.class  = UI:CreateClassIcon(row, 18)
        cells.name   = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
        cells.rating = NUL:CreateLabel(row, { text = "", justifyH = "LEFT" })
        cells.notes  = NUL:CreateLabel(row, { text = "", size = "sm", color = theme.colors.text.muted, justifyH = "LEFT", wrap = false })
        cells.added  = NUL:CreateLabel(row, { text = "", size = "sm", color = theme.colors.text.muted, justifyH = "LEFT", wrap = false })
        if RememberMe.HAS_MPLUS then
            cells.run = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
        end
        cells.opts   = buildOptionsCell(row, theme)

        local function layout(totalWidth)
            local x = 8
            cells.class:ClearAllPoints();  cells.class:SetPoint("LEFT", row, "LEFT", x, 0); x = x + 22 + 4
            cells.name:ClearAllPoints();   cells.name:SetWidth(170);   cells.name:SetPoint("LEFT", row, "LEFT", x, 0); x = x + 170 + 4
            cells.rating:ClearAllPoints(); cells.rating:SetWidth(80);  cells.rating:SetPoint("LEFT", row, "LEFT", x, 0); x = x + 80 + 4
            cells.added:ClearAllPoints();  cells.added:SetWidth(80);   cells.added:SetPoint("LEFT", row, "LEFT", x, 0); x = x + 80 + 4
            if cells.run then
                local rw = tabUI.runWidth or RUN_MIN_W
                cells.run:ClearAllPoints(); cells.run:SetWidth(rw); cells.run:SetPoint("LEFT", row, "LEFT", x, 0); x = x + rw + 4
            end

            local fixedRight = OPTIONS_W + 8
            local notesW = math.max(60, totalWidth - x - fixedRight - 4)
            cells.notes:ClearAllPoints();  cells.notes:SetWidth(notesW); cells.notes:SetPoint("LEFT", row, "LEFT", x, 0); x = x + notesW + 4
            cells.opts:ClearAllPoints();   cells.opts:SetPoint("LEFT", row, "LEFT", x, 0)
        end
        row._layout = layout

        return function(r, entry)
            r._layout(r:GetWidth())

            cells.class:SetClass(entry.class or "WARRIOR", "midnight")

            local hex = entry.classColor or (entry.class and NBK:GetClassHex(entry.class)) or "ffffff"
            cells.name:SetText(NBK:DisplayName(entry.name, entry.realm, hex))

            cells.rating:SetText(ratingString(entry.rating))
            cells.notes:SetText(entry.notes or "")
            cells.added:SetText(formatDate(entry.addedAt))
            if cells.run then cells.run:SetText(entry.run or "") end

            cells.opts.edit:SetScript("OnClick", function()
                RememberMe:ShowEditDialog(entry)
            end)
            cells.opts.remove:SetScript("OnClick", function()
                local L = NBK.L
                LibStub("NerzorsUILib-1.0"):Confirm({
                    text = L["Remove %s from Remember Me?"]:format(NBK:DisplayName(entry.name, entry.realm)),
                    onAccept = function()
                        RememberMe:RemoveEntry(entry.name, entry.realm)
                        RememberMe:RefreshTab()
                    end,
                })
            end)
        end
    end
end

local function buildHeader(parent, theme, columns, self_ref)
    local NUL = LibStub("NerzorsUILib-1.0")
    local header = CreateFrame("Frame", nil, parent)
    header:SetHeight(20)
    NUL:Surface(header, "header")

    header._cells = {}
    header._cols  = columns

    local function paintCell(cell)
        local col = cell._col
        local active = col.sortable and self_ref.sortKey == col.key

        if NBK:PaintColumnHeader(cell, col, active) then
            if cell._arrow and cell._arrow:IsShown() then
                cell._arrow:SetTexture(NBK:IconPath(
                    (active and self_ref.sortDir == "asc") and "arrow-up.png" or "arrow-down.png"))
            end
            return
        end

        cell._label:SetText(col.label or "")
        local c = active and theme.colors.accent.primary or theme.colors.text.muted
        NUL.SetFontColor(cell._label, c)

        if cell._arrow then
            if active then
                local iconName = (self_ref.sortDir == "asc") and "arrow-up.png" or "arrow-down.png"
                cell._arrow:SetTexture(NBK:IconPath(iconName))
                local a = theme.colors.accent.primary
                cell._arrow:SetVertexColor(a.r, a.g, a.b, 1)
                cell._arrow:Show()
            else
                cell._arrow:Hide()
            end
        end
    end

    for i, col in ipairs(columns) do
        local cell = CreateFrame("Frame", nil, header)
        cell:SetHeight(20)
        cell._col = col

        local fs = NUL:CreateLabel(cell, {
            role     = "column",
            text     = col.label,
            size     = "sm",
            color    = theme.colors.text.muted,
            justifyH = "LEFT",
        })

        fs:SetPoint("LEFT", 0, 0); fs:SetPoint("RIGHT", -14, 0)
        cell._label = fs

        local arrow = cell:CreateTexture(nil, "OVERLAY")
        arrow:SetSize(10, 10)
        arrow:SetPoint("RIGHT", cell, "RIGHT", -2, 0)
        arrow:Hide()
        cell._arrow = arrow

        NBK:SetupColumnHeader(cell, col)

        if col.sortable then
            cell:EnableMouse(true)
            cell:SetScript("OnMouseDown", function() self_ref:_SetSort(col.key) end)
            cell:SetScript("OnEnter", function()
                NUL.SetFontColor(fs, theme.colors.text.primary)
            end)
            cell:SetScript("OnLeave", function() paintCell(cell) end)
        end
        header._cells[i] = cell
    end

    header._paint = function()
        for _, c in ipairs(header._cells) do paintCell(c) end
    end

    header._layout = function()
        local w = header:GetWidth()
        local fixed = 0
        for _, c in ipairs(columns) do
            if not c.flex then fixed = fixed + c.width end
        end
        local flexW = math.max(60, w - fixed - (#columns * 4) - 8)
        local x = 8
        for i, col in ipairs(columns) do
            local cell = header._cells[i]
            local cw = col.flex and flexW or col.width
            cell:ClearAllPoints()
            cell:SetPoint("LEFT", header, "LEFT", x, 0)
            cell:SetWidth(cw)
            paintCell(cell)
            x = x + cw + 4
        end
    end
    header:SetScript("OnSizeChanged", header._layout)

    return header
end

function RememberMe:_BuildTab(parent)
    if tabUI.root then return tabUI.root end
    local NUL   = LibStub("NerzorsUILib-1.0")
    local L     = NBK.L
    local theme = NUL:GetTheme()

    if not self.sortKey then
        self.sortKey, self.sortDir = "rating", "desc"
        if NBK.GetSavedSort then
            local key, dir = NBK:GetSavedSort("remember_me", "rating", "desc")
            if key == "class" or key == "name" or key == "rating" or key == "added"
                or (key == "run" and RememberMe.HAS_MPLUS) then
                self.sortKey, self.sortDir = key, dir
            end
        end
    end

    local root = CreateFrame("Frame", nil, parent)
    root:SetAllPoints()
    tabUI.root = root

    local searchBox = NUL:EditBox(root, {
        width       = 260, height = 26,
        placeholder = L["Search name, realm, reason..."],
        clearButton = true, clearTooltip = L["Clear search"],
        onTextChanged = function() self:RefreshTab() end,
    })
    searchBox:SetPoint("TOPLEFT")
    tabUI.searchEB = searchBox

    local addBtn = NUL:Button(root, {
        label = L["+ Add"] or "+ Add",
        height = 26, style = "accent",
        onClick = function() self:ShowAddDialog() end,
    })
    addBtn:SetPoint("LEFT", searchBox, "RIGHT", 8, 0)

    local rateBtn = NUL:Button(root, {
        label   = L["Rate group"],
        height  = 26,
        tooltip = L["Rate the players in your party. Only in a party - not alone and not in a raid."],
        onClick = function() self:RateGroup() end,
    })
    rateBtn:SetPoint("LEFT", addBtn, "RIGHT", 8, 0)
    tabUI.rateBtn = rateBtn

    local countLabel = NUL:CreateLabel(root, { text = "", color = theme.colors.text.muted })

    countLabel:SetPoint("RIGHT", root, "TOPRIGHT", 0, -13)
    tabUI.countLabel = countLabel

    local columns = {
        { key = "class",  label = L["Class"] or "Class",             width = 26,  sortable = true, compact = true },
        { key = "name",   label = L["Name"]   or "Name",             width = 170, sortable = true  },
        { key = "rating", label = L["Rating"] or "Rating",           width = 80,  sortable = true  },
        { key = "added",  label = L["Date"]   or "Date",             width = 80,  sortable = true  },
        { key = "notes",  label = L["Notes"]  or "Notes",            width = 0,   flex = true,  sortable = false },
        { key = "opts",   label = L["Options"] or "Options",         width = OPTIONS_W, sortable = false },
    }
    if RememberMe.HAS_MPLUS then

        local runCol = { key = "run", label = L["Run"] or "Run", width = tabUI.runWidth or RUN_MIN_W, sortable = true }
        table.insert(columns, 5, runCol)
        tabUI.runCol = runCol
    end

    local header = buildHeader(root, theme, columns, self)
    header:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, -8)
    header:SetPoint("RIGHT")
    tabUI.header = header

    local list = NUL:ScrollList(root, {
        rowHeight  = ROW_HEIGHT,
        rowBuilder = makeRowBuilder(),
    })
    list.container:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    list.container:SetPoint("BOTTOMRIGHT")
    tabUI.list = list

    local emptyText = NUL:CreateLabel(root, {
        text  = RememberMe.HAS_MPLUS
                and L["No entries yet - finish a Mythic+ run to remember your party-mates."]
                or  L["No entries yet - right-click a player or rate your group to remember them."],
        size  = "sm",
        color = theme.colors.text.muted,
    })
    emptyText:SetPoint("TOP", list.container, "TOP", 0, -20)
    emptyText:Hide()
    tabUI.emptyText = emptyText

    if header._layout then header._layout() end
    self:RefreshTab()

    return root
end

function RememberMe:_SetSort(key)
    if self.sortKey == key then
        self.sortDir = (self.sortDir == "asc") and "desc" or "asc"
    else
        self.sortKey = key

        if key == "rating" or key == "added" then
            self.sortDir = "desc"
        else
            self.sortDir = "asc"
        end
    end
    if NBK.SaveSort then NBK:SaveSort("remember_me", self.sortKey, self.sortDir) end
    if tabUI.header and tabUI.header._paint then tabUI.header._paint() end
    self:RefreshTab()
end

function RememberMe:RefreshTab()
    if not tabUI.list then return end
    local filter = tabUI.searchEB and tabUI.searchEB:GetText() or ""
    local entries = sortedEntries(filter, self.sortKey, self.sortDir)

    if tabUI.runCol then
        if not tabUI.runMeasure then
            local NUL = LibStub("NerzorsUILib-1.0")
            tabUI.runMeasure = NUL:CreateLabel(tabUI.root, { text = "", wrap = false })
            tabUI.runMeasure:Hide()
        end
        local fs = tabUI.runMeasure
        local function measure(text) fs:SetText(text); return tonumber(fs:GetStringWidth()) or 0 end
        local seen, runs = {}, {}
        for _, e in pairs(entriesTable()) do
            local r = e.run
            if type(r) == "string" and r ~= "" and not seen[r] then
                seen[r] = true
                runs[#runs + 1] = r
            end
        end
        local headerW = tabUI.header and tonumber(tabUI.header:GetWidth()) or 0
        local w = runWidthFor(runs, measure, headerW, tabUI.runCol.label)
        tabUI.runWidth = w
        if tabUI.runCol.width ~= w then
            tabUI.runCol.width = w
            if tabUI.header and tabUI.header._layout then tabUI.header._layout() end
        end
    end

    tabUI.list:SetData(entries)

    local total = self:CountEntries()
    local shown = #entries
    local L = NBK.L
    if shown == total then
        tabUI.countLabel:SetText((L["%d entries"]):format(total))
    else
        tabUI.countLabel:SetText((L["%d / %d"]):format(shown, total))
    end

    if tabUI.emptyText then
        if total == 0 then tabUI.emptyText:Show() else tabUI.emptyText:Hide() end
    end
    if tabUI.rateBtn then tabUI.rateBtn:SetEnabled(self:CanRateGroup()) end
end

local function buildConfigTab(parent)
    local NUL    = LibStub("NerzorsUILib-1.0")
    local L      = NBK.L
    local Config = NBK:GetModule("Config")
    local theme  = NUL:GetTheme()

    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    local y = 0
    local _, ny = Config:AddSectionLabel(panel, y, "Remember Me"); y = ny

    local s = settings()

    local tipCB = NUL:Checkbox(panel, {
        label    = L["Show in unit tooltips"] or "Show in unit tooltips",
        checked  = s.showTooltip ~= false,
        onChange = function(v) settings().showTooltip = v and true or false end,
    })
    tipCB:SetPoint("TOPLEFT", 0, y); y = y - 26

    if RememberMe.HAS_MPLUS then
        local mpCB = NUL:Checkbox(panel, {
            label    = L["Prompt after Mythic+ runs"] or "Prompt after Mythic+ runs",
            checked  = s.promptOnMplus ~= false,
            onChange = function(v) settings().promptOnMplus = v and true or false end,
        })
        mpCB:SetPoint("TOPLEFT", 0, y); y = y - 26
    end

    local leaveCB = NUL:Checkbox(panel, {
        label    = L["Ask when I leave a group"],
        checked  = s.promptOnLeave == true,
        onChange = function(v) settings().promptOnLeave = v and true or false end,
    })
    leaveCB:SetPoint("TOPLEFT", 0, y); y = y - 26

    local mateCB = NUL:Checkbox(panel, {
        label    = L["Ask when someone leaves the group"],
        checked  = s.promptOnMemberLeave == true,
        onChange = function(v) settings().promptOnMemberLeave = v and true or false end,
    })
    mateCB:SetPoint("TOPLEFT", 0, y); y = y - 26

    local raidCB = NUL:Checkbox(panel, {
        label    = L["Also in raids (when someone leaves)"],
        checked  = s.promptInRaid == true,
        onChange = function(v) settings().promptInRaid = v and true or false end,
    })
    raidCB:SetPoint("TOPLEFT", 16, y); y = y - 26

    local rLabel = NUL:CreateLabel(panel, {
        text  = L["Default rating"] or "Default rating",
        color = theme.colors.text.muted,
    })
    rLabel:SetPoint("TOPLEFT", 0, y); y = y - 18

    local rDD = NUL:Dropdown(panel, {
        width = 140, height = 24,
        options = {
            { key = 1, label = "1 " .. starIcon(12) },
            { key = 2, label = "2 " .. starIcon(12) },
            { key = 3, label = "3 " .. starIcon(12) },
            { key = 4, label = "4 " .. starIcon(12) },
            { key = 5, label = "5 " .. starIcon(12) },
        },
        value = s.defaultRating or 4,
        onSelect = function(v) settings().defaultRating = tonumber(v) or 4 end,
    })
    rDD:SetPoint("TOPLEFT", 0, y); y = y - 36

    local _, ny2 = Config:AddDivider(panel, y); y = ny2

    local clearBtn = NUL:Button(panel, {
        label = L["Clear Remember Me..."] or "Clear Remember Me...",
        width = 200, height = 26, style = "danger",
        onClick = function()
            local n = RememberMe:CountEntries()
            local prompt = (L["Clear all %d Remember Me entries?"] or "Clear all %d Remember Me entries?"):format(n)
            NUL:Confirm({
                text = prompt,
                onAccept = function()
                    local removed = RememberMe:Clear()
                    NBK:Print((L["Cleared %d Remember Me entries."] or "Cleared %d Remember Me entries."):format(removed))
                    RememberMe:RefreshTab()
                end,
            })
        end,
    })
    clearBtn:SetPoint("TOPLEFT", 0, y); y = y - 32

    panel.lastY = y
    return panel
end

local mplusPopup

function RememberMe.FormatRunTime(ms)
    if type(ms) ~= "number" or ms <= 0 then return nil end
    local s = math.floor(ms / 1000)
    local h, m = math.floor(s / 3600), math.floor((s % 3600) / 60)
    s = s % 60
    if h > 0 then return ("%d:%02d:%02d"):format(h, m, s) end
    return ("%d:%02d"):format(m, s)
end

local function captureCurrentPartyMembers()
    local list = {}
    if not IsInGroup(LE_PARTY_CATEGORY_HOME) then return list end
    if IsInRaid() then return list end

    local myName = NBK:PlayerName()
    for i = 1, GetNumGroupMembers() do
        local unit = "party" .. i
        if UnitExists(unit) and UnitIsPlayer(unit) then
            local name, realm = NBK:UnitPlayer(unit)

            if name and name ~= myName then
                realm = realm or GetNormalizedRealmName()
                local _, classFile = UnitClass(unit)
                table.insert(list, { name = name, realm = realm, class = classFile })
            end
        end
    end
    return list
end

local function readCompletionInfo()
    local CM = C_ChallengeMode
    if type(CM) ~= "table" then return nil end
    if type(CM.GetChallengeCompletionInfo) == "function" then
        local ok, t = pcall(CM.GetChallengeCompletionInfo)
        if ok and type(t) == "table" then
            return t.mapChallengeModeID, t.level, t.time, t.onTime
        end
    end
    if type(CM.GetCompletionInfo) == "function" then
        local ok, mapID, level, timeMs, onTime = pcall(CM.GetCompletionInfo)
        if ok then return mapID, level, timeMs, onTime end
    end
    return nil
end

local function captureMplusInfo()
    local mapID, level, timeMs, onTime = readCompletionInfo()
    if issecretvalue and (issecretvalue(mapID) or issecretvalue(level)
        or issecretvalue(timeMs) or issecretvalue(onTime)) then return nil end
    if type(mapID) ~= "number" or mapID == 0 then return nil end
    if type(level) ~= "number" then level = nil end
    if type(timeMs) ~= "number" then timeMs = nil end
    local mapName = ""
    if type(C_ChallengeMode.GetMapUIInfo) == "function" then
        local ok, n = pcall(C_ChallengeMode.GetMapUIInfo, mapID)
        if ok and type(n) == "string" and not (issecretvalue and issecretvalue(n)) then mapName = n end
    end
    return {
        mapID    = mapID,
        mapName  = mapName,
        level    = level or 0,
        timeMs   = timeMs or 0,
        onTime   = onTime and true or false,
    }
end

local function buildMplusPopup()
    if mplusPopup then return mplusPopup end
    local NUL   = LibStub("NerzorsUILib-1.0")
    local UI    = NBK.UI
    local L     = NBK.L
    local theme = NUL:GetTheme()

    local f = NUL:Window({
        name   = "NBKRememberMeMplusPopup",
        title  = L["Mythic+ run finished"] or "Mythic+ run finished",
        width  = 570, height = 340,
        strata = "DIALOG",
    })

    f:SetFrameLevel(180)
    f:SetPositionKey("NBKRememberMeMplusPopup", NBK.db)
    f:RestorePosition()
    f:Hide()

    local content = f.content

    local subtitle = NUL:CreateLabel(content, {
        text     = "",
        size     = "sm",
        color    = theme.colors.text.muted,
        justifyH = "LEFT",
    })
    subtitle:SetPoint("TOPLEFT", 0, 0)
    subtitle:SetPoint("RIGHT", 0, 0)
    f.subtitle = subtitle

    local hint = NUL:CreateLabel(content, {
        text = L["Rate your party-mates"] or "Rate your party-mates",
    })
    hint:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -10)

    local rowsContainer = CreateFrame("Frame", nil, content)
    rowsContainer:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -8)
    rowsContainer:SetPoint("RIGHT", 0, 0)
    rowsContainer:SetHeight(180)
    f.rowsContainer = rowsContainer
    f._memberRows = {}

    local done = NUL:Button(content, {
        label = L["Done"] or "Done",
        width = 100, height = 26, style = "accent",
        onClick = function() f:Hide() end,
    })
    done:SetPoint("BOTTOMRIGHT", 0, 0)

    function f:SetData(info, members)
        local L = NBK.L

        if info then
            local resultText = info.onTime and (L["timed"] or "timed") or (L["depleted"] or "depleted")
            local text = (L["%s +%d - %s"] or "%s +%d - %s"):format(
                info.mapName ~= "" and info.mapName or "?",
                info.level or 0,
                resultText)

            local clock = RememberMe.FormatRunTime(info.timeMs)
            if clock then text = text .. " (" .. clock .. ")" end
            self.subtitle:SetText(text)
        else
            self.subtitle:SetText("")
        end

        for _, r in ipairs(self._memberRows) do r:Hide(); r:SetParent(nil) end
        wipe(self._memberRows)

        local t = NUL:GetTheme()
        local rowH = 32

        for i, m in ipairs(members) do
            local row = CreateFrame("Frame", nil, self.rowsContainer)
            row:SetHeight(rowH)
            row:SetPoint("TOPLEFT", 0, -(i - 1) * (rowH + 4))
            row:SetPoint("RIGHT", 0, 0)
            NUL:FillBackground(row, t.colors.bgLight)

            local classIcon = UI:CreateClassIcon(row, 22)
            classIcon:SetPoint("LEFT", row, "LEFT", 6, 0)
            classIcon:SetClass(m.class or "WARRIOR", "midnight")

            local hex = (m.class and NBK:GetClassHex(m.class)) or "ffffff"
            local nameLbl = NUL:CreateLabel(row, {
                text     = NBK:DisplayName(m.name, m.realm, hex),
                justifyH = "LEFT",
                wrap     = false,
            })
            nameLbl:SetPoint("LEFT", classIcon, "RIGHT", 8, 0)
            nameLbl:SetWidth(180)

            local rmBtn = NUL:Button(row, {
                label = starIcon(13) .. " " .. (L["Remember Me"] or "Remember Me"),
                width = 130, height = 22, style = "accent",
                onClick = function()

                    RememberMe:ShowAddDialog({
                        name   = NBK:DisplayName(m.name, m.realm),
                        class  = m.class,
                        rating = settings().defaultRating or 4,
                        run    = info and NBK.FormatRun and NBK:FormatRun(info.mapName, info.level) or nil,
                    })
                end,
            })
            rmBtn:SetPoint("RIGHT", row, "RIGHT", -8, 0)

            local blBtn = NUL:Button(row, {
                label = L["Add to blacklist"] or "Add to Blacklist",
                width = 130, height = 22, style = "danger",
                onClick = function()
                    local lw = NBK:GetModule("ListWindow")
                    if lw and lw.ShowAddDialog then

                        lw:ShowAddDialog({
                            name  = NBK:DisplayName(m.name, m.realm),
                            class = m.class,
                            zone  = info and NBK.FormatRun and NBK:FormatRun(info.mapName, info.level) or nil,
                        })
                    end
                end,
            })
            blBtn:SetPoint("RIGHT", rmBtn, "LEFT", -6, 0)

            table.insert(self._memberRows, row)
        end

        self.rowsContainer:SetHeight(math.max(1, #members) * (rowH + 4))
    end

    mplusPopup = f
    return f
end

local function showMplusPopup(info, members)
    if settings().promptOnMplus == false then return end
    info    = info    or captureMplusInfo()
    members = members or captureCurrentPartyMembers()
    if #members == 0 then return end

    local f = buildMplusPopup()
    f._mode = "mplus"
    f:SetTitle(NBK.L["Mythic+ run finished"])
    f:SetData(info, members)
    f:Show()
end

function RememberMe:CanRateGroup()
    return (IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid()) and true or false
end

function RememberMe:RateGroup()
    local L = NBK.L
    local members = self:CanRateGroup() and captureCurrentPartyMembers() or {}
    if #members == 0 then
        NBK:Print(L["Rate the players in your party. Only in a party - not alone and not in a raid."])
        return false
    end
    local f = buildMplusPopup()
    f._mode = "rate"
    f:SetTitle(L["Rate group"])
    f:SetData(nil, members)
    f:Show()
    return true
end

local function refreshRateButton()
    if tabUI.rateBtn then tabUI.rateBtn:SetEnabled(RememberMe:CanRateGroup()) end
end

local MIN_TOGETHER = 300
local MAX_ROWS     = 5
local roster = { inGroup = false, isRaid = false, members = {} }
local pendingRate
local regenFrame

local function scanRoster()
    local out = {}
    if not IsInGroup() then return out, false end
    local isRaid = IsInRaid() and true or false
    local n = GetNumGroupMembers() or 0
    local prefix, count = "party", n - 1
    if isRaid then prefix, count = "raid", n end
    local unknown = UNKNOWNOBJECT or "Unknown"
    for i = 1, count do
        local unit = prefix .. i
        if UnitExists(unit) and UnitIsPlayer(unit) and not UnitIsUnit(unit, "player") then
            local name, realm = NBK:UnitPlayer(unit)
            if not name then return nil end
            if issecretvalue and (issecretvalue(name) or (realm ~= nil and issecretvalue(realm))) then
                return nil
            end
            if name == "" or name == unknown then return nil end
            realm = realm or GetNormalizedRealmName()
            local key = NBK:NormalizeKey(name, realm)
            if key then
                local _, classFile = UnitClass(unit)
                out[key] = { name = name, realm = realm, class = classFile }
            end
        end
    end
    return out, isRaid
end

local function sameMember(a, b)
    return NBK:NormalizeKey(a.name, a.realm) == NBK:NormalizeKey(b.name, b.realm)
end

local function openRatePopupFor(players)
    local f = buildMplusPopup()
    local recentMplus = (GetTime() - (RememberMe._lastPopupAt or -1e9)) < 15
    if f:IsShown() and f._mode == "mplus" then return end
    if recentMplus then return end
    local list = {}
    if f:IsShown() and f._mode == "rate" and f._members then
        for _, m in ipairs(f._members) do list[#list + 1] = m end
    end
    for _, p in ipairs(players) do
        local dup = false
        for _, m in ipairs(list) do if sameMember(m, p) then dup = true; break end end
        if not dup then list[#list + 1] = p end
    end
    while #list > MAX_ROWS do table.remove(list, 1) end
    f._mode, f._members = "rate", list
    f:SetTitle(NBK.L["Rate group"])
    f:SetData(nil, list)
    f:Show()
end

local function onRegenEnabled()
    if regenFrame then regenFrame:UnregisterEvent("PLAYER_REGEN_ENABLED") end
    local players = pendingRate
    pendingRate = nil
    if players and #players > 0 then openRatePopupFor(players) end
end

local function promptFor(departed, now)
    local pick = {}
    for _, m in ipairs(departed) do
        if now - (m.since or now) >= MIN_TOGETHER then
            local okBL, onBL = pcall(NBK.IsBlacklisted, NBK, m.name, m.realm)
            if not (okBL and onBL) and not RememberMe:HasEntry(m.name, m.realm) then
                pick[#pick + 1] = { name = m.name, realm = m.realm, class = m.class }
            end
        end
    end
    if #pick == 0 then return end
    if InCombatLockdown() then
        pendingRate = pendingRate or {}
        for _, p in ipairs(pick) do pendingRate[#pendingRate + 1] = p end
        if not regenFrame then
            regenFrame = CreateFrame("Frame")
            regenFrame:SetScript("OnEvent", onRegenEnabled)
        end
        regenFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    openRatePopupFor(pick)
end

local function onRosterChanged(silent)
    local cur, isRaid = scanRoster()
    if not cur then return end
    local now = GetTime()
    local inGroup = IsInGroup() and true or false

    local departed = {}
    for key, m in pairs(roster.members) do
        if not cur[key] then departed[#departed + 1] = m end
    end
    for key, m in pairs(cur) do
        local old = roster.members[key]
        m.since = old and old.since or now
    end
    local wasInGroup, wasRaid = roster.inGroup, roster.isRaid
    roster.members, roster.inGroup, roster.isRaid = cur, inGroup, isRaid
    if silent or #departed == 0 then return end

    local s = settings()
    if wasInGroup and not inGroup then
        if wasRaid then return end
        if s.promptOnLeave == true
           or (s.promptOnMemberLeave == true and #departed == 1) then
            promptFor(departed, now)
        end
    elseif s.promptOnMemberLeave == true then
        if (isRaid or wasRaid) and s.promptInRaid ~= true then return end
        promptFor(departed, now)
    end
end

function RememberMe:OnEnable()

    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
       and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnit)
    elseif GameTooltip and GameTooltip.HookScript then
        GameTooltip:HookScript("OnTooltipSetUnit", onTooltipSetUnit)
    end

    local lw = NBK:GetModule("ListWindow")
    if lw and lw.RegisterTab then
        lw:RegisterTab({
            key      = "remember_me",
            labelKey = "Remember Me",
            order    = 30,
            build    = function(parent) return RememberMe:_BuildTab(parent) end,
            refresh  = function() RememberMe:RefreshTab() end,
            onShow   = function() RememberMe:RefreshTab() end,

            showAddDialog  = function(_, prefill) RememberMe:ShowAddDialog(prefill) end,
            showEditDialog = function(_, entry)   RememberMe:ShowEditDialog(entry) end,
        })
    end

    local Config = NBK:GetModule("Config")
    if Config and Config.RegisterTab then
        Config:RegisterTab({
            key = "RememberMe", labelKey = "Remember Me", build = buildConfigTab,
            order = 36, icon = "tab-remembered.png", category = "modules",
        })
    end

    local cm = NBK:GetModule("ContextMenu")
    if cm and cm.RegisterAction then
        cm:RegisterAction({
            key     = "remember_me_actions",
            order   = 20,
            builder = buildRememberMeContextActions,
        })
    end

    if NBK and NBK.AddPlayer and not self._addPlayerHooked then
        self._addPlayerHooked = true
        hooksecurefunc(NBK, "AddPlayer", function(_, name, realm)

            if realm == "" then realm = nil end
            local key, n, r = NBK:NormalizeKey(name, realm)
            if not key then return end
            name = n

            if C_Timer and C_Timer.After then
                C_Timer.After(0, function() promptRememberMeConflict(name, r) end)
            else
                promptRememberMeConflict(name, r)
            end
        end)
    end

    local rosterFrame = CreateFrame("Frame")
    rosterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    rosterFrame:SetScript("OnEvent", function()
        refreshRateButton()
        onRosterChanged(false)
    end)
    onRosterChanged(true)

    if not RememberMe.HAS_MPLUS then return end

    local f = CreateFrame("Frame")
    f:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self._lastPopupAt  = 0

    f:SetScript("OnEvent", function(_, event)
        local now = GetTime() or 0

        if now - (self._lastPopupAt or 0) < 5 then
            return
        end
        self._lastPopupAt = now

        local info    = captureMplusInfo()
        local members = captureCurrentPartyMembers()
        if #members == 0 then return end

        if C_Timer and C_Timer.After then

            C_Timer.After(2, function() showMplusPopup(info, members) end)
        else
            showMplusPopup(info, members)
        end
    end)
end
