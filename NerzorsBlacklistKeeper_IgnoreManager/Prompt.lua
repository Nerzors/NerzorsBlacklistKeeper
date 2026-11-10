local NBK = _G.NBK
if not NBK then return end

local NUL = LibStub("NerzorsUILib-1.0")

local IgnoreAllChars = NBK:GetModule("IgnoreAllChars")
if not IgnoreAllChars then return end

local ROW_HEIGHT   = 22
local VISIBLE_ROWS = 5

local ui = {}

local function charName(key) return key and (strsplit("-", key, 2)) or "?" end

local function rowBuilder(row)
    local theme = NUL:GetTheme()
    local who = NUL:CreateLabel(row, { text = "", justifyH = "LEFT", wrap = false })
    who:SetPoint("LEFT", 8, 0)
    local by = NUL:CreateLabel(row, {
        text = "", size = "sm", color = theme.colors.text.muted, justifyH = "RIGHT", wrap = false,
    })
    by:SetPoint("RIGHT", -28, 0)

    return function(_, item)
        local L, t = NBK.L, NUL:GetTheme()
        local job = item.job
        local del = job.op == "del"
        local sign = ("|cff%s%s|r"):format(NUL.ToHex(del and t.colors.state.danger or t.colors.accent.primary),
                                          del and "–" or "+")
        who:SetText(("%s  %s"):format(sign, NBK:DisplayName(job.name, job.realm)))
        by:SetText(job.by and L["planned on %s"]:format(charName(job.by)) or "")
    end
end

local function build()
    if ui.f then return ui.f end
    local L, theme = NBK.L, NUL:GetTheme()

    local f = NUL:Window({
        name   = "NBKIgnoreQueuePrompt",
        title  = L["Ignore Manager"],
        width  = 460, height = 320,
        strata = "DIALOG",
    })
    ui.f = f

    ui.text = NUL:CreateLabel(f.content, { text = "", justifyH = "LEFT", color = theme.colors.text.primary })
    ui.text:SetPoint("TOPLEFT", 0, 0)
    ui.text:SetPoint("TOPRIGHT", 0, 0)

    ui.list = NUL:ScrollList(f.content, { rowHeight = ROW_HEIGHT, rowBuilder = rowBuilder })
    ui.list.container:SetPoint("TOPLEFT", ui.text, "BOTTOMLEFT", 0, -8)
    ui.list.container:SetPoint("RIGHT", f.content, "RIGHT", 0, 0)
    ui.list.container:SetHeight(ROW_HEIGHT * VISIBLE_ROWS + 4)

    ui.alsoBL = NUL:Checkbox(f.content, { label = "" })
    ui.alsoBL:SetWidth(420)
    ui.auto = NUL:Checkbox(f.content, { label = L["Run planned changes automatically from now on"] })
    ui.auto:SetWidth(420)

    local run = NUL:Button(f.content, {
        label = L["Run now"], width = 110, height = 26, style = "primary",
        onClick = function()
            local also = ui.alsoBL:IsShown() and ui.alsoBL:GetChecked()
            if ui.auto:GetChecked() and NBK.db and NBK.db.settings then
                NBK.db.settings.ignoreQueueAuto = true
            end
            f:Hide()
            IgnoreAllChars:ExecuteQueue(also)
        end,
    })
    run:SetPoint("BOTTOMRIGHT", 0, 0)

    local later = NUL:Button(f.content, {
        label = L["Later"], width = 100, height = 26,
        onClick = function() f:Hide() end,
    })
    later:SetPoint("RIGHT", run, "LEFT", -6, 0)

    local discard = NUL:Button(f.content, {
        label = L["Discard"], width = 100, height = 26,
        onClick = function()
            f:Hide()
            IgnoreAllChars:DiscardQueue()
        end,
    })
    discard:SetPoint("RIGHT", later, "LEFT", -6, 0)

    return f
end

function IgnoreAllChars:ShowPrompt()
    local jobs = self:GetOwnJobs()
    if #jobs == 0 then return end
    local L = NBK.L
    local f = build()

    local onBlacklist = 0
    for _, item in ipairs(jobs) do
        local job = item.job
        if job.op == "del" and NBK:IsBlacklisted(job.name, job.realm) then
            onBlacklist = onBlacklist + 1
        end
    end

    ui.text:SetText(L["Changes to this character's ignore list are planned: %d"]:format(#jobs))
    ui.list:SetData(jobs)

    ui.alsoBL:SetLabel(L["Also remove them from the blacklist (%d)"]:format(onBlacklist))
    ui.alsoBL:SetChecked(false)
    ui.alsoBL:SetShown(onBlacklist > 0)
    ui.auto:SetChecked(false)

    ui.alsoBL:ClearAllPoints()
    ui.alsoBL:SetPoint("TOPLEFT", ui.list.container, "BOTTOMLEFT", 0, -8)
    ui.auto:ClearAllPoints()
    ui.auto:SetPoint("TOPLEFT", onBlacklist > 0 and ui.alsoBL or ui.list.container, "BOTTOMLEFT",
                     0, onBlacklist > 0 and -4 or -8)
    f:Show()
end
