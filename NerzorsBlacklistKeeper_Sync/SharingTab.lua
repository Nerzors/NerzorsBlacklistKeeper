local NBK = _G.NBK
if not NBK then return end

local SyncTab = NBK:RegisterModule("SyncTab")

local function db() return NBK:GetAddonDB("Sync") or {} end

local function buildSharingTab(parent)
    local NUL    = LibStub("NerzorsUILib-1.0")
    local L      = NBK.L
    local theme  = NUL:GetTheme()
    local Config = NBK:GetModule("Config")

    local panel = CreateFrame("Frame", nil, parent)
    panel:SetAllPoints()

    local y = 0
    local _, ny = Config:AddSectionLabel(panel, y, "Sharing"); y = ny

    local cbEnabled = NUL:Checkbox(panel, {
        label    = L["Enable sharing (send & receive)"],
        checked  = db().enabled ~= false,
        onChange = function(v)
            local d = NBK:GetAddonDB("Sync")
            if d then d.enabled = v and true or false end
        end,
    })
    cbEnabled:SetPoint("TOPLEFT", 0, y); y = y - 26

    local acceptLabel = NUL:CreateLabel(panel, {
        text  = L["Accept shares from"],
        color = theme.colors.text.muted,
    })
    acceptLabel:SetPoint("TOPLEFT", 0, y); y = y - 18

    local acceptDD = NUL:Dropdown(panel, {
        width = 220, height = 24,
        options = {
            { key = "anyone",  label = L["anyone"]  or "anyone"  },
            { key = "guild",   label = L["guild"]   or "guild"   },
            { key = "friends", label = L["friends"] or "friends" },
            { key = "none",    label = L["nobody"]  or "nobody"  },
        },
        value = db().acceptFrom or "friends",
        onSelect = function(v)
            local d = NBK:GetAddonDB("Sync")
            if d then d.acceptFrom = v end
        end,
    })
    acceptDD:SetPoint("TOPLEFT", 0, y); y = y - 36

    local function addToggle(labelKey, field, defVal)
        local cur = db()[field]
        if cur == nil then cur = defVal end
        local cb = NUL:Checkbox(panel, {
            label    = L[labelKey],
            checked  = cur and true or false,
            onChange = function(v)
                local d = NBK:GetAddonDB("Sync")
                if d then d[field] = v and true or false end
            end,
        })
        cb:SetPoint("TOPLEFT", 0, y)
        y = y - 26
    end

    addToggle("Auto-open import preview on receive", "autoShow",         true)
    addToggle("Announce in chat when sharing",       "announceSend",     true)
    addToggle("New entries shareable by default",    "defaultShareable", true)
    addToggle("Export only shareable entries",       "exportSharedOnly", false)
    addToggle("Debug (verbose send/receive log)",    "debug",            false)

    local _, ny5 = Config:AddDivider(panel, y); y = ny5

    local shareListId = "blacklist"
    local listTypes   = NBK:GetListTypes()
    if #listTypes > 1 then
        local listLabel = NUL:CreateLabel(panel, {
            text  = L["List"] or "List",
            color = theme.colors.text.muted,
        })
        listLabel:SetPoint("TOPLEFT", 0, y); y = y - 18

        local options = {}
        for _, lt in ipairs(listTypes) do
            options[#options + 1] = { key = lt.id, label = lt.label }
        end
        local listDD = NUL:Dropdown(panel, {
            width = 220, height = 24,
            options  = options,
            value    = "blacklist",
            onSelect = function(id) shareListId = id end,
        })
        listDD:SetPoint("TOPLEFT", 0, y); y = y - 32
    end

    local shareWith = NUL:CreateLabel(panel, {
        text  = L["Share with"] or "Share with",
        color = theme.colors.text.muted,
    })
    shareWith:SetPoint("TOPLEFT", 0, y); y = y - 18

    local targetBox = NUL:EditBox(panel, {
        width       = 220,
        height      = 24,
        placeholder = L["name[-realm]"] or "name[-realm]",
    })
    targetBox:SetPoint("TOPLEFT", 0, y)

    local whisperBtn = NUL:Button(panel, {
        label = L["Whisper"] or "Whisper", height = 24, style = "accent",
        onClick = function()
            local t = (targetBox:GetText() or ""):match("^%s*(.-)%s*$")
            if not t or t == "" then return end
            local ok, sentOrErr = NBK:Share("WHISPER", t, shareListId)
            if not ok then NBK:Print(L["share failed:"], L[sentOrErr]) end
        end,
    })
    whisperBtn:SetPoint("LEFT", targetBox, "RIGHT", 8, 0)

    local guildBtn = NUL:Button(panel, {
        label = L["Guild"] or "Guild", height = 24,
        onClick = function()
            local ok, sentOrErr = NBK:Share("GUILD", nil, shareListId)
            if not ok then NBK:Print(L["share failed:"], L[sentOrErr]) end
        end,
    })
    guildBtn:SetPoint("LEFT", whisperBtn, "RIGHT", 8, 0)
    y = y - 36

    local _, nyAS = Config:AddDivider(panel, y); y = nyAS
    local _, nyASh = Config:AddSectionLabel(panel, y, L["Auto-Sync"] or "Auto-Sync"); y = nyASh

    local cbAuto = NUL:Checkbox(panel, {
        label    = L["Auto-Sync new blacklist entries"] or "Auto-Sync new blacklist entries",
        checked  = db().autoSync and true or false,
        onChange = function(v)
            local d = NBK:GetAddonDB("Sync")
            if d then d.autoSync = v and true or false end
        end,
    })
    cbAuto:SetPoint("TOPLEFT", 0, y); y = y - 26

    local modeLbl = NUL:CreateLabel(panel, {
        text  = L["Send to"] or "Send to",
        color = theme.colors.text.muted,
    })
    modeLbl:SetPoint("TOPLEFT", 0, y); y = y - 18

    local recipientsFrame
    local modeDD = NUL:Dropdown(panel, {
        width = 220, height = 24,
        options = {
            { key = "guild",    label = L["Guild"]   or "Guild" },
            { key = "friends",  label = L["Friends"] or "Friends" },
            { key = "specific", label = L["Specific characters"] or "Specific characters" },
        },
        value    = db().autoSyncMode or "guild",
        onSelect = function(v)
            local d = NBK:GetAddonDB("Sync")
            if d then d.autoSyncMode = v end
            if recipientsFrame then recipientsFrame:SetShown(v == "specific") end
        end,
    })
    modeDD:SetPoint("TOPLEFT", 0, y); y = y - 32

    recipientsFrame = CreateFrame("Frame", nil, panel)
    recipientsFrame:SetPoint("TOPLEFT",  0, y)
    recipientsFrame:SetPoint("TOPRIGHT", 0, y)
    recipientsFrame:SetHeight(160)
    recipientsFrame:SetShown((db().autoSyncMode or "guild") == "specific")

    local recipientsHint = NUL:CreateLabel(recipientsFrame, {
        text  = L["Tick the characters that should receive auto-pushes (Name-Realm)."]
                or "Tick the characters that should receive auto-pushes (Name-Realm).",
        size  = "sm",
        color = theme.colors.text.muted,
        justifyH = "LEFT",
    })
    recipientsHint:SetPoint("TOPLEFT",  0, 0)
    recipientsHint:SetPoint("TOPRIGHT", 0, 0)

    local listHost = CreateFrame("Frame", nil, recipientsFrame)
    listHost:SetPoint("TOPLEFT",     0, -18)
    listHost:SetPoint("BOTTOMRIGHT", 0, 0)

    NUL:MultiSelectList(listHost, {
        addPlaceholder = L["Name-Realm"] or "Name-Realm",
        newDefaultsOn  = true,
        get = function()
            local d = NBK:GetAddonDB("Sync")
            if not d then return {} end
            if type(d.autoSyncRecipients) ~= "table" then d.autoSyncRecipients = {} end
            return d.autoSyncRecipients
        end,
        onChange = function() end,
    })

    y = y - 160 - 6

    panel.lastY = y - 12

    local hint = NUL:CreateLabel(panel, {
        text  = L["Changes save automatically."],
        size  = "sm",
        color = theme.colors.text.muted,
    })
    hint:SetPoint("BOTTOMLEFT", 0, 0)

    return panel
end

function SyncTab:OnEnable()
    local Config = NBK:GetModule("Config")
    if Config and Config.RegisterTab then
        Config:RegisterTab({
            key = "Sharing", labelKey = "Sharing", build = buildSharingTab,
            order = 40, icon = "tab-sharing.png", category = "modules",
        })
    end
end
