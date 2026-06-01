# Nerzors Blacklist Keeper V2

> Remember the players you never want to group with again - and the good ones too.

**Nerzors Blacklist Keeper (NBK)** is a modular World of Warcraft addon for keeping a personal blacklist of players (with reasons, notes, mute flags and class info), sharing it with people you trust, and getting a heads-up the moment a blacklisted player shows up in your group, or in chat.

It also keeps a positive "Remember Me" list for the good ones, tracks your recent party-mates, and can prompt you to rate teammates after a Mythic+ run.

*   **Author:** Nerzors · [www.nerzors.de](https://www.nerzors.de/)
*   **Language:** English + Deutsch (auto-detected from your client locale)
*   **For Game-Version**: Currently for `WOW-RETAIL` only

***

## Features

*   **Blacklist** with reason presets, free-form notes, per-entry mute, pin, class detection and a sortable, searchable list window.
*   **Group warning** - chat message, popup and/or sound when a blacklisted player joins your group.
*   **Tooltip integration** - blacklist / remember-me info right in the unit tooltip.
*   **Chat filter** - optionally hide messages from blacklisted players, plus a configurable blocked-words / whitelist filter.
*   **Group Finder (LFG)** - warns when a blacklisted player appears in a Premade Group Finder listing or applies to your group.
*   **Recents** - tracks the last unique party-mates you grouped with.
*   **Remember Me** - a positive list with star ratings, notes and an optional post-Mythic+ "rate your group" prompt.
*   **Sharing / Sync** - peer-to-peer blacklist + remember-me sharing over the addon comm channel (whisper / guild), including per-entry **Auto-Sync**.
*   **Multi-list Export / Import** - export the blacklist or the remember-me list to a string; import auto-detects which list it is.

***

## Installation

1.  Extract so each folder lands directly in your AddOns directory:

```
   World of Warcraft/_retail_/Interface/AddOns/
   ├── NerzorsBlacklistKeeper_Data        (required - shared assets + libraries)
   ├── NerzorsBlacklistKeeper             (core)
   ├── NerzorsBlacklistKeeper_Tooltip
   ├── NerzorsBlacklistKeeper_ChatFilters
   ├── NerzorsBlacklistKeeper_GroupFinder
   ├── NerzorsBlacklistKeeper_Sync
   ├── NerzorsBlacklistKeeper_Recents
   └── NerzorsBlacklistKeeper_RememberMe
```

1.  `NerzorsBlacklistKeeper_Data` is a **hard dependency** for everything else - keep it enabled. The other sub-addons are optional: install only the features you want.

***

## Modules

| Folder                 |What it adds                                            |Required? |
| ---------------------- |------------------------------------------------------- |--------- |
| <code>_Data</code>     |Shared libraries, textures, fonts, sounds.              |<strong>Yes</strong> |
| <code>NerzorsBlacklistKeeper</code> |Core: blacklist, list window, settings, slash commands. |<strong>Yes</strong> |
| <code>_Tooltip</code>  |Blacklist / remember-me info in unit tooltips.          |Optional  |
| <code>_ChatFilters</code> |Hide blacklisted players' chat + blocked-words filter.  |Optional  |
| <code>_GroupFinder</code> |LFG / Premade Group Finder warnings.                    |Optional  |
| <code>_Sync</code>     |Peer-to-peer sharing + Auto-Sync.                       |Optional  |
| <code>_Recents</code>  |Recent party-mate tracking.                             |Optional  |
| <code>_RememberMe</code> |Positive list, star ratings, Mythic+ prompt.            |Optional  |

***

## Slash commands

| Command                        |Action                              |
| ------------------------------ |----------------------------------- |
| <code>/nbk</code>              |Open the main window                |
| <code>/nbk config</code>       |Open settings                       |
| <code>/nbk add name[-realm] [reason]</code> |Add a player                        |
| <code>/nbk removename[-realm]</code> |Remove a player                     |
| <code>/nbk check name[-realm]</code> |Check whether a player is listed    |
| <code>/nbk list</code>         |Print the blacklist to chat         |
| <code>/nbk share name[-realm]</code> |Share via whisper <em>(requires <code>_Sync</code>)</em> |
| <code>/nbk share guild</code>  |Broadcast to guild <em>(requires <code>_Sync</code>)</em> |
| <code>/nbk theme [name|list]</code> |Switch / list UI themes             |
| <code>/nbk news</code>         |Reopen the "What's new?" window     |

`/blacklistkeeper` works as a long-form alias for `/nbk`.

***

## Sharing & Auto-Sync

Sharing is peer-to-peer over WoW's addon comm channel - no server, nothing leaves the game. You control who you accept shares from (anyone / guild / friends / nobody) in the **Sharing** tab.

**Auto-Sync** (opt-in) pushes each newly blacklisted entry to your chosen recipients - your guild, online friends on your realm, or a custom name list - the moment you add it, as long as that entry is marked shareable.

> Note: Blizzard's anti-spam means addon whispers only reach recipients who are online and in a recent contact relationship (friend / guildmate / group / recently whispered). Guild channel is the most reliable.

***

## License

Bundled third-party libraries (LibStub, LibDeflate, CallbackHandler) keep their own respective licenses.

***

## Support & contact

*   Website: [www.nerzors.de](https://www.nerzors.de/)
*   NerzorsBlacklistKeeper: `nbk.addon@nerzors.de`
*   Github: [https://github.com/Nerzors/NerzorsBlacklistKeeper/issues](https://github.com/Nerzors/NerzorsBlacklistKeeper/issues)
*   General: `DEV@NERZORS.DE` · contact form at [nerzors.de/en/contact](https://nerzors.de/en/contact)
