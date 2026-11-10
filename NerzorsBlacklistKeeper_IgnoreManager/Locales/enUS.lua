local NBK = _G.NBK
if not NBK then return end

NBK:RegisterLocaleStrings("enUS", {

    ["All characters"] = true,

    ["Characters: %d"] = true,
    ["Snapshot from %s"] = true,
    ["Older than 30 days - log in on this character to update it."] = true,
    ["Ignored on: %d / %d"] = true,

    ["Log in once on each character so the overview is complete; a date in the warning colour is older than 30 days. Click a cell to change it - on other characters the change waits for their next login."] = true,
    ["Ignored"] = true,
    ["Not ignored"] = true,
    ["Planned: remove at next login"] = true,
    ["Planned: ignore at next login"] = true,
    ["Last attempt failed: the ignore list is full."] = true,
    ["Last attempt failed."] = true,
    ["Click to remove now"] = true,
    ["Click to ignore now"] = true,
    ["Click to remove at next login"] = true,
    ["Click to ignore at next login"] = true,
    ["Click to cancel"] = true,
    ["Planned changes: %d"] = true,
    ["Could not ignore %s - the ignore list is full."] = true,
    ["Ignore Manager - planned changes done: %d, failed: %d"] = true,

    ["Changes to this character's ignore list are planned: %d"] = true,
    ["planned on %s"] = true,
    ["Run planned changes automatically from now on"] = true,
    ["Run now"] = true,
    ["Later"] = true,
    ["Discard"] = true,
    ["Planned changes discarded: %d"] = true,
    ["Run planned ignore-list changes automatically at login"] = true,
    ["Changes you plan in the Ignore Manager for another character run at that character's next login - with this option right away, otherwise NBK asks first. The blacklist is never changed automatically."] = true,

    ["Ignore everywhere"] = true,
    ["Remove everywhere"] = true,
    ["Ignores the selected players on every character: right away on this one, at their next login on the others."] = true,
    ["Removes the selected players from every character's ignore list: right away on this one, at their next login on the others."] = true,
    ["Ignore %d selected players on all characters?"] = true,
    ["Remove %d selected players from all characters?"] = true,
    ["On this character, right away: %d"] = true,
    ["At the next login on %d other characters: %d"] = true,
    ["Planned changes cancelled: %d"] = true,
    ["Only %d more fit on this character's ignore list."] = true,
    ["Nothing to change - the selected players are already like that on every character."] = true,
    ["Ignore everywhere - ignored here: %d, planned for other characters: %d"] = true,
    ["Remove everywhere - removed here: %d, planned for other characters: %d"] = true,

    ["Players that no longer exist: %d"] = true,
    ["Clean up"] = true,
    ["No longer exists - the game removes it at this character's next login."] = true,
    ["No longer exists (reported by the game on %s)"] = true,
    ["These players no longer exist. Other characters still have them in their saved lists; the game removes them there at the next login. Remove them from the overview now?"] = true,
    ["Removed from the overview: %d"] = true,
}, true)
