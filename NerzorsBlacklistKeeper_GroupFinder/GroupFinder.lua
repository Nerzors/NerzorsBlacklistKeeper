local NBK = _G.NBK
if not NBK then return end

NBK:RegisterAddonDB({
    addonName = "NerzorsBlacklistKeeper_GroupFinder",
    key       = "GroupFinder",
    svName    = "NerzorsBlacklistKeeperGroupFinderDB",
    version   = 1,
    defaults  = {
        enabled           = true,
        flagSearchResults = true,
        warnBeforeApply   = true,
        warnOnApplicant   = true,
        sound             = true,
        soundFile         = "WaterDrop",
    },
    onFirstLoad = function(db)
        if type(NBKDB) ~= "table" or type(NBKDB.settings) ~= "table" then return end
        local legacy = NBKDB.settings.lfgWarning
        if type(legacy) ~= "table" then return end
        if legacy.enabled           ~= nil then db.enabled           = legacy.enabled and true or false end
        if legacy.flagSearchResults ~= nil then db.flagSearchResults = legacy.flagSearchResults and true or false end
        if legacy.warnBeforeApply   ~= nil then db.warnBeforeApply   = legacy.warnBeforeApply and true or false end
        if legacy.warnOnApplicant   ~= nil then db.warnOnApplicant   = legacy.warnOnApplicant and true or false end
        if legacy.sound             ~= nil then db.sound             = legacy.sound and true or false end
        if type(legacy.soundFile) == "string" then db.soundFile = legacy.soundFile end
        NBKDB.settings.lfgWarning = nil
    end,
})

local GroupFinder = NBK:RegisterModule("GroupFinder")

local RED = { 1.0, 0.35, 0.35, 1 }

local applyWarned, applicantWarned = {}, {}

local function S()
    return NBK:GetAddonDB("GroupFinder") or {}
end

local function isEnabled() return S().enabled ~= false end

local function playSound()
    local s = S()
    if s.sound == false then return end
    local name = s.soundFile or "WaterDrop"
    local path = NBK:SoundPath(name)
    if path and PlaySoundFile then PlaySoundFile(path, "Master") end
end

local function resultLeaderEntry(resultID)
    if not resultID or not C_LFGList or not C_LFGList.GetSearchResultInfo then
        return nil
    end
    local info = C_LFGList.GetSearchResultInfo(resultID)
    if not info or not info.leaderName or info.leaderName == "" then return nil end

    local name, realm = strsplit("-", info.leaderName, 2)
    if not name or name == "" then return nil end
    if not realm or realm == "" then realm = GetNormalizedRealmName() end

    local entry = NBK:GetPlayer(name, realm)
    if not entry then return nil end
    return name, realm, entry
end

local function ensureFlag(entry)
    if entry._nbkFlag then return entry._nbkFlag end
    local f = entry:CreateTexture(nil, "OVERLAY")
    f:SetTexture(NBK:IconPath("eui-close"))
    f:SetSize(18, 18)
    f:SetPoint("LEFT", entry, "LEFT", 2, 0)
    f:SetVertexColor(RED[1], RED[2], RED[3], 1)
    entry._nbkFlag = f
    return f
end

local function flagSearchEntry(entry)
    if not entry then return end

    local active = isEnabled() and S().flagSearchResults ~= false
    if not active then
        if entry._nbkFlag then entry._nbkFlag:Hide() end
        return
    end

    local resultID = entry.resultID
    if not resultID then
        if entry._nbkFlag then entry._nbkFlag:Hide() end
        return
    end

    local name = resultLeaderEntry(resultID)
    if name then
        ensureFlag(entry):Show()

        local nameFS = entry.Name or entry.ActivityName
        if nameFS and nameFS.SetTextColor then
            nameFS:SetTextColor(RED[1], RED[2], RED[3])
        end
    elseif entry._nbkFlag then
        entry._nbkFlag:Hide()
    end
end

local function hideApplyBanner()
    local dlg = _G.LFGListApplicationDialog
    if dlg and dlg._nbkWarn then dlg._nbkWarn:Hide() end
end

local function showApplyBanner(dlg, name, realm, entry)
    local L   = NBK.L
    local NUL = LibStub("NerzorsUILib-1.0")

    if not dlg._nbkWarn then
        local banner = CreateFrame("Frame", nil, dlg)
        banner:SetFrameStrata("DIALOG")
        banner:SetFrameLevel(dlg:GetFrameLevel() + 5)
        banner:SetHeight(30)

        banner:SetPoint("BOTTOMLEFT", dlg, "TOPLEFT", 0, 2)
        banner:SetPoint("BOTTOMRIGHT", dlg, "TOPRIGHT", 0, 2)

        banner.bg = banner:CreateTexture(nil, "BACKGROUND")
        banner.bg:SetAllPoints()
        banner.bg:SetColorTexture(0.55, 0.10, 0.12, 0.95)

        NUL:AddBorder(banner, { 1, 0.35, 0.35, 1 }, 1)

        banner.label = NUL:CreateLabel(banner, {
            text     = "",
            color    = { 1, 1, 1, 1 },
            justifyH = "LEFT",
        })
        banner.label:SetPoint("LEFT",  8, 0)
        banner.label:SetPoint("RIGHT", -8, 0)

        dlg._nbkWarn = banner
    end

    local reason = (entry.reason and entry.reason ~= "") and entry.reason
                 or L["no reason logged"]
    dlg._nbkWarn.label:SetText(("|cffff6666⚠ %s:|r %s-%s - %s"):format(
        L["Blacklisted"], name, realm, reason))
    dlg._nbkWarn:Show()
end

local function onApplicationDialogShow(self, resultID)
    if not isEnabled() then hideApplyBanner(); return end
    if S().warnBeforeApply == false then hideApplyBanner(); return end

    local name, realm, entry = resultLeaderEntry(resultID)
    if not name then hideApplyBanner(); return end

    showApplyBanner(self, name, realm, entry)

    if not applyWarned[resultID] then
        applyWarned[resultID] = true
        playSound()
        NBK:RecordEncounter(name, realm)
    end
end

local function onApplicationDialogHide()
    hideApplyBanner()
end

local function checkApplicant(applicantID)
    if not applicantID or applicantWarned[applicantID] then return end
    if not C_LFGList or not C_LFGList.GetApplicantInfo then return end

    local info = C_LFGList.GetApplicantInfo(applicantID)
    if not info then return end

    local members = info.numMembers or 1
    for i = 1, members do
        local fullName = C_LFGList.GetApplicantMemberInfo(applicantID, i)
        if fullName and fullName ~= "" then
            local n, r = strsplit("-", fullName, 2)
            if not r or r == "" then r = GetNormalizedRealmName() end
            if NBK:IsBlacklisted(n, r) then
                local L = NBK.L
                local entry = NBK:GetPlayer(n, r)
                local reason = (entry and entry.reason and entry.reason ~= "") and entry.reason
                             or L["no reason logged"]
                local hex = NBK:GetClassHex(entry and entry.class or nil)
                NBK:Print((L["LFG applicant |cff%s%s|r-%s is blacklisted (%s)"])
                    :format(hex, n, r, reason))
                applicantWarned[applicantID] = true
                playSound()
                NBK:RecordEncounter(n, r)
                return
            end
        end
    end
end

local function checkAllApplicants()
    if not isEnabled() or S().warnOnApplicant == false then return end
    if not C_LFGList or not C_LFGList.GetApplicants then return end
    for _, applicantID in ipairs(C_LFGList.GetApplicants()) do
        checkApplicant(applicantID)
    end
end

local function clearApplyCache()
    wipe(applyWarned)
end

local function clearApplicantCache()
    wipe(applicantWarned)
end

function GroupFinder:RefreshVisibleResults()
    if not _G.LFGListFrame or not _G.LFGListFrame.SearchPanel then return end
    local scrollBox = LFGListFrame.SearchPanel.ScrollBox
    if scrollBox and scrollBox.ForEachFrame then
        scrollBox:ForEachFrame(function(entry) flagSearchEntry(entry) end)
    end
end

function GroupFinder:OnEnable()
    if not C_LFGList then return end

    if _G.LFGListSearchEntry_Update then
        hooksecurefunc("LFGListSearchEntry_Update", flagSearchEntry)
    end

    if _G.LFGListApplicationDialog_Show then
        hooksecurefunc("LFGListApplicationDialog_Show", onApplicationDialogShow)
    end
    if _G.LFGListApplicationDialog then
        LFGListApplicationDialog:HookScript("OnHide", onApplicationDialogHide)
    end

    NBK:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED", checkAllApplicants)
    NBK:RegisterEvent("LFG_LIST_APPLICANT_UPDATED", function(_, applicantID)
        if not isEnabled() or S().warnOnApplicant == false then return end
        checkApplicant(applicantID)
    end)

    NBK:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED", clearApplyCache)
    NBK:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED", clearApplyCache)
    NBK:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE", clearApplicantCache)
end
