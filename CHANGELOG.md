# What's new? (Last 3 Changes/Updates)

## 2.0.0-dev.0.46.0 - Broker bar + multi-select

### New
- **add Patch**: 12.1.5
- **Add WoW:Forever Support**
- **Data-broker support (LibDataBroker).** NBK now shows up on Titan Panel,
  ElvUI data texts and similar bars as a button - alongside the minimap icon.
  Left-click opens the list, right-click the settings.
- **Multi-select on the blacklist.** A new "Select" button reveals checkboxes:
  mark several entries and delete them together, or (with Sync installed) mark
  them shareable/private. Plus "select all/none".

---

## 2.0.0-dev.0.45.0 (by Veplo)
### New
- Statistics: "Top realms" card. Shows which realms your blacklist spans, as a ranked bar list just like top reasons and zones.
- NBK now appears in the game's settings. Options > AddOns has an NBK entry with a button that opens the addon's settings - where you'd look first for any addon.

### Fixed
- small other thinks

## 2.0.0-dev.0.44.0 - Fixes

### Fixed
- **Lua error from Message History in dungeons/raids** (`attempt to perform string conversion on a secret string value`). The history was reading the protected in-instance chat data directly, it now gets those messages through the normal chat filter instead - (Thanks @cellcubed for Report.)
- **"What's new?" showed English on German clients.** The language wasn't detected correctly; localised text now displays properly.
- **Login error** about the ignore list (`unknown event`). The ignore-list integration now loads cleanly.

### Changed
- **List column headers.** In the Blacklist, Remember Me and Recents tabs the class column (as an icon) was too narrow for the word "Class", and "Note" was truncated to "N...". Those columns now show an icon instead of clipped text, with the full name in a hover tooltip.
- **"Saved messages" window.** Long messages were cut off - they now wrap across multiple lines so the whole text is visible.