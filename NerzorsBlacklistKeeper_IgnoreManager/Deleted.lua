local NBK = _G.NBK
if not NBK then return end

local NUL = LibStub("NerzorsUILib-1.0")

local IgnoreAllChars = NBK:GetModule("IgnoreAllChars")
if not IgnoreAllChars then return end

local MAX_NAMES = 8
local CHROME    = 28 + 1 + 12 * 2

local ui = {}

function IgnoreAllChars:ForgetDeleted(rows, alsoBlacklist)
    local ig = NBK.db and NBK.db.ignore
    if not (ig and ig.chars) then return end
    local L = NBK.L
    local fromBlacklist = 0

    for _, row in ipairs(rows) do
        for charKey in pairs(row.gone) do
            local c = ig.chars[charKey]
            if c and c.names then c.names[row.key] = nil end
            self:Unplan(charKey, row.key)
        end
        if alsoBlacklist and row.deleted and row.bl then

            NBK:UpdateEntry(row.name, row.realm, { ignoredByNBK = false })
            if NBK:RemovePlayer(row.name, row.realm) then fromBlacklist = fromBlacklist + 1 end
        end
        if self.selected then self.selected[row.key] = nil end
    end

    NBK:Print(L["Removed from the overview: %d"]:format(#rows))
    if fromBlacklist > 0 then
        NBK:Print(L["Removed from the blacklist: %d"]:format(fromBlacklist))
        local lw = NBK:GetModule("ListWindow")
        if lw and lw.Refresh then lw:Refresh() end
    end
    local core = NBK:GetModule("IgnoreManager")
    if core and core.RefreshTab then core:RefreshTab() end
end

local function fitHeight()
    local h = math.max(14, ui.text:GetStringHeight() or 0) + 8
            + math.max(14, ui.names:GetStringHeight() or 0)
    if ui.alsoBL:IsShown() then
        h = h + 10 + ui.alsoBL:GetHeight()
        if ui.pinned:IsShown() then h = h + 2 + math.max(12, ui.pinned:GetStringHeight() or 0) end
    end
    ui.f:SetHeight(math.ceil(h + 16 + 26 + CHROME))
end

local function build()
    if ui.f then return ui.f end
    local L, theme = NBK.L, NUL:GetTheme()

    local f = NUL:Window({
        name   = "NBKIgnoreDeletedDialog",
        title  = L["Clean up"],
        width  = 420, height = 200,
        strata = "DIALOG",
    })
    ui.f = f

    ui.text = NUL:CreateLabel(f.content, {
        text = L["These players no longer exist. Other characters still have them in their saved lists; the game removes them there at the next login. Remove them from the overview now?"],
        justifyH = "LEFT", color = theme.colors.text.primary,
    })
    ui.text:SetPoint("TOPLEFT", 0, 0)
    ui.text:SetPoint("TOPRIGHT", 0, 0)

    ui.names = NUL:CreateLabel(f.content, {
        text = "", size = "sm", justifyH = "LEFT", color = theme.colors.text.muted,
    })
    ui.names:SetPoint("TOPLEFT", ui.text, "BOTTOMLEFT", 0, -8)
    ui.names:SetPoint("TOPRIGHT", ui.text, "BOTTOMRIGHT", 0, -8)

    ui.alsoBL = NUL:Checkbox(f.content, { label = "" })
    ui.alsoBL:SetPoint("TOPLEFT", ui.names, "BOTTOMLEFT", 0, -10)
    ui.alsoBL:SetWidth(390)

    ui.pinned = NUL:CreateLabel(f.content, {
        text = "", size = "sm", justifyH = "LEFT", color = theme.colors.text.muted,
    })
    ui.pinned:SetPoint("TOPLEFT", ui.alsoBL, "BOTTOMLEFT", 24, -2)

    local accept = NUL:Button(f.content, {
        label = L["Clean up"], width = 120, height = 26, style = "primary",
        onClick = function()
            local rows, also = ui.rows or {}, ui.alsoBL:IsShown() and ui.alsoBL:GetChecked()
            f:Hide()
            IgnoreAllChars:ForgetDeleted(rows, also)
        end,
    })
    accept:SetPoint("BOTTOMRIGHT", 0, 0)

    local cancel = NUL:Button(f.content, {
        label = L["Cancel"], width = 110, height = 26,
        onClick = function() f:Hide() end,
    })
    cancel:SetPoint("RIGHT", accept, "LEFT", -6, 0)

    f:HookScript("OnShow", function()
        if C_Timer and C_Timer.After then C_Timer.After(0, fitHeight) end
    end)
    return f
end

function IgnoreAllChars:ConfirmForgetDeleted(rows)
    if not rows or #rows == 0 then return end
    local L = NBK.L
    local f = build()
    ui.rows = rows

    local names, onBlacklist, pinned = {}, 0, 0
    for i, row in ipairs(rows) do
        if i <= MAX_NAMES then names[#names + 1] = NBK:DisplayName(row.name, row.realm) end
        if row.deleted and row.bl then
            onBlacklist = onBlacklist + 1
            if row.bl.pinned then pinned = pinned + 1 end
        end
    end
    if #rows > MAX_NAMES then names[#names + 1] = "..." end
    ui.names:SetText(table.concat(names, ", "))

    ui.alsoBL:SetLabel(L["Also remove them from the blacklist (%d)"]:format(onBlacklist))
    ui.alsoBL:SetChecked(false)
    ui.alsoBL:SetShown(onBlacklist > 0)
    ui.pinned:SetText(L["Pinned among them: %d"]:format(pinned))
    ui.pinned:SetShown(onBlacklist > 0 and pinned > 0)

    fitHeight()
    f:Show()
end
