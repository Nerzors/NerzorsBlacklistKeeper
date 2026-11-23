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
        flagRemembered    = true,
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

local RED   = { 1.0, 0.35, 0.35, 1 }
local GREEN = { 0.40, 0.85, 0.45, 1 }

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

local function isSecret(v) return issecretvalue ~= nil and issecretvalue(v) and true or false end

local function resultLeader(resultID)
    if not resultID or isSecret(resultID) or not C_LFGList or not C_LFGList.GetSearchResultInfo then
        return nil
    end
    local ok, info = pcall(C_LFGList.GetSearchResultInfo, resultID)
    if not ok or type(info) ~= "table" or isSecret(info) then return nil end
    if isSecret(info.leaderName) then return nil end
    if not info.leaderName or info.leaderName == "" then return nil end

    local name, realm = strsplit("-", info.leaderName, 2)
    if not name or name == "" then return nil end
    if not realm or realm == "" then realm = GetNormalizedRealmName() end
    return name, realm
end

local function resultLeaderEntry(resultID)
    local name, realm = resultLeader(resultID)
    if not name then return nil end
    local entry = NBK:GetPlayer(name, realm)
    if not entry then return nil end
    return name, realm, entry
end

local function rememberOn() return S().flagRemembered ~= false end

local function rememberEntry(name, realm)
    local rm = NBK:GetModule("RememberMe")
    if not rm or type(rm.GetEntry) ~= "function" then return nil end
    local ok, e = pcall(rm.GetEntry, rm, name, realm)
    if ok and type(e) == "table" then return e end
end

local function rememberedPlayer(name, realm)
    if not name or not rememberOn() then return nil end
    if NBK:GetPlayer(name, realm) then return nil end
    return rememberEntry(name, realm)
end

local function resultRemembered(resultID)
    if not rememberOn() then return nil end
    local name, realm = resultLeader(resultID)
    local e = rememberedPlayer(name, realm)
    if not e then return nil end
    return name, realm, e
end
GroupFinder._resultRemembered = resultRemembered

local function ratingOf(e)
    local r = math.floor((tonumber(e and e.rating) or 4) + 0.5)
    return math.max(0, math.min(5, r))
end

local STAR, STAR_GAP = 10, 1
local STAR_FULL  = NBK:IconPath("ratings\\star.png")
local STAR_EMPTY = NBK:IconPath("ratings\\star_empty.png")

local function ensureStars(row)
    if row._nbkStars then return row._nbkStars end
    local st = { tex = {} }
    for i = 1, 5 do
        local t = row:CreateTexture(nil, "OVERLAY", nil, 7)
        t:SetSize(STAR, STAR)
        t:Hide()
        st.tex[i] = t
    end
    st.num = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    st.num:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
    st.num:Hide()
    row._nbkStars = st
    return st
end

local function hideStars(row)
    local st = row._nbkStars
    if not st then return end
    for i = 1, 5 do st.tex[i]:Hide() end
    st.num:Hide()
end

local function placeStars(row, nameFS, rating)
    local st = ensureStars(row)
    local textW  = tonumber(nameFS:GetStringWidth()) or 0
    local fieldW = tonumber(nameFS:GetWidth()) or 0
    local fullW  = 5 * (STAR + STAR_GAP)
    for i = 1, 5 do st.tex[i]:Hide(); st.tex[i]:ClearAllPoints() end
    st.num:Hide(); st.num:ClearAllPoints()
    if fieldW <= 0 or textW + 4 + fullW <= fieldW then
        local x = textW + 4
        for i = 1, 5 do
            local t = st.tex[i]
            t:SetTexture(i <= rating and STAR_FULL or STAR_EMPTY)
            t:SetPoint("LEFT", nameFS, "LEFT", x, 0)
            t:Show()
            x = x + STAR + STAR_GAP
        end
        return "full"
    end
    local compactW = STAR + 2 + 8
    local x = math.max(0, math.min(textW + 4, fieldW - compactW))
    local t = st.tex[1]
    t:SetTexture(STAR_FULL)
    t:SetPoint("LEFT", nameFS, "LEFT", x, 0)
    t:Show()
    st.num:SetText(tostring(rating))
    st.num:SetPoint("LEFT", t, "RIGHT", 2, 0)
    st.num:Show()
    return "compact"
end
GroupFinder._placeStars = placeStars

local function ensureStripe(row)
    if row._nbkStripe then return row._nbkStripe end
    local t = row:CreateTexture(nil, "OVERLAY", nil, 7)
    t:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    t:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    t:SetWidth(3)
    row._nbkStripe = t
    return t
end

local function showStripe(row, c)
    local t = ensureStripe(row)
    t:SetColorTexture(c[1], c[2], c[3], 1)
    t:Show()
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
    local resultID = entry.resultID

    local nameFS = entry.Name or entry.ActivityName
    entry._nbkMark = nil

    local active = isEnabled() and S().flagSearchResults ~= false
    local name = active and resultID and resultLeaderEntry(resultID)
    if name then
        ensureFlag(entry):Show()
        if entry._nbkStripe then entry._nbkStripe:Hide() end
        hideStars(entry)
        if nameFS and nameFS.SetTextColor then
            nameFS:SetTextColor(RED[1], RED[2], RED[3])
        end
        entry._nbkMark = "blacklist"
        return
    end
    if entry._nbkFlag then entry._nbkFlag:Hide() end

    local rn, re, _rr
    if resultID then rn, _rr, re = resultRemembered(resultID) end
    if rn and nameFS and nameFS.SetTextColor then
        showStripe(entry, GREEN)
        nameFS:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
        placeStars(entry, nameFS, ratingOf(re))
        entry._nbkMark = "remembered"
    else
        if entry._nbkStripe then entry._nbkStripe:Hide() end
        hideStars(entry)
    end
end
GroupFinder._flagSearchEntry = flagSearchEntry

local EUI_FOLDER = "EllesmereUIGroupFinder"
local euiRows   = setmetatable({}, { __mode = "k" })
local euiFrames = setmetatable({}, { __mode = "k" })
local euiRecolouring = false
local euiScanQueued  = false
local euiHooked      = false

local function isEllesmereRow(r)
    if type(r) ~= "table" or type(r.IsObjectType) ~= "function" then return false end
    local okB, isButton = pcall(r.IsObjectType, r, "Button")
    if not okB or not isButton then return false end
    return type(r.line3) == "table" and type(r.name) == "table"
       and type(r.name.SetTextColor) == "function" and r.mid ~= nil
end

local function flagEllesmereRow(row)
    if euiRecolouring then return end
    row._nbkMark = nil
    local active = isEnabled() and S().flagSearchResults ~= false
    local name = active and row.resultID and resultLeaderEntry(row.resultID)
    if name then
        showStripe(row, RED)
        hideStars(row)
        euiRecolouring = true
        row.name:SetTextColor(RED[1], RED[2], RED[3])
        euiRecolouring = false
        row._nbkMark = "blacklist"
        return
    end

    local rn, re, _rr
    if row.resultID then rn, _rr, re = resultRemembered(row.resultID) end
    if rn then
        showStripe(row, GREEN)
        euiRecolouring = true
        row.name:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
        euiRecolouring = false
        placeStars(row, row.name, ratingOf(re))
        row._nbkMark = "remembered"
    else
        if row._nbkStripe then row._nbkStripe:Hide() end
        hideStars(row)
    end
end
GroupFinder._flagEllesmereRow = flagEllesmereRow

local scanSoon

local function scanEllesmereRows()
    euiScanQueued = false
    local sp = _G.LFGListFrame and _G.LFGListFrame.SearchPanel
    if not sp or type(sp.GetChildren) ~= "function" then return end
    for _, frame in ipairs({ sp:GetChildren() }) do
        for _, body in ipairs({ frame:GetChildren() }) do
            for _, row in ipairs({ body:GetChildren() }) do
                if isEllesmereRow(row) then
                    if not euiRows[row] then
                        euiRows[row] = true
                        hooksecurefunc(row.name, "SetTextColor", function() flagEllesmereRow(row) end)
                    end
                    if not euiFrames[frame] then

                        euiFrames[frame] = true
                        frame:HookScript("OnMouseWheel", function() scanSoon() end)
                        frame:HookScript("OnSizeChanged", function() scanSoon() end)
                    end
                    flagEllesmereRow(row)
                end
            end
        end
    end
end

scanSoon = function()
    if euiScanQueued then return end
    euiScanQueued = true
    if C_Timer and C_Timer.After then
        C_Timer.After(0, scanEllesmereRows)
    else
        scanEllesmereRows()
    end
end

local function isAddOnLoaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then return C_AddOns.IsAddOnLoaded(name) and true or false end
    return IsAddOnLoaded and IsAddOnLoaded(name) and true or false
end

function GroupFinder:EllesmereActive()
    return isAddOnLoaded(EUI_FOLDER)
end

function GroupFinder:EllesmereState()
    local rows, flagged, remembered = 0, 0, 0
    for row in pairs(euiRows) do
        rows = rows + 1
        if row:IsShown() then
            if row._nbkMark == "blacklist" then flagged = flagged + 1
            elseif row._nbkMark == "remembered" then remembered = remembered + 1 end
        end
    end
    return self:EllesmereActive(), euiHooked, rows, flagged, remembered
end

function GroupFinder:BlizzardRowState()
    local rows, flagged, remembered = 0, 0, 0
    local sp = _G.LFGListFrame and _G.LFGListFrame.SearchPanel
    local box = sp and sp.ScrollBox
    if box and box.ForEachFrame then
        box:ForEachFrame(function(e)
            rows = rows + 1
            if e._nbkMark == "blacklist" then flagged = flagged + 1
            elseif e._nbkMark == "remembered" then remembered = remembered + 1 end
        end)
    end
    return rows, flagged, remembered
end

local function hookEllesmere()
    if euiHooked or not GroupFinder:EllesmereActive() then return end
    if not _G.LFGListFrame or not _G.LFGListFrame.SearchPanel then return end
    euiHooked = true
    if _G.LFGListSearchPanel_UpdateResults then
        hooksecurefunc("LFGListSearchPanel_UpdateResults", scanSoon)
    end
    _G.LFGListFrame.SearchPanel:HookScript("OnShow", scanSoon)
    scanSoon()
end

local function applicantMember(appID, memberIdx)
    if not appID or not memberIdx then return nil end
    if isSecret(appID) or not C_LFGList or not C_LFGList.GetApplicantMemberInfo then return nil end
    local ok, full = pcall(C_LFGList.GetApplicantMemberInfo, appID, memberIdx)
    if not ok or full == nil or isSecret(full) or type(full) ~= "string" or full == "" then return nil end
    local name, realm = strsplit("-", full, 2)
    if not name or name == "" then return nil end
    if not realm or realm == "" then realm = GetNormalizedRealmName() end
    return name, realm
end

local function applicantRemembered(appID, memberIdx)
    if not rememberOn() then return nil end
    local name, realm = applicantMember(appID, memberIdx)
    local e = name and rememberedPlayer(name, realm)
    if not e then return nil end
    return name, realm, e
end

local function applicantBlacklisted(appID, memberIdx)
    if not isEnabled() or S().warnOnApplicant == false then return nil end
    local name, realm = applicantMember(appID, memberIdx)
    local e = name and NBK:GetPlayer(name, realm)
    if not e then return nil end
    return name, realm, e
end
GroupFinder._applicantBlacklisted = applicantBlacklisted

local function markApplicant(row, nameFS, appID, memberIdx)
    row._nbkMark = nil
    if applicantBlacklisted(appID, memberIdx) and nameFS and nameFS.SetTextColor then
        showStripe(row, RED)
        nameFS:SetTextColor(RED[1], RED[2], RED[3])
        hideStars(row)
        row._nbkMark = "blacklist"
        return
    end
    local rn, _rr, re = applicantRemembered(appID, memberIdx)
    if rn and nameFS and nameFS.SetTextColor then
        showStripe(row, GREEN)
        nameFS:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
        placeStars(row, nameFS, ratingOf(re))
        row._nbkMark = "remembered"
    else
        if row._nbkStripe then row._nbkStripe:Hide() end
        hideStars(row)
    end
end

local blizzApplicants = setmetatable({}, { __mode = "k" })
local function onUpdateApplicantMember(member, appID, memberIdx)
    if type(member) ~= "table" then return end
    blizzApplicants[member] = true
    member._nbkAppID, member._nbkMemberIdx = appID, memberIdx
    local ok = pcall(markApplicant, member, member.Name, appID, memberIdx)
    if not ok then member._nbkMark = nil end
end
GroupFinder._onUpdateApplicantMember = onUpdateApplicantMember

local euiLines = setmetatable({}, { __mode = "k" })
local euiLineRecolouring = false

local function isEllesmereApplicantLine(l)
    if type(l) ~= "table" or type(l.IsObjectType) ~= "function" then return false end
    local okB, isButton = pcall(l.IsObjectType, l, "Button")
    if not okB or not isButton then return false end
    return type(l.memberIdx) == "number" and type(l.name) == "table"
       and type(l.name.SetTextColor) == "function"
       and type(l.roles) == "table" and type(l.cells) == "table"
end

local function markEllesmereLine(l)
    if euiLineRecolouring then return end
    local block = l.GetParent and l:GetParent()
    local appID = block and block.applicantID
    euiLineRecolouring = true
    local ok = pcall(markApplicant, l, l.name, appID, l.memberIdx)
    euiLineRecolouring = false
    if not ok then l._nbkMark = nil end
end

local applicantScanQueued = false
local function scanEllesmereApplicants()
    applicantScanQueued = false
    local av = _G.LFGListFrame and _G.LFGListFrame.ApplicationViewer
    if not av or type(av.GetChildren) ~= "function" then return end
    for _, frame in ipairs({ av:GetChildren() }) do
        if type(frame.GetChildren) == "function" then
            for _, body in ipairs({ frame:GetChildren() }) do
                if type(body.GetChildren) == "function" then
                    for _, block in ipairs({ body:GetChildren() }) do
                        if type(block) == "table" and type(block.lines) == "table" then
                            for _, l in pairs(block.lines) do
                                if isEllesmereApplicantLine(l) then
                                    if not euiLines[l] then
                                        euiLines[l] = true
                                        hooksecurefunc(l.name, "SetTextColor", function() markEllesmereLine(l) end)
                                    end
                                    markEllesmereLine(l)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function scanApplicantsSoon()
    if not GroupFinder:EllesmereActive() or applicantScanQueued then return end
    applicantScanQueued = true
    if C_Timer and C_Timer.After then
        C_Timer.After(0, scanEllesmereApplicants)
        C_Timer.After(0.3, scanEllesmereApplicants)
    else
        scanEllesmereApplicants()
    end
end
GroupFinder._scanApplicantsSoon = scanApplicantsSoon

function GroupFinder:ApplicantState()
    local bRows, bMarked, eRows, eMarked, bBlack, eBlack = 0, 0, 0, 0, 0, 0
    for m in pairs(blizzApplicants) do
        if m.IsShown == nil or m:IsShown() then
            bRows = bRows + 1
            if m._nbkMark == "remembered" then bMarked = bMarked + 1 end
            if m._nbkMark == "blacklist" then bBlack = bBlack + 1 end
        end
    end
    for l in pairs(euiLines) do
        eRows = eRows + 1
        if l.IsShown == nil or l:IsShown() then
            if l._nbkMark == "remembered" then eMarked = eMarked + 1 end
            if l._nbkMark == "blacklist" then eBlack = eBlack + 1 end
        end
    end
    return bRows, bMarked, eRows, eMarked, bBlack, eBlack
end

local ALERT = "|TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:14:14|t"

local function warnLine(name, realm, reason)
    return ("%s |cffff6666%s:|r %s-%s - %s"):format(ALERT, NBK.L["Blacklisted"], name, realm, reason)
end

local function reasonText(entry)
    local L = NBK.L
    return (entry.reason and entry.reason ~= "")
        and (NBK.ReasonText and NBK:ReasonText(entry.reason) or entry.reason)
        or L["no reason logged"]
end

local BRAND, GREEN_HEX, DIM = "|cff9b59b6NBK|r", "|cff5cb85c", "|cff888c99"

local function starString(rating)
    local full  = "|T" .. STAR_FULL  .. ":14:14:0:0|t"
    local empty = "|T" .. STAR_EMPTY .. ":14:14:0:0|t"
    return full:rep(rating) .. empty:rep(5 - rating)
end
GroupFinder._starString = starString

local function addRememberedLines(tooltip, name, realm, e)
    local L = NBK.L
    local left = ("%s %s%s:|r %s-%s"):format(BRAND, GREEN_HEX, L["Remembered"], name, realm)
    tooltip:AddLine(" ")
    if type(tooltip.AddDoubleLine) == "function" then
        tooltip:AddDoubleLine(left, starString(ratingOf(e)), 1, 1, 1, 1, 1, 1)
    else
        tooltip:AddLine(left .. "  " .. starString(ratingOf(e)), 1, 1, 1)
    end
    if type(e.notes) == "string" and e.notes ~= "" then
        tooltip:AddLine(DIM .. L["Notes"] .. ":|r " .. e.notes, 0.85, 0.95, 0.85, true)
    end
    if type(e.run) == "string" and e.run ~= "" then
        tooltip:AddLine(DIM .. L["Run"] .. ":|r " .. e.run, 0.75, 0.8, 0.75, true)
    end
end

local function onSearchEntryTooltip(tooltip, resultID)
    if not tooltip or type(tooltip.AddLine) ~= "function" then return end
    if isEnabled() and S().flagSearchResults ~= false then
        local name, realm, entry = resultLeaderEntry(resultID)
        if name then
            tooltip:AddLine(" ")
            tooltip:AddLine(warnLine(name, realm, reasonText(entry)), 1, 1, 1, true)
            if tooltip.Show then tooltip:Show() end
            return
        end
    end
    local rn, rr, re = resultRemembered(resultID)
    if not rn then return end
    addRememberedLines(tooltip, rn, rr, re)
    if tooltip.Show then tooltip:Show() end
end
GroupFinder._onSearchEntryTooltip = onSearchEntryTooltip

local function onApplicantMemberEnter(member)
    if type(member) ~= "table" or member._nbkMark ~= "blacklist" then return end
    local tt = _G.GameTooltip
    if not tt or type(tt.AddLine) ~= "function" then return end
    local name, realm, entry = applicantBlacklisted(member._nbkAppID, member._nbkMemberIdx)
    if not name then return end
    tt:AddLine(" ")
    tt:AddLine(warnLine(name, realm, reasonText(entry)), 1, 1, 1, true)
    if tt.Show then tt:Show() end
end
GroupFinder._onApplicantMemberEnter = onApplicantMemberEnter

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

    dlg._nbkWarn.label:SetText(warnLine(name, realm, reasonText(entry)))
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
                local reason = (entry and entry.reason and entry.reason ~= "")
                             and (NBK.ReasonText and NBK:ReasonText(entry.reason) or entry.reason)
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
    for row in pairs(euiRows) do flagEllesmereRow(row) end

    for m in pairs(blizzApplicants) do
        pcall(markApplicant, m, m.Name, m._nbkAppID, m._nbkMemberIdx)
    end
    for l in pairs(euiLines) do markEllesmereLine(l) end
end

local uiHooked = false
local function hookGroupFinderUI()
    if uiHooked then return true end
    if not _G.LFGListFrame then return false end
    uiHooked = true

    if _G.LFGListSearchEntry_Update then
        hooksecurefunc("LFGListSearchEntry_Update", flagSearchEntry)
    end

    if _G.LFGListApplicationDialog_Show then
        hooksecurefunc("LFGListApplicationDialog_Show", onApplicationDialogShow)
    end
    if _G.LFGListApplicationDialog then
        LFGListApplicationDialog:HookScript("OnHide", onApplicationDialogHide)
    end

    hookEllesmere()

    if _G.LFGListUtil_SetSearchEntryTooltip then
        hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", onSearchEntryTooltip)
    end

    if _G.LFGListApplicationViewer_UpdateApplicantMember then
        hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", onUpdateApplicantMember)
    end
    local av = _G.LFGListFrame.ApplicationViewer
    if av and av.HookScript then av:HookScript("OnShow", scanApplicantsSoon) end

    if _G.LFGListApplicantMember_OnEnter then
        hooksecurefunc("LFGListApplicantMember_OnEnter", function(member) pcall(onApplicantMemberEnter, member) end)
    end
    return true
end
GroupFinder._hookGroupFinderUI = hookGroupFinderUI

function GroupFinder:OnEnable()
    if not C_LFGList then return end

    if not hookGroupFinderUI() then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, _, name)
            if name == "Blizzard_GroupFinder" or name == EUI_FOLDER then
                if hookGroupFinderUI() then self:UnregisterAllEvents() end
            end
        end)
    end

    if not euiHooked then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, _, name)
            if name == EUI_FOLDER or name == "Blizzard_GroupFinder" then
                hookEllesmere()
                if euiHooked then self:UnregisterAllEvents() end
            end
        end)
    end

    NBK:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED", checkAllApplicants)
    NBK:RegisterEvent("LFG_LIST_APPLICANT_UPDATED", function(_, applicantID)
        if not isEnabled() or S().warnOnApplicant == false then return end
        checkApplicant(applicantID)
    end)

    NBK:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED", function() scanApplicantsSoon() end)
    NBK:RegisterEvent("LFG_LIST_APPLICANT_UPDATED", function() scanApplicantsSoon() end)

    NBK:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED", clearApplyCache)
    NBK:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED", clearApplyCache)
    NBK:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE", clearApplicantCache)
end
