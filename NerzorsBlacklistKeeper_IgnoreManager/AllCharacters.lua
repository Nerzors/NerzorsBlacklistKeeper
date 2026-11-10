local NBK = _G.NBK
if not NBK then return end

local IgnoreAllChars = NBK:RegisterModule("IgnoreAllChars")

IgnoreAllChars.STALE_AFTER = 30 * 86400

local function chars()
    local ig = NBK.db and NBK.db.ignore
    return ig and ig.chars or {}
end

local function deletedSet()
    local ig = NBK.db and NBK.db.ignore
    return ig and ig.deleted or {}
end

function IgnoreAllChars:DeletedAt(key) return deletedSet()[key] end

function IgnoreAllChars:CurrentCharKey()
    return NBK:PlayerFullName()
end

function IgnoreAllChars:GetCharacters()
    local out, me, now = {}, self:CurrentCharKey(), time()
    for key, c in pairs(chars()) do
        local name, realm = strsplit("-", key, 2)
        local count = 0
        for _ in pairs(c.names or {}) do count = count + 1 end
        out[#out + 1] = {
            key       = key,
            name      = name,
            realm     = realm or "",
            class     = c.class,
            scannedAt = c.scannedAt,
            count     = count,
            planned   = self.PlannedCount and self:PlannedCount(key) or 0,
            current   = (key == me),
            stale     = not c.scannedAt or (now - c.scannedAt > self.STALE_AFTER),
        }
    end
    table.sort(out, function(a, b)
        if a.current ~= b.current then return a.current end
        if a.name ~= b.name then return a.name < b.name end
        return a.realm < b.realm
    end)
    return out
end

function IgnoreAllChars:GetRows(characters)
    local rows, byKey, all, deleted = {}, {}, chars(), deletedSet()
    for _, ch in ipairs(characters or self:GetCharacters()) do
        local c = all[ch.key]
        for key, rec in pairs(c and c.names or {}) do
            local row = byKey[key]
            if not row then
                local name, realm = strsplit("-", rec.full or key, 2)
                realm = realm or ch.realm
                local bl = NBK:GetPlayer(name, realm)
                row = {
                    key   = key,
                    name  = (bl and bl.name) or name,
                    realm = (bl and bl.realm) or realm,
                    class = bl and bl.class,
                    bl    = bl,
                    on    = {},
                    onCount = 0,
                    gone  = {},
                    goneCount = 0,
                    deletedAt = deleted[key],
                }
                byKey[key] = row
                rows[#rows + 1] = row
            end
            row.on[ch.key] = true
            row.onCount = row.onCount + 1
            if row.deletedAt and (c.scannedAt or 0) < row.deletedAt then
                row.gone[ch.key] = true
                row.goneCount = row.goneCount + 1
            end
        end
    end
    for _, row in ipairs(rows) do
        row.deleted = row.goneCount > 0 and row.goneCount == row.onCount
    end
    table.sort(rows, function(a, b) return (a.name or ""):lower() < (b.name or ""):lower() end)
    return rows
end

function IgnoreAllChars:OnEnable()
    local core = NBK:GetModule("IgnoreManager")
    local tab  = NBK:GetModule("IgnoreTab")
    if not (core and core:IsAvailable() and tab and tab.RegisterView) then return end
    self:_InitQueue()
    tab:RegisterView({
        key      = "all",
        labelKey = "All characters",
        order    = 20,
        build    = function(parent) return IgnoreAllChars:_BuildView(parent) end,
        refresh  = function() IgnoreAllChars:Refresh() end,
    })
end
