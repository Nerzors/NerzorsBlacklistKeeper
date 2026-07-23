local NBK = _G.NBK
if not NBK then return end

NBK:RegisterAddonDB({
    addonName = "NerzorsBlacklistKeeper_Sync",
    key       = "Sync",
    svName    = "NerzorsBlacklistKeeperSyncDB",
    version   = 1,
    defaults  = {
        enabled          = true,
        acceptFrom       = "friends",
        autoShow         = true,
        announceSend     = true,
        defaultShareable = true,
        exportSharedOnly = false,
        debug            = false,

        autoSync         = false,
        autoSyncMode     = "guild",

        autoSyncRecipients = {},
    },

    onFirstLoad = function(db)
        if type(NBKDB) ~= "table" or type(NBKDB.settings) ~= "table" then return end
        local legacy = NBKDB.settings.sync
        if type(legacy) ~= "table" then return end
        if legacy.enabled          ~= nil then db.enabled          = legacy.enabled and true or false end
        if legacy.acceptFrom       ~= nil then db.acceptFrom       = legacy.acceptFrom end
        if legacy.autoShow         ~= nil then db.autoShow         = legacy.autoShow and true or false end
        if legacy.announceSend     ~= nil then db.announceSend     = legacy.announceSend and true or false end
        if legacy.defaultShareable ~= nil then db.defaultShareable = legacy.defaultShareable and true or false end
        if legacy.exportSharedOnly ~= nil then db.exportSharedOnly = legacy.exportSharedOnly and true or false end
        NBKDB.settings.sync = nil
    end,
})

local Sync = NBK:RegisterModule("Sync")

local PREFIX        = "NBK"
local PROTO_VERSION = "1"
local MAX_BYTES     = 240
local SEND_INTERVAL = 0.18

local CHUNK_PAYLOAD = 200

local inbox = {}

local outQueue = {}
local pacer

local function sidNew()

    return string.format("%08x", math.random(0, 0x7FFFFFFF))
end

local function inboxKey(sender, sid)
    return sender .. "\031" .. sid
end

local function cleanupInbox(key)
    inbox[key] = nil
end

local function syncSettings()
    return NBK:GetAddonDB("Sync") or {}
end

local function syncDebug(...)
    if syncSettings().debug then
        NBK:Print("|cff888c99[Sync debug]|r", ...)
    end
end

local function sendRaw(message, channel, target)
    if ChatThrottleLib and ChatThrottleLib.SendAddonMessage then
        ChatThrottleLib:SendAddonMessage("NORMAL", PREFIX, message, channel, target)
    else
        C_ChatInfo.SendAddonMessage(PREFIX, message, channel, target)
    end
end

local function ensurePacer()
    if pacer then return end
    pacer = CreateFrame("Frame")
    local elapsedAcc = 0
    pacer:SetScript("OnUpdate", function(_, dt)
        elapsedAcc = elapsedAcc + dt
        if elapsedAcc < SEND_INTERVAL then return end
        elapsedAcc = 0
        local item = table.remove(outQueue, 1)
        if item then
            sendRaw(item.msg, item.channel, item.target)
        else
            pacer:SetScript("OnUpdate", nil)
            pacer = nil
        end
    end)
end

local function enqueue(msg, channel, target)
    if ChatThrottleLib and ChatThrottleLib.SendAddonMessage then
        sendRaw(msg, channel, target)
        return
    end
    table.insert(outQueue, { msg = msg, channel = channel, target = target })
    ensurePacer()
end

local function currentEntryLines(listId)
    local text = NBK:ExportString({ list = listId or "blacklist", sharedOnly = true })
    local lines = {}
    local first = true
    for line in text:gmatch("([^\n]+)") do
        if first then
            first = false
        else
            table.insert(lines, line)
        end
    end
    return lines
end

local function countPrivate(listId)
    if (listId or "blacklist") ~= "blacklist" then return 0 end
    local n = 0
    local entries = NBK.db and NBK.db.entries or {}
    for _, e in pairs(entries) do
        if e.shareable == false then n = n + 1 end
    end
    return n
end

local function validateTarget(channel, target)
    if channel == "WHISPER" then
        if not target or target == "" then return false, "missing target" end
        return true
    elseif channel == "GUILD" then
        if not IsInGuild() then return false, "not in a guild" end
        return true
    elseif channel == "PARTY" or channel == "RAID" then
        if not IsInGroup() then return false, "not in a group" end
        return true
    end
    return false, "unsupported channel"
end

function NBK:Share(channel, target, listId)
    local settings = syncSettings()
    if settings.enabled == false then
        return false, "sync disabled"
    end

    listId = listId or "blacklist"
    if not NBK:GetListType(listId) then
        return false, "unknown list: " .. tostring(listId)
    end

    local ok, err = validateTarget(channel, target)
    if not ok then return false, err end

    local lines   = currentEntryLines(listId)
    local private = countPrivate(listId)
    if #lines == 0 then
        if private > 0 then
            return false, "no shareable entries (all marked private)"
        end
        return false, "list is empty"
    end

    local sid   = sidNew()
    local total = #lines
    local ver   = tostring(NBK.version or "0")

    syncDebug(("sending session sid=%s list=%s total=%d via %s%s"):format(
        sid, listId, total, channel, target and (" → " .. target) or ""))

    enqueue(table.concat({ PROTO_VERSION, "O", sid, tostring(total), ver, listId }, "|"),
        channel, target)

    local sent = 0
    for i, line in ipairs(lines) do
        local msg = table.concat({ PROTO_VERSION, "E", sid, tostring(i), line }, "|")
        if #msg <= MAX_BYTES then
            enqueue(msg, channel, target)
        else

            local parts = math.ceil(#line / CHUNK_PAYLOAD)
            for p = 1, parts do
                local slice = line:sub((p - 1) * CHUNK_PAYLOAD + 1, p * CHUNK_PAYLOAD)
                enqueue(table.concat({
                    PROTO_VERSION, "C", sid, tostring(i),
                    tostring(p), tostring(parts), slice,
                }, "|"), channel, target)
            end
        end
        sent = sent + 1
    end

    enqueue(table.concat({ PROTO_VERSION, "F", sid, tostring(sent) }, "|"),
        channel, target)

    if settings.announceSend ~= false then
        local L = NBK.L
        local where = (channel == "WHISPER") and target
                  or  (channel == "GUILD") and "guild"
                  or  channel:lower()
        NBK:Print((L["Shared %d entries with %s."] or "Shared %d entries with %s."):format(sent, where))
        if private > 0 then
            NBK:Print((L["%d private entries held back."] or "%d private entries held back."):format(private))
        end

        if channel == "WHISPER" and not NBK._whisperHintShown then
            NBK._whisperHintShown = true
            NBK:Print("|cff888c99" ..
                (L["Tip: addon-whispers need the recipient online + a recent contact relationship (friend / guildmate / group / recent /w). If they see nothing, send them a normal whisper first or use Guild channel."]
                 or "Tip: addon-whispers need the recipient online + a recent contact relationship (friend / guildmate / group / recent /w). If they see nothing, send them a normal whisper first or use Guild channel.")
                .. "|r")
        end
    end

    return true, sent
end

local function serializeSingleRow(entry, listId)
    local spec = NBK:GetListType(listId)
    if not spec then return nil end
    local raw = spec.serializeRow(entry) or {}
    local escaped = {}
    for i = 1, #raw do escaped[i] = NBK:EscapeField(raw[i]) end
    return table.concat(escaped, "|")
end

local function pushSingleEntry(channel, target, entry, listId)
    listId = listId or "blacklist"
    local settings = syncSettings()
    if settings.enabled == false then return false, "sync disabled" end

    local ok, err = validateTarget(channel, target)
    if not ok then return false, err end

    local line = serializeSingleRow(entry, listId)
    if not line or line == "" then return false, "could not serialize entry" end

    local sid = sidNew()
    local ver = tostring(NBK.version or "0")

    syncDebug(("auto-push sid=%s list=%s entry=%s-%s via %s%s"):format(
        sid, listId, entry.name or "?", entry.realm or "?",
        channel, target and (" → " .. target) or ""))

    enqueue(table.concat({ PROTO_VERSION, "P", sid, "1", ver, listId }, "|"),
        channel, target)

    local emsg = table.concat({ PROTO_VERSION, "E", sid, "1", line }, "|")
    if #emsg <= MAX_BYTES then
        enqueue(emsg, channel, target)
    else
        local parts = math.ceil(#line / CHUNK_PAYLOAD)
        for p = 1, parts do
            local slice = line:sub((p - 1) * CHUNK_PAYLOAD + 1, p * CHUNK_PAYLOAD)
            enqueue(table.concat({
                PROTO_VERSION, "C", sid, "1", tostring(p), tostring(parts), slice,
            }, "|"), channel, target)
        end
    end

    enqueue(table.concat({ PROTO_VERSION, "F", sid, "1" }, "|"), channel, target)
    return true
end

local function dispatchAutoSync(entry)
    local s = syncSettings()
    if s.autoSync ~= true then return end
    if entry.shareable == false then return end

    local mode = s.autoSyncMode or "guild"
    if mode == "guild" then
        if IsInGuild and IsInGuild() then
            pushSingleEntry("GUILD", nil, entry, "blacklist")
        end

    elseif mode == "friends" then

        local myRealm = GetNormalizedRealmName() or ""
        local seen = {}
        local function pushFriend(name)
            if not name or name == "" or seen[name] then return end
            seen[name] = true
            pushSingleEntry("WHISPER", name, entry, "blacklist")
        end
        if BNGetNumFriends then
            for i = 1, BNGetNumFriends() do
                if C_BattleNet and C_BattleNet.GetFriendAccountInfo then
                    local info = C_BattleNet.GetFriendAccountInfo(i)
                    local game = info and info.gameAccountInfo
                    if game and game.isOnline and game.characterName
                       and (game.realmName or "") == myRealm then
                        pushFriend(game.characterName)
                    end
                end
            end
        end
        if C_FriendList and C_FriendList.GetNumFriends then
            for i = 1, C_FriendList.GetNumFriends() do
                local info = C_FriendList.GetFriendInfoByIndex(i)
                if info and info.connected and info.name then
                    pushFriend(info.name)
                end
            end
        end

    elseif mode == "specific" then
        local list = s.autoSyncRecipients or {}
        for _, rec in ipairs(list) do
            if rec.enabled and rec.key and rec.key ~= "" then
                pushSingleEntry("WHISPER", rec.key, entry, "blacklist")
            end
        end
    end
end

NBK._SyncDispatchAutoSync = dispatchAutoSync

local function isInOurGuild(senderFull, senderName)
    if not IsInGuild or not IsInGuild() then return false end
    if not GetNumGuildMembers or not GetGuildRosterInfo then return false end
    local num = GetNumGuildMembers() or 0
    for i = 1, num do
        local name = GetGuildRosterInfo(i)
        if name and (name == senderFull or name:match("^([^%-]+)") == senderName) then
            return true
        end
    end
    return false
end

local function isFriend(senderFull, senderName)
    if BNGetNumFriends then
        local bnTotal = BNGetNumFriends()
        for i = 1, bnTotal do
            if C_BattleNet and C_BattleNet.GetFriendAccountInfo then
                local info = C_BattleNet.GetFriendAccountInfo(i)
                local game = info and info.gameAccountInfo
                if game and game.characterName and game.characterName == senderName then
                    return true
                end
            end
        end
    end
    if C_FriendList and C_FriendList.GetNumFriends then
        local n = C_FriendList.GetNumFriends()
        for i = 1, n do
            local info = C_FriendList.GetFriendInfoByIndex(i)
            local n2 = info and (info.name or info)
            if n2 == senderName or n2 == senderFull then return true end
        end
    end
    return false
end

local function senderAllowed(senderFull, channel)
    local settings = syncSettings()
    if settings.enabled == false then return false, "sync disabled" end
    local policy = settings.acceptFrom or "friends"

    if policy == "none"   then return false, "policy=none" end
    if policy == "anyone" then return true,  "policy=anyone" end

    local senderName = senderFull:match("^([^%-]+)") or senderFull

    if channel == "GUILD" and isInOurGuild(senderFull, senderName) then
        return true, "guild member via GUILD"
    end

    if policy == "guild" then
        if isInOurGuild(senderFull, senderName) then
            return true, "guild member"
        end
        return false, "policy=guild, sender not in guild"
    end

    if policy == "friends" then
        if isFriend(senderFull, senderName) then
            return true, "friend"
        end

        if isInOurGuild(senderFull, senderName) then
            return true, "guild member (under friends policy)"
        end
        return false, "policy=friends, sender not friend or guildmate"
    end

    return false, "unknown policy: " .. tostring(policy)
end

local autoPopup
local autoPopupQueue = {}

local function autoPopupApply(f, apply)
    local cur = f._current
    if cur and apply then

        local spec = NBK:GetListType(cur.listId or "blacklist")
        if spec then spec.applyEntry(cur.entry, "merge") end
        local lw = NBK:GetModule("ListWindow")
        if lw and lw.Refresh then lw:Refresh() end
    end
    f._current = nil
    f:_showNext()
end

local function buildAutoSyncPopup()
    if autoPopup then return autoPopup end
    local NUL = LibStub("NerzorsUILib-1.0")
    local L = NBK.L

    local f = NUL:DetailDialog({
        name        = "NBKAutoSyncPopup",
        title       = L["Auto-Sync blacklist push"] or "Auto-Sync blacklist push",
        width       = 460,
        strata      = "DIALOG",
        accent      = "primary",
        acceptLabel = L["Add to blacklist"] or "Add to blacklist",
        cancelLabel = L["Decline"]           or "Decline",
        onAccept    = function(self) autoPopupApply(self, true)  end,
        onCancel    = function(self) autoPopupApply(self, false) end,
    })
    f:SetFrameLevel(220)

    function f:_showNext()
        local next_ = table.remove(autoPopupQueue, 1)
        if not next_ then self:Hide(); return end
        self._current = next_
        local L2     = NBK.L
        local entry  = next_.entry or {}
        local hex    = (entry.class and NBK:GetClassHex(entry.class)) or "ffffff"

        self:SetHeadline(("|cff%s%s|r-%s"):format(
            hex, entry.name or "?", entry.realm or "?"))

        local reasonText = (entry.reason and entry.reason ~= "") and entry.reason
                                                                  or (L2["no reason logged"] or "-")
        self:SetDetails({
            { label = L2["From"]   or "From",   value = next_.sender or "?" },
            { label = L2["Reason"] or "Reason", value = reasonText },

            { label = L2["Note"]   or "Note",   value = entry.notes or "" },
        })
    end

    autoPopup = f
    return f
end

local function showAutoSyncPopup(senderFull, entry, listId)
    table.insert(autoPopupQueue, { sender = senderFull, entry = entry, listId = listId })
    local f = buildAutoSyncPopup()
    if f:IsShown() then return end
    f:_showNext()
    f:Show()
end

local function finalize(key)
    local session = inbox[key]
    if not session then return end
    inbox[key] = nil

    local L = NBK.L
    local lines = session.lines or {}
    local count = #lines
    if count == 0 then
        NBK:Print((L["%s sent an empty share."] or "%s sent an empty share."):format(session.sender))
        return
    end

    local listId = session.listId or "blacklist"

    if session.kind == "auto" then
        local spec = NBK:GetListType(listId)
        if not spec then
            syncDebug("auto-push dropped: unknown list", listId)
            return
        end

        local text = "!NBK1!|" .. listId .. "\n" .. table.concat(lines, "\n")
        local parsed = NBK:ParseImport(text)
        local entry  = parsed and parsed.entries and parsed.entries[1]
        if not entry then
            syncDebug("auto-push dropped: failed to parse entry from", session.sender)
            return
        end
        NBK:Print((L["%s auto-shared %s-%s."] or "%s auto-shared %s-%s.")
            :format(session.sender, entry.name or "?", entry.realm or "?"))
        showAutoSyncPopup(session.sender, entry, listId)
        return
    end

    local text = "!NBK1!|" .. listId .. "\n" .. table.concat(lines, "\n")

    local listSpec  = NBK:GetListType(listId)
    local listLabel = (listSpec and listSpec.label) or listId
    NBK:Print((L["%s shared %d entries (%s)."]
        or "%s shared %d entries (%s)."):format(session.sender, count, listLabel))

    local settings = syncSettings()
    if settings.autoShow == false then
        NBK._pendingShare = { sender = session.sender, text = text, count = count }
        NBK:Print(L["Use /nbk share show to review."] or "Use /nbk share show to review.")
        return
    end

    local Config = NBK:GetModule("Config")
    if Config and Config.ShowImportDialogWithText then
        Config:ShowImportDialogWithText(text, session.sender)
    elseif Config and Config.ShowImportDialog then
        Config:ShowImportDialog()
        NBK._pendingShare = { sender = session.sender, text = text, count = count }
    end
end

local function handleMessage(message, channel, senderFull)
    local v, t, sid, rest = message:match("^([^|]+)|([^|]+)|([^|]+)|?(.*)$")
    if v ~= PROTO_VERSION then
        syncDebug("dropped: protocol mismatch from", senderFull, "via", channel)
        return
    end
    if not t or not sid then return end

    local me = UnitName("player") or ""
    local meRealm = GetNormalizedRealmName() or ""
    local meFull  = me .. "-" .. meRealm
    if senderFull == meFull or senderFull == me then return end

    local allowed, why = senderAllowed(senderFull, channel)
    if not allowed then
        syncDebug(("dropped %s from %s via %s (%s)"):format(t, senderFull, channel, why or "?"))
        return
    end
    syncDebug(("accepted %s from %s via %s (%s)"):format(t, senderFull, channel, why or "?"))

    local key = inboxKey(senderFull, sid)

    if t == "O" or t == "P" then

        local total, ver, list = rest:match("^([^|]+)|([^|]+)|?(.*)$")
        inbox[key] = {
            sender  = senderFull,
            channel = channel,
            sid     = sid,
            total   = tonumber(total) or 0,
            version = ver,
            listId  = (list ~= nil and list ~= "" and list) or "blacklist",
            kind    = (t == "P") and "auto" or "bulk",
            lines   = {},
            startAt = GetTime(),
        }
        C_Timer.After(60, function()
            if inbox[key] and inbox[key].startAt and (GetTime() - inbox[key].startAt) >= 60 then
                cleanupInbox(key)
            end
        end)

    elseif t == "E" then
        local session = inbox[key]
        if not session then return end

        local _, entryLine = rest:match("^([^|]+)|(.*)$")
        if entryLine and entryLine ~= "" then
            table.insert(session.lines, entryLine)
        end

    elseif t == "C" then
        local session = inbox[key]
        if not session then return end

        local idx, part, parts, data = rest:match("^([^|]+)|([^|]+)|([^|]+)|(.*)$")
        idx, part, parts = tonumber(idx), tonumber(part), tonumber(parts)
        if not idx or not part or not parts then return end

        session.chunks = session.chunks or {}
        local buf = session.chunks[idx]
        if not buf then
            buf = { parts = parts, have = 0, data = {} }
            session.chunks[idx] = buf
        end

        if not buf.data[part] then
            buf.data[part] = data or ""
            buf.have = buf.have + 1
        end

        if buf.have >= buf.parts then
            table.insert(session.lines, table.concat(buf.data, "", 1, buf.parts))
            session.chunks[idx] = nil
        end

    elseif t == "F" then
        local session = inbox[key]
        if not session then return end
        finalize(key)
    end
end

function Sync:OnInitialize()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    end
end

function Sync:OnEnable()
    NBK:RegisterEvent("CHAT_MSG_ADDON", function(_, prefix, message, channel, sender)
        if prefix ~= PREFIX then return end

        syncDebug(("event arrived: channel=%s sender=%s len=%d"):format(
            channel or "?", sender or "?", #(message or "")))
        local ok, err = pcall(handleMessage, message, channel, sender)
        if not ok then
            NBK:Print("sync handler error:", err)
        end
    end)

    local LibStub = _G.LibStub
    local Api = LibStub and LibStub("LibNBKApi-1.0", true)
    if Api and Api.RegisterCallback and NBK._SyncDispatchAutoSync then
        Api:RegisterCallback("BLACKLIST_ENTRY_ADDED", function(_, name, realm, entry)

            local fname, frealm = name, realm
            if (not fname or fname == "") and entry then
                fname, frealm = entry.name, entry.realm
            end
            C_Timer.After(0, function()
                local fresh = (fname and NBK.GetPlayer) and NBK:GetPlayer(fname, frealm) or entry
                if fresh then NBK._SyncDispatchAutoSync(fresh) end
            end)
        end)
    end
end

function NBK:ShowPendingShare()
    local pending = self._pendingShare
    if not pending then
        self:Print("no pending share")
        return
    end
    local Config = self:GetModule("Config")
    if Config and Config.ShowImportDialogWithText then
        Config:ShowImportDialogWithText(pending.text, pending.sender)
    end
end
