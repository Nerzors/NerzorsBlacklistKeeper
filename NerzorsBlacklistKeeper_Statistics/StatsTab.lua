local NBK = _G.NBK
if not NBK then return end

local NUL = LibStub("NerzorsUILib-1.0")

local StatsTab = NBK:RegisterModule("StatisticsTab")

local GAP        = 10
local CARD_CHROME = 40
local TILE_H     = 58
local MONTH_H    = 110
local TWO_COL_AT = 700

local function L(key, fallback)
    local s = NBK.L and NBK.L[key]
    return s or fallback or key
end

local ui = {}

local pending

local function sizeRankedCard(card, chart)
    card:SetHeight(chart:GetNaturalHeight() + CARD_CHROME)
end

function StatsTab:_BuildTab(parent)
    if ui.root then return ui.root end
    local emptyText = L("No data yet", "No data yet")

    if pending then
        pending:Hide()
        pending:ClearAllPoints()
        pending:SetParent(nil)
        pending = nil
    end
    local t = {}

    local root = CreateFrame("Frame", nil, parent)
    root:SetAllPoints()
    pending = root
    t.root  = root

    local scroll = CreateFrame("ScrollFrame", nil, root, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT")
    scroll:SetPoint("BOTTOMRIGHT", -22, 0)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    NUL:_AttachThemedScrollBar(scroll, root)
    t.scroll, t.content = scroll, content

    t.tiles = {
        NUL:StatTile(content, { value = 0, label = L("Entries", "Entries"),            height = TILE_H }),
        NUL:StatTile(content, { value = 0, label = L("New (30 days)", "New (30 days)"), height = TILE_H }),
        NUL:StatTile(content, { value = 0, label = L("Encounters", "Encounters"),      height = TILE_H }),
        NUL:StatTile(content, { value = 0, label = L("Messages", "Messages"),          height = TILE_H }),
    }

    t.monthCard  = NUL:Card(content, { title = L("Entries per month", "Entries per month"),
                                       height = MONTH_H + CARD_CHROME })
    t.monthChart = NUL:BarChart(t.monthCard.content, { height = MONTH_H, emptyText = emptyText })
    t.monthChart:SetPoint("TOPLEFT")
    t.monthChart:SetPoint("TOPRIGHT")

    local function rankedCard(titleKey, titleFallback)
        local card  = NUL:Card(content, { title = L(titleKey, titleFallback) })
        local chart = NUL:RankedBars(card.content, { emptyText = emptyText })
        chart:SetPoint("TOPLEFT")
        chart:SetPoint("TOPRIGHT")
        chart:SetHeight(1)
        return card, chart
    end

    t.reasonsCard,    t.reasonsChart    = rankedCard("Top reasons",      "Top reasons")
    t.zonesCard,      t.zonesChart      = rankedCard("Top zones",        "Top zones")
    t.classCard,      t.classChart      = rankedCard("By class",         "By class")
    t.encountersCard, t.encountersChart = rankedCard("Most encountered", "Most encountered")

    t.realmsCard, t.realmsChart = rankedCard("Top realms", "Top realms")

    t.chatCard = NUL:Card(content, { title = L("Chat impact", "Chat impact") })
    local cc = t.chatCard.content
    t.chatTiles = {
        NUL:StatTile(cc, { value = 0, label = L("Censored", "Censored"), height = TILE_H }),
        NUL:StatTile(cc, { value = 0, label = L("Hidden", "Hidden"),     height = TILE_H }),
        NUL:StatTile(cc, { value = 0, label = L("Archived", "Archived"), height = TILE_H }),
    }
    t.channelChart = NUL:RankedBars(cc, { emptyText = emptyText })
    t.channelChart:SetHeight(1)

    scroll:HookScript("OnSizeChanged", function(_, w)
        if w and w > 1 then
            content:SetWidth(w)
            StatsTab:_Layout()
        end
    end)

    ui, pending = t, nil

    self:Render()
    return root
end

function StatsTab:_Layout()
    local content = ui.content
    if not content then return end
    local w = content:GetWidth() or 0
    if w <= 1 then return end

    local twoCol = w >= TWO_COL_AT
    local colW   = twoCol and math.floor((w - GAP) / 2) or w
    local y      = 0

    local tileW = math.floor((w - GAP * 3) / 4)
    for i, tile in ipairs(ui.tiles) do
        tile:SetWidth(tileW)
        tile:ClearAllPoints()
        tile:SetPoint("TOPLEFT", content, "TOPLEFT", (i - 1) * (tileW + GAP), -y)
    end
    y = y + TILE_H + GAP

    ui.monthCard:SetWidth(w)
    ui.monthCard:ClearAllPoints()
    ui.monthCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
    y = y + ui.monthCard:GetHeight() + GAP

    local function placePair(a, b)
        if twoCol then
            a:SetWidth(colW); a:ClearAllPoints()
            a:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            b:SetWidth(colW); b:ClearAllPoints()
            b:SetPoint("TOPLEFT", content, "TOPLEFT", colW + GAP, -y)
            y = y + math.max(a:GetHeight(), b:GetHeight()) + GAP
        else
            a:SetWidth(w); a:ClearAllPoints()
            a:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            y = y + a:GetHeight() + GAP
            b:SetWidth(w); b:ClearAllPoints()
            b:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            y = y + b:GetHeight() + GAP
        end
    end
    placePair(ui.reasonsCard, ui.zonesCard)
    placePair(ui.classCard,   ui.encountersCard)

    ui.realmsCard:SetWidth(w)
    ui.realmsCard:ClearAllPoints()
    ui.realmsCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
    y = y + ui.realmsCard:GetHeight() + GAP

    if ui.chatCard:IsShown() then
        ui.chatCard:SetWidth(w)
        ui.chatCard:ClearAllPoints()
        ui.chatCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)

        local cw      = math.max(1, w - 20)
        local shown   = {}
        for _, t in ipairs(ui.chatTiles) do
            if t:IsShown() then shown[#shown + 1] = t end
        end
        local innerY = 0
        if #shown > 0 then
            local tw = math.floor((cw - GAP * (#shown - 1)) / #shown)
            for i, t in ipairs(shown) do
                t:SetWidth(tw)
                t:ClearAllPoints()
                t:SetPoint("TOPLEFT", ui.chatCard.content, "TOPLEFT", (i - 1) * (tw + GAP), 0)
            end
            innerY = TILE_H + GAP
        end

        local chH = 0
        if ui.channelChart:IsShown() then
            ui.channelChart:ClearAllPoints()
            ui.channelChart:SetPoint("TOPLEFT",  ui.chatCard.content, "TOPLEFT",  0, -innerY)
            ui.channelChart:SetPoint("TOPRIGHT", ui.chatCard.content, "TOPRIGHT", 0, -innerY)
            chH = ui.channelChart:GetNaturalHeight()
            ui.channelChart:SetHeight(chH)
        end

        ui.chatCard:SetHeight(innerY + chH + CARD_CHROME)
        y = y + ui.chatCard:GetHeight() + GAP
    end

    content:SetHeight(math.max(1, y))
end

function StatsTab:Render()
    if not ui.root then return end
    local Statistics = NBK:GetModule("Statistics")
    if not Statistics then return end
    local s = Statistics:Compute()

    ui.tiles[1]:SetValue(s.total      or 0)
    ui.tiles[2]:SetValue(s.added30    or 0)
    ui.tiles[3]:SetValue(s.encounters or 0)
    ui.tiles[4]:SetValue((s.chat and s.chat.archived) or 0)

    ui.monthChart:SetData(s.perMonth)

    ui.reasonsChart:SetData(s.topReasons)
    ui.zonesChart:SetData(s.topZones)
    ui.classChart:SetData(s.byClass)
    ui.encountersChart:SetData(s.topEncounters)
    ui.realmsChart:SetData(s.topRealms)

    sizeRankedCard(ui.reasonsCard,    ui.reasonsChart)
    sizeRankedCard(ui.zonesCard,      ui.zonesChart)
    sizeRankedCard(ui.classCard,      ui.classChart)
    sizeRankedCard(ui.encountersCard, ui.encountersChart)
    sizeRankedCard(ui.realmsCard,     ui.realmsChart)
    ui.reasonsChart:SetHeight(ui.reasonsChart:GetNaturalHeight())
    ui.zonesChart:SetHeight(ui.zonesChart:GetNaturalHeight())
    ui.classChart:SetHeight(ui.classChart:GetNaturalHeight())
    ui.encountersChart:SetHeight(ui.encountersChart:GetNaturalHeight())
    ui.realmsChart:SetHeight(ui.realmsChart:GetNaturalHeight())

    local chat = s.chat or {}
    ui.chatTiles[1]:SetShown(chat.hasFilters == true)
    ui.chatTiles[2]:SetShown(chat.hasFilters == true)
    ui.chatTiles[3]:SetShown(chat.hasHistory == true)
    if chat.hasFilters then
        ui.chatTiles[1]:SetValue(chat.censored or 0)
        ui.chatTiles[2]:SetValue(chat.hidden   or 0)
    end
    if chat.hasHistory then
        ui.chatTiles[3]:SetValue(chat.archived or 0)
        ui.channelChart:SetData(chat.byChannel)
    end
    ui.channelChart:SetShown(chat.hasHistory == true)
    ui.chatCard:SetShown((chat.hasFilters or chat.hasHistory) and true or false)

    self:_Layout()
end

local function widgetsAvailable()
    return type(NUL.Card)      == "function"
       and type(NUL.StatTile)  == "function"
       and type(NUL.BarChart)  == "function"
       and type(NUL.RankedBars) == "function"
end

function StatsTab:OnEnable()
    if not widgetsAvailable() then
        NBK:Print(L("Statistics needs an updated Data folder",
                    "Statistics: please update the NerzorsBlacklistKeeper_Data folder."))
        return
    end
    local lw = NBK:GetModule("ListWindow")
    if lw and lw.RegisterTab then
        lw:RegisterTab({
            key      = "statistics",
            labelKey = "Statistics",
            order    = 40,
            build    = function(parent) return StatsTab:_BuildTab(parent) end,
            refresh  = function() StatsTab:Render() end,
            onShow   = function() StatsTab:Render() end,
        })
    end
end
