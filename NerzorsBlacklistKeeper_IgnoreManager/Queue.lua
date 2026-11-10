local NBK = _G.NBK
if not NBK then return end

local IgnoreAllChars = NBK:GetModule("IgnoreAllChars")
if not IgnoreAllChars then return end

local NUL = LibStub("NerzorsUILib-1.0")

local CAP = 50

NBK:RegisterSettingsDefaults({ ignoreQueueAuto = false })

local function autoRun()
    local s = NBK.db and NBK.db.settings
    return s and s.ignoreQueueAuto == true
end

local function queueRoot(create)
    local ig = NBK.db and NBK.db.ignore
    if not ig then return nil end
    if not ig.queue and create then ig.queue = {} end
    return ig.queue
end

function IgnoreAllChars:GetPlanned(charKey, playerKey)
    local q = queueRoot(false)
    return q and q[charKey] and q[charKey][playerKey] or nil
end

local function obsolete(key, job)
    local at = IgnoreAllChars:DeletedAt(key)
    return at ~= nil and at > (job.at or 0)
end

function IgnoreAllChars:PlannedCount(charKey)
    local q, n = queueRoot(false), 0
    for key, job in pairs(q and q[charKey] or {}) do
        if not obsolete(key, job) then n = n + 1 end
    end
    return n
end

function IgnoreAllChars:_DropObsolete(charKey)
    local q = queueRoot(false)
    local cq = q and q[charKey]
    if not cq then return end
    for key, job in pairs(cq) do
        if obsolete(key, job) then cq[key] = nil end
    end
    if not next(cq) then q[charKey] = nil end
end

function IgnoreAllChars:Plan(charKey, row, op)
    local q = queueRoot(true)
    if not q or not charKey or not row then return end
    q[charKey] = q[charKey] or {}
    q[charKey][row.key] = {
        op = op, name = row.name, realm = row.realm,
        at = time(), by = self:CurrentCharKey(),
    }
end

function IgnoreAllChars:Unplan(charKey, playerKey)
    local q = queueRoot(false)
    local cq = q and q[charKey]
    if not cq then return end
    cq[playerKey] = nil
    if not next(cq) then q[charKey] = nil end
end

function IgnoreAllChars:TogglePlanned(charKey, row, ignored)
    if not charKey or not row then return end
    if self:GetPlanned(charKey, row.key) then
        self:Unplan(charKey, row.key)
    else
        self:Plan(charKey, row, ignored and "del" or "add")
    end
end

function IgnoreAllChars:GetOwnJobs()
    local q, me = queueRoot(false), self:CurrentCharKey()
    local out = {}
    for key, job in pairs(q and me and q[me] or {}) do out[#out + 1] = { key = key, job = job } end
    table.sort(out, function(a, b) return (a.job.name or ""):lower() < (b.job.name or ""):lower() end)
    return out
end

function IgnoreAllChars:RunQueue()
    if self._queueRan then return end
    local IS   = NBK:GetModule("IgnoreSync")
    local core = NBK:GetModule("IgnoreManager")
    if not (IS and IS:IsAvailable() and core and core._ready) then return end
    self._queueRan = true
    self:_DropObsolete(self:CurrentCharKey())
    if #self:GetOwnJobs() == 0 then return end
    if autoRun() then
        self:ExecuteQueue(false)
    elseif self.ShowPrompt then
        self:ShowPrompt()
    end
end

function IgnoreAllChars:DiscardQueue()
    local q, me = queueRoot(false), self:CurrentCharKey()
    local n = #self:GetOwnJobs()
    if q and me then q[me] = nil end
    NBK:Print(NBK.L["Planned changes discarded: %d"]:format(n))
    local core = NBK:GetModule("IgnoreManager")
    if core and core.RefreshTab then core:RefreshTab() end
end

function IgnoreAllChars:ExecuteQueue(alsoBlacklist)
    local IS   = NBK:GetModule("IgnoreSync")
    local core = NBK:GetModule("IgnoreManager")
    local q, me = queueRoot(false), self:CurrentCharKey()
    local cq = q and me and q[me]
    if not (IS and core and cq) then return end

    local L = NBK.L
    local done, failed, fromBlacklist = 0, 0, 0
    local count = #IS:GetIgnoreList()
    for key, job in pairs(cq) do
        local ignored = IS:IsIgnored(job.name, job.realm)
        if obsolete(key, job) then

            cq[key] = nil
        elseif job.op == "del" then
            if ignored then
                core._removing[key] = true
                IS:Remove(job.name, job.realm)
                count = count - 1
            end
            if alsoBlacklist and NBK:IsBlacklisted(job.name, job.realm)
               and NBK:RemovePlayer(job.name, job.realm) then
                fromBlacklist = fromBlacklist + 1
            end
            cq[key] = nil
            done = done + 1
        elseif ignored then
            cq[key] = nil
            done = done + 1
        elseif count >= CAP or IS._listFull then
            job.failed, job.triedAt = "full", time()
            failed = failed + 1
            NBK:Print(L["Could not ignore %s - the ignore list is full."]
                :format(NBK:DisplayName(job.name, job.realm)))
        elseif IS:Add(job.name, job.realm) then
            cq[key] = nil
            done = done + 1
            count = count + 1
        else
            job.failed, job.triedAt = "error", time()
            failed = failed + 1
        end
    end
    if not next(cq) then q[me] = nil end

    NBK:Print(L["Ignore Manager - planned changes done: %d, failed: %d"]:format(done, failed))
    if fromBlacklist > 0 then
        NBK:Print(L["Removed from the blacklist: %d"]:format(fromBlacklist))
    end
    if core.RefreshTab then core:RefreshTab() end
end

local function buildSettingsSection(panel, y)
    local Config = NBK:GetModule("Config")
    local L = NBK.L
    local _, ny = Config:AddSectionLabel(panel, y - 10, "Ignore Manager"); y = ny
    local cb
    cb, y = Config:AddCheckboxRow(panel, y,
        "Run planned ignore-list changes automatically at login", {"ignoreQueueAuto"}, false)
    NUL:AttachTooltip(cb, L["Changes you plan in the Ignore Manager for another character run at that character's next login - with this option right away, otherwise NBK asks first. The blacklist is never changed automatically."])
    return y - 8
end

function IgnoreAllChars:_InitQueue()
    local core = NBK:GetModule("IgnoreManager")
    if not core then return end
    local Config = NBK:GetModule("Config")
    if Config and Config.RegisterSection then
        Config:RegisterSection("Notifications", buildSettingsSection, 60)
    end

    local function runSoon()
        if IgnoreAllChars._queueRan then return end
        if C_Timer and C_Timer.After then
            C_Timer.After(1, function() IgnoreAllChars:RunQueue() end)
        else
            IgnoreAllChars:RunQueue()
        end
    end
    hooksecurefunc(core, "_OnListUpdate", runSoon)

    if core._ready then runSoon() end

    if self:PlannedCount(self:CurrentCharKey()) > 0 and C_Timer and C_Timer.After then
        C_Timer.After(5, function()
            if not core._ready and core.RequestList then core:RequestList() end
        end)
    end
end
