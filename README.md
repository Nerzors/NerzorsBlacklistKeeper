# Nerzors Blacklist Keeper

> Remember the players you never want to group with again - and the good ones too.

**Nerzors Blacklist Keeper (NBK)** is a modular World of Warcraft addon for
keeping a personal blacklist of players (with reasons, notes, mute flags and
class info), sharing it with people you trust, and getting a heads-up the
moment a blacklisted player shows up in your group, on a nameplate, or in chat.

It also keeps a positive "Remember Me" list for the good ones, tracks your
recent party-mates, and can prompt you to rate teammates after a Mythic+ run.

> ### ⚠️ Heads up — this is a work in progress
>
> **NBK V2 is still in active development**, so a few things you'll spot in
> here aren't fully wired up yet. V2 is a ground-up rebuild of my old
> **NBK V1** — back then it wasn't modular at all, which is why V2 looks and
> behaves pretty differently under the hood.
>
> Long story short: **there won't be any more updates for NBK V1.** Its GitHub
> repo isn't public anymore either. Most of V1's features already made it into
> V2, so V1 is basically retired — no real reason to keep using it.

- **Author:** Nerzors · [www.nerzors.de](https://www.nerzors.de)
- **Language:** English + Deutsch (auto-detected from your client locale)
- **Versioning:** while in development it's `2.0.0-dev.<addon-version>`. Once it
  reaches a stable release the scheme switches to `<addon-version>-<wow-patch>` —
  e.g. `2.1.1-12.0.5` (addon version paired with the WoW patch it targets).

---

## Features

- **Blacklist** with reason presets, free-form notes, per-entry mute, pin,
  class detection and a sortable, searchable list window.
- **Group warning** - chat message, popup and/or sound when a blacklisted
  player joins your group.
- **Tooltip integration** - blacklist / remember-me info right in the unit tooltip.
- **Nameplates** - warning icon + name tint on blacklisted players (with an
  optional Plater hook script).
- **Chat filter** - optionally hide messages from blacklisted players, plus a
  configurable blocked-words / whitelist filter.
- **Group Finder (LFG)** - warns when a blacklisted player appears in a
  Premade Group Finder listing or applies to your group.
- **Recents** - tracks the last unique party-mates you grouped with.
- **Remember Me** - a positive list with star ratings, notes and an optional
  post-Mythic+ "rate your group" prompt.
- **Sharing / Sync** - peer-to-peer blacklist + remember-me sharing over the
  addon comm channel (whisper / guild), including per-entry **Auto-Sync**.
- **Multi-list Export / Import** - export the blacklist or the remember-me
  list to a string; import auto-detects which list it is.
- **Themes** - three built-in looks (Nerzors, Midnight, Sci-Fi), switchable
  live.
- **"What's new?" window** - opens once after every update.
- **Public API** for third-party addons (WeakAuras, Plater, custom UIs).

---

## Installation

1. Install from one of the **official sources** (see the `LICENSE.md` and
   `OFFICIAL-DOWNLOADS.md` for the authoritative list - CurseForge, GitHub
   Releases, the official download page).
2. Extract so each folder lands directly in your AddOns directory:

   ```
   World of Warcraft/_retail_/Interface/AddOns/
   ├── NerzorsBlacklistKeeper_Data        (required - shared assets + libraries)
   ├── NerzorsBlacklistKeeper             (core)
   ├── NerzorsBlacklistKeeper_Tooltip
   ├── NerzorsBlacklistKeeper_Nameplates
   ├── NerzorsBlacklistKeeper_ChatFilters
   ├── NerzorsBlacklistKeeper_GroupFinder
   ├── NerzorsBlacklistKeeper_Sync
   ├── NerzorsBlacklistKeeper_Recents
   └── NerzorsBlacklistKeeper_RememberMe
   ```

3. `NerzorsBlacklistKeeper_Data` is a **hard dependency** for everything else -
   keep it enabled. The other sub-addons are optional: install only the
   features you want.

---

## Modules

| Folder | What it adds | Required? |
| --- | --- | --- |
| `_Data` | Shared libraries, textures, fonts, sounds. | **Yes** |
| `NerzorsBlacklistKeeper` | Core: blacklist, list window, settings, slash commands. | **Yes** |
| `_Tooltip` | Blacklist / remember-me info in unit tooltips. | Optional |
| `_Nameplates` | Warning icon + name tint on nameplates (+ Plater hook). | Optional |
| `_ChatFilters` | Hide blacklisted players' chat + blocked-words filter. | Optional |
| `_GroupFinder` | LFG / Premade Group Finder warnings. | Optional |
| `_Sync` | Peer-to-peer sharing + Auto-Sync. | Optional |
| `_Recents` | Recent party-mate tracking. | Optional |
| `_RememberMe` | Positive list, star ratings, Mythic+ prompt. | Optional |

---

## Slash commands

| Command | Action |
| --- | --- |
| `/nbk` | Open the main window |
| `/nbk config` | Open settings |
| `/nbk add <name[-realm]> [reason]` | Add a player |
| `/nbk remove <name[-realm]>` | Remove a player |
| `/nbk check <name[-realm]>` | Check whether a player is listed |
| `/nbk list` | Print the blacklist to chat |
| `/nbk share <name[-realm]>` | Share via whisper *(requires `_Sync`)* |
| `/nbk share guild` | Broadcast to guild *(requires `_Sync`)* |
| `/nbk theme [name\|list]` | Switch / list UI themes |
| `/nbk news` | Reopen the "What's new?" window |

`/blacklistkeeper` works as a long-form alias for `/nbk`.

---

## Sharing & Auto-Sync

Sharing is peer-to-peer over WoW's addon comm channel - no server, nothing
leaves the game. You control who you accept shares from (anyone / guild /
friends / nobody) in the **Sharing** tab.

**Auto-Sync** (opt-in) pushes each newly blacklisted entry to your chosen
recipients - your guild, online friends on your realm, or a custom name list -
the moment you add it, as long as that entry is marked shareable.

> Note: Blizzard's anti-spam means addon whispers only reach recipients who
> are online and in a recent contact relationship (friend / guildmate /
> group / recently whispered). Guild channel is the most reliable.

---

## Public API

Other addons can query NBK and react to changes through a stable, versioned
read surface: **`LibNBKApi-1.0`** (also exposed as `NBK.API`).

```lua
local api = LibStub("LibNBKApi-1.0", true)
if api and api:IsBlacklisted("Playername", "Realm") then
    -- ...
end

api:RegisterCallback("BLACKLIST_ENTRY_ADDED", function(_, name, realm, entry)
    -- react to a new entry
end)
```

See `NerzorsBlacklistKeeper/Core/PublicAPI.lua` for the full surface
(read methods + callback events). The public API keeps its documentation
comments in release builds on purpose.

---

## License

This addon is distributed under the **Nerzors Addon NC-NRD-ND License**
(Non-Commercial / No Redistribution / No Derivatives) - see [`LICENSE.md`](LICENSE.md).

In short:
- ✅ Use it, back it up, and **show it off** in videos / streams (YouTube,
  Twitch, …) - including on monetized channels.
- ✅ Link people to the **official download sources**.
- ❌ Don't re-host, repackage or redistribute the files yourself.
- ❌ Don't create or publish modified / derivative versions.
- ❌ Don't reuse its code, art, icons or strings without written permission.

Bundled third-party libraries (LibStub, LibDeflate, CallbackHandler, …) keep
their own respective licenses.

---

## Support & contact

- Website: [www.nerzors.de](https://www.nerzors.de)
- NerzorsBlacklistKeeper: `nbk.addon@nerzors.de`
- General: `DEV@NERZORS.DE` · contact form at [nerzors.de/en/contact](https://nerzors.de/en/contact)
