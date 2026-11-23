local NBK = _G.NBK
if not NBK then return end

local IgnoreAllChars = NBK:GetModule("IgnoreAllChars")
if not IgnoreAllChars then return end

function IgnoreAllChars:ForgetDeleted(rows, alsoBlacklist)

    if NBK.RunAsCleanup and not NBK._removeBatch then
        return NBK:RunAsCleanup("deleted", function() self:ForgetDeleted(rows, alsoBlacklist) end)
    end
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

function IgnoreAllChars:ConfirmForgetDeleted()
    if self.ShowCleanup then self:ShowCleanup("gone") end
end
