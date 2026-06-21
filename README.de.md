<div align="center">
<img src="https://media.nerzors.de/addons/nbk/nbk-banner_og_920x360.jpg" alt="Nerzors Blacklist Keeper Banner"/>

<h1><img src="https://media.nerzors.de/addons/nbk/nbkAddon_Midnight.final-v3.png" width="32" alt="Nerzors Blacklist Keeper Logo"/> Nerzors Blacklist Keeper</h1>

<p><i>Merke dir die Spieler, mit denen du nie wieder spielen willst... und die guten gleich mit.</i></p>

<p>
  <a href="https://www.curseforge.com/wow/addons/nerzorsblacklistkeeper">
    <img src="https://img.shields.io/badge/CurseForge-1B1F2B?style=for-the-badge&logo=curseforge&logoColor=e04e14&labelColor=1B1F2B" alt="CurseForge"/>
  </a>
  <a href="https://www.curseforge.com/wow/addons/nerzorsblacklistkeeper">
    <img src="https://img.shields.io/badge/WoWUp-1B1F2B?style=for-the-badge&logoColor=A87CE8&labelColor=1B1F2B" alt="WoWUp"/>
  </a>
  <a href="https://addons.wago.io/addons/nerzorsblacklistkeeper">
    <img src="https://img.shields.io/badge/Wago.io-1B1F2B?style=for-the-badge&logoColor=A87CE8&labelColor=1B1F2B" alt="Wago.io"/>
  </a>
</p>

<p>
  <img src="https://cf.way2muchnoise.eu/1554935.svg?gameVersionTypeId=517" alt="CurseForge Downloads"/>
  <img src="https://img.shields.io/github/v/release/Nerzors/NerzorsBlacklistKeeper?style=flat-square&color=252669&labelColor=1B1F2B" alt="Latest Release"/>
  <img src="https://img.shields.io/github/last-commit/Nerzors/NerzorsBlacklistKeeper?style=flat-square&color=A87CE8&labelColor=1B1F2B" alt="Last Commit"/>
  <img src="https://img.shields.io/github/issues/Nerzors/NerzorsBlacklistKeeper?style=flat-square&color=252669&labelColor=1B1F2B" alt="Open Issues"/>
  <img src="https://img.shields.io/github/stars/Nerzors/NerzorsBlacklistKeeper?style=flat-square&color=A87CE8&labelColor=1B1F2B" alt="Stars"/>
</p>

</div>

<br/>

> *"Vertrauen verdient man sich in Dungeons und verspielt es bei einem schlechten Pull."*

**Nerzors Blacklist Keeper (NBK)** ist ein modulares Addon für World of Warcraft, mit dem du den Überblick über Spieler behältst, mit denen du wieder spielen willst, oder eben nicht.

Pflege deine persönliche Blacklist mit Gründen, Notizen, Mute-Flags und Klasseninfo. Erhalte Warnungen, wenn geblacklistete Spieler in deiner Gruppe, im Gruppenfinder oder im Chat auftauchen.

NBK enthält außerdem eine positive **Remember Me**-Liste für vertrauenswürdige Spieler, ein Tracking der letzten Gruppenmitglieder und optionale Bewertungs-Prompts nach Runs. Stell es dir vor wie deinen persönlichen Kodex der Verbündeten und Widersacher, nur ohne das Urteil des Lichts, dafür mit Mute-Button.

---

## Entwicklungsstatus

> [!IMPORTANT]
> Mit Updated `2.0.0-dev.0.39.0`: Das `Tooltip`-Sub-Addon ist weggefallen. Seine Funktionalität ist jetzt Teil des Hauptaddons. Du musst `NerzorsBlacklistKeeper_Tooltip` nicht mehr installieren und kannst den alten Ordner löschen.

> NBK V2 befindet sich aktuell in aktiver Entwicklung.

Version 2 ist ein kompletter Neuaufbau des ursprünglichen Addons mit modularer Architektur.
NBK V1 ist eingestellt und erhält keine Updates mehr. *Ruhe in Frieden, V1 - du hast deinen Zweck erfüllt, wie ein guter DK-Ghul.*

---

## ADDON - Kerninformationen

| Eigenschaft | Wert |
|----------|-------|
| Autor | Nerzors |
| Co-Autor | Veplo (Discord: Veplo) |
| Sprache | English / Deutsch |
| Spielversion | WoW Retail [12.0.x] |
| Aktueller Branch | 2.0 Development (2.0.0-dev.0.39.0) |

---

## Features

| Modul | Beschreibung |
|--------|-------------|
| Blacklist | Spieler mit Gründen, Notizen, Pins und Mute-Flags speichern |
| Group Warning | Warnung, wenn geblacklistete Spieler deiner Gruppe beitreten |
| Tooltip | Zeigt Blacklist-Infos im Tooltip an |
| Chat Filter | Blendet geblacklistete Spieler und blockierte Wörter aus |
| Group Finder | Erkennt geblacklistete Spieler im LFG |
| Recents | Verfolgt zuletzt gespielte Gruppenmitglieder |
| Remember Me | Positive Spielerliste mit Bewertungen |
| Sync | Einträge mit vertrauten Spielern teilen und synchronisieren |

---

## Installation (Manuell)

Ordner installieren in:

```txt
World of Warcraft/_retail_/Interface/AddOns/
```

```txt
NerzorsBlacklistKeeper_Data
NerzorsBlacklistKeeper
NerzorsBlacklistKeeper_ChatFilters
NerzorsBlacklistKeeper_GroupFinder
NerzorsBlacklistKeeper_Sync
NerzorsBlacklistKeeper_Recents
NerzorsBlacklistKeeper_RememberMe
```

### Erforderlich

- `NerzorsBlacklistKeeper_Data`
- `NerzorsBlacklistKeeper`

Alle anderen Module sind optional. Wähle dein Loadout wie einen Talentbaum. nimm nur, was du wirklich benötigst, oder einfach Meta-Build alles an!

---

## Module

| Ordner | Erforderlich | Zweck |
|--------|----------|---------|
| `_Data` | Ja | Geteilte Assets und Libraries |
| `Core` | Ja | Hauptfunktionalität des Addons |
| `_ChatFilters` | Nein | Chat-Filterung |
| `_GroupFinder` | Nein | LFG-Warnungen |
| `_Sync` | Nein | Teilen & Synchronisation |
| `_Recents` | Nein | Tracking zuletzt gespielter Spieler |
| `_RememberMe` | Nein | Positive Spielerliste |

---

## Slash Commands

| Befehl | Aktion |
|---------|--------|
| `/nbk` | Hauptfenster öffnen |
| `/nbk config` | Einstellungen öffnen |
| `/nbk add name` | Spieler hinzufügen |
| `/nbk remove name` | Spieler entfernen |
| `/nbk check name` | Spieler prüfen |
| `/nbk list` | Blacklist ausgeben |
| `/nbk news` | News-Fenster öffnen |

Alias:

```txt
/blacklistkeeper
```

---

## Teilen & Auto-Sync

NBK unterstützt Peer-to-Peer-Teilen über die Addon-Kommunikation von WoW.

Du entscheidest:

- Wer Einträge senden darf
- Wer Sync-Daten empfängt
- Welche Einträge teilbar sind

Auto-Sync kann neu hinzugefügte Blacklist-Einträge sofort teilen mit:

- Deiner Gilde
- Freunden
- Benutzerdefinierten Spielerlisten

---

## Eingebundene Libraries

-   [libstub](https://www.wowace.com/projects/libstub)
-   [callbackhandler](https://www.wowace.com/projects/callbackhandler)
-   [libdeflate](https://github.com/SafeteeWoW/LibDeflate)
-   [libsharedmedia-3.0](https://www.wowace.com/projects/libsharedmedia-3-0)

Libraries unterliegen weiterhin ihren jeweiligen Originallizenzen.

---

## Support

| Plattform | Link |
|----------|------|
| 🌐 Webseite | [www.nerzors.de](https://www.nerzors.de/en/) |
| 🐛 Issues | [GitHub Issues](https://github.com/Nerzors/NerzorsBlacklistKeeper/issues) |
| 📬 Addon-Mail | [nbk.addon@nerzors.de](mailto:nbk.addon@nerzors.de) |
| ✉️ Allgemeiner Kontakt | [dev@nerzors.de](mailto:dev@nerzors.de) |

<div align="center">
<sub>Erstellt mit 🩸 & ♥️ von Nerzors | weil sich irgendjemand merken muss, wer ohne zu fragen gepullt hat.</sub>
</div>
