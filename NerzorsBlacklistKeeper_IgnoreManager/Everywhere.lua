local NBK = _G.NBK
if not NBK then return end

local NUL = LibStub("NerzorsUILib-1.0")

local IgnoreAllChars = NBK:GetModule("IgnoreAllChars")
if not IgnoreAllChars then return end

local CAP    = 50
local CHROME = 28 + 1 + 12 * 2

local ui = {}

function IgnoreAllChars:PlanEverywhere(ticked, op)
    local IS = NBK:GetModule("IgnoreSync")
    local rows = {}
    for _, row in ipairs(ticked) do
        if not row.deleted then rows[#rows + 1] = row end
    end
    local p = { op = op, rows = rows, now = {}, plan = {}, cancel = {},
                planChars = 0, free = 0, onBlacklist = 0, pinned = 0 }
    if not IS then return p end

    local want, touched = (op == "add"), {}
    for _, ch in ipairs(self:GetCharacters()) do
        for _, row in ipairs(rows) do
            if row.gone[ch.key] then

            elseif ch.current then

                if IS:IsIgnored(row.name, row.realm) ~= want then p.now[#p.now + 1] = row end
            else
                local ignored = row.on[ch.key] == true
                local job = self:GetPlanned(ch.key, row.key)
                if ignored == want then
                    if job then p.cancel[#p.cancel + 1] = { char = ch.key, row = row } end
                elseif not (job and job.op == op) then
                    p.plan[#p.plan + 1] = { char = ch.key, row = row }
                    touched[ch.key] = true
                end
            end
        end
    end
    for _ in pairs(touched) do p.planChars = p.planChars + 1 end
    p.free = CAP - #IS:GetIgnoreList()

    for _, row in ipairs(rows) do
        if row.bl then
            p.onBlacklist = p.onBlacklist + 1
            if row.bl.pinned then p.pinned = p.pinned + 1 end
        end
    end
    return p
end

function IgnoreAllChars:ApplyEverywhere(p, alsoBlacklist)
    local IS   = NBK:GetModule("IgnoreSync")
    local core = NBK:GetModule("IgnoreManager")
    if not (IS and core) then return end
    local L = NBK.L
    local done, fromBlacklist = 0, 0

    if p.op == "del" then
        for _, row in ipairs(p.now) do

            if row.bl then NBK:UpdateEntry(row.name, row.realm, { ignoredByNBK = false }) end
            core._removing[row.key] = true
            if IS:Remove(row.name, row.realm) then done = done + 1 end
        end
        if alsoBlacklist then
            for _, row in ipairs(p.rows) do
                if row.bl then
                    NBK:UpdateEntry(row.name, row.realm, { ignoredByNBK = false })
                    if NBK:RemovePlayer(row.name, row.realm) then fromBlacklist = fromBlacklist + 1 end
                end
            end
        end
    else
        local count = #IS:GetIgnoreList()
        for _, row in ipairs(p.now) do
            if count >= CAP or IS._listFull then
                NBK:Print(L["Could not ignore %s - the ignore list is full."]
                    :format(NBK:DisplayName(row.name, row.realm)))
            elseif IS:Add(row.name, row.realm) then
                done, count = done + 1, count + 1
            end
        end
    end

    for _, it in ipairs(p.plan)   do self:Plan(it.char, it.row, p.op) end
    for _, it in ipairs(p.cancel) do self:Unplan(it.char, it.row.key) end

    local summary = p.op == "del"
        and L["Remove everywhere - removed here: %d, planned for other characters: %d"]
        or  L["Ignore everywhere - ignored here: %d, planned for other characters: %d"]
    NBK:Print(summary:format(done, #p.plan))
    if #p.cancel > 0 then NBK:Print(L["Planned changes cancelled: %d"]:format(#p.cancel)) end
    if fromBlacklist > 0 then
        NBK:Print(L["Removed from the blacklist: %d"]:format(fromBlacklist))
        local lw = NBK:GetModule("ListWindow")
        if lw and lw.Refresh then lw:Refresh() end
    end

    for _, row in ipairs(p.rows) do (self.selected or {})[row.key] = nil end
    if core.RefreshTab then core:RefreshTab() end
end

local function fitHeight()
    local h = math.max(14, ui.text:GetStringHeight() or 0) + 8
            + math.max(14, ui.details:GetStringHeight() or 0)
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
        name   = "NBKIgnoreEverywhereDialog",
        title  = "",
        width  = 420, height = 200,
        strata = "DIALOG",
    })
    ui.f = f

    ui.text = NUL:CreateLabel(f.content, { text = "", justifyH = "LEFT", color = theme.colors.text.primary })
    ui.text:SetPoint("TOPLEFT", 0, 0)
    ui.text:SetPoint("TOPRIGHT", 0, 0)

    ui.details = NUL:CreateLabel(f.content, {
        text = "", size = "sm", justifyH = "LEFT", color = theme.colors.text.muted,
    })
    ui.details:SetPoint("TOPLEFT", ui.text, "BOTTOMLEFT", 0, -8)
    ui.details:SetPoint("TOPRIGHT", ui.text, "BOTTOMRIGHT", 0, -8)

    ui.alsoBL = NUL:Checkbox(f.content, { label = "" })
    ui.alsoBL:SetPoint("TOPLEFT", ui.details, "BOTTOMLEFT", 0, -10)
    ui.alsoBL:SetWidth(390)

    ui.pinned = NUL:CreateLabel(f.content, {
        text = "", size = "sm", justifyH = "LEFT", color = theme.colors.text.muted,
    })
    ui.pinned:SetPoint("TOPLEFT", ui.alsoBL, "BOTTOMLEFT", 24, -2)

    local function accept()
        local p, also = ui.plan, ui.alsoBL:IsShown() and ui.alsoBL:GetChecked()
        f:Hide()
        if p then IgnoreAllChars:ApplyEverywhere(p, also) end
    end

    ui.confirm = {
        add = NUL:Button(f.content, {
            label = L["Ignore everywhere"], width = 140, height = 26, style = "accent", onClick = accept,
        }),
        del = NUL:Button(f.content, {
            label = L["Remove everywhere"], width = 140, height = 26, style = "danger", onClick = accept,
        }),
    }
    for _, b in pairs(ui.confirm) do b:SetPoint("BOTTOMRIGHT", 0, 0) end

    ui.cancel = NUL:Button(f.content, {
        label = L["Cancel"], width = 110, height = 26,
        onClick = function() f:Hide() end,
    })

    f:HookScript("OnShow", function()
        if C_Timer and C_Timer.After then C_Timer.After(0, fitHeight) end
    end)
    return f
end

function IgnoreAllChars:ConfirmEverywhere(rows, op)
    local L = NBK.L
    if #rows == 0 then
        NBK:Print(L["Select at least one player first."])
        return
    end
    local p = self:PlanEverywhere(rows, op)
    if #p.now + #p.plan + #p.cancel == 0 then
        NBK:Print(L["Nothing to change - the selected players are already like that on every character."])
        return
    end

    local f, theme = build(), NUL:GetTheme()
    ui.plan = p
    local del = op == "del"
    f:SetTitle(del and L["Remove everywhere"] or L["Ignore everywhere"])
    ui.text:SetText((del and L["Remove %d selected players from all characters?"]
                          or L["Ignore %d selected players on all characters?"]):format(#p.rows))

    local lines = {
        L["On this character, right away: %d"]:format(#p.now),
        L["At the next login on %d other characters: %d"]:format(p.planChars, #p.plan),
    }
    if #p.cancel > 0 then lines[#lines + 1] = L["Planned changes cancelled: %d"]:format(#p.cancel) end
    if not del and #p.now > p.free then
        lines[#lines + 1] = ("|cff%s%s|r"):format(NUL.ToHex(theme.colors.state.warning),
            L["Only %d more fit on this character's ignore list."]:format(math.max(0, p.free)))
    end
    ui.details:SetText(table.concat(lines, "\n"))

    local askBL = del and p.onBlacklist > 0
    ui.alsoBL:SetLabel(L["Also remove them from the blacklist (%d)"]:format(p.onBlacklist))
    ui.alsoBL:SetChecked(false)
    ui.alsoBL:SetShown(askBL)
    ui.pinned:SetText(L["Pinned among them: %d"]:format(p.pinned))
    ui.pinned:SetShown(askBL and p.pinned > 0)

    ui.confirm.add:SetShown(not del)
    ui.confirm.del:SetShown(del)
    ui.cancel:ClearAllPoints()
    ui.cancel:SetPoint("RIGHT", ui.confirm[op], "LEFT", -6, 0)

    fitHeight()
    f:Show()
end
