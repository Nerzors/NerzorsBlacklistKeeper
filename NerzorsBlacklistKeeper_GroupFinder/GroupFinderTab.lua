local NBK = _G.NBK
if not NBK then return end

local GroupFinderTab = NBK:RegisterModule("GroupFinderTab")

local function db() return NBK:GetAddonDB("GroupFinder") or {} end

local function refreshVisible()
    local gf = NBK:GetModule("GroupFinder")
    if gf and gf.RefreshVisibleResults then gf:RefreshVisibleResults() end
end

local function buildGroupFinderTab(parent)
    local NUL    = LibStub("NerzorsUILib-1.0")
    local L      = NBK.L
    local theme  = NUL:GetTheme()
    local Config = NBK:GetModule("Config")

    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    local y = 0
    local _, ny = Config:AddSectionLabel(panel, y, "Group Finder warnings"); y = ny

    local function addToggle(labelKey, field, defVal, onChange)
        local cur = db()[field]
        if cur == nil then cur = defVal end
        local cb = NUL:Checkbox(panel, {
            label   = L[labelKey] or labelKey,
            checked = cur and true or false,
            onChange = function(v)
                local d = NBK:GetAddonDB("GroupFinder")
                if d then d[field] = v and true or false end
                if onChange then onChange() end
            end,
        })
        cb:SetPoint("TOPLEFT", 0, y)
        y = y - 26
    end

    addToggle("Enable Group Finder warnings",                       "enabled",           true,  refreshVisible)
    addToggle("Flag blacklisted leaders in search results",         "flagSearchResults", true,  refreshVisible)
    addToggle("Warn before applying to a blacklisted leader",       "warnBeforeApply",   true)
    addToggle("Warn when a blacklisted player applies to my group", "warnOnApplicant",   true)

    local hint = NUL:CreateLabel(panel, {
        text  = L["Changes save automatically."],
        size  = "sm",
        color = theme.colors.text.muted,
    })
    hint:SetPoint("BOTTOMLEFT", 0, 0)

    panel.lastY = y
    return panel
end

function GroupFinderTab:OnEnable()
    local Config = NBK:GetModule("Config")
    if Config and Config.RegisterTab then

        Config:RegisterTab({
            key = "GroupFinder", labelKey = "Group Finder warnings", build = buildGroupFinderTab,
            order = 30, icon = "tab-groupfinder.png", category = "modules",
        })
    end
end
