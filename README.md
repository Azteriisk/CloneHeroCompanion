<p align="center">
  <img src="icon.png" width="128" height="128" alt="Azterisk Hero Companion" />
</p>

<h1 align="center">Azterisk Hero Companion</h1>

<p align="center">
  <em>A modern, high-performance companion app for <strong>Clone Hero</strong> and <strong>YARG (Yet Another Rhythm Game)</strong>.</em>
</p>

<p align="center">
  <a href="https://github.com/Azteriisk/CloneHeroCompanion/releases/latest"><img src="https://img.shields.io/github/v/release/Azteriisk/CloneHeroCompanion?style=for-the-badge&color=22c55e" alt="Release"></a>
  <a href="https://github.com/Azteriisk/CloneHeroCompanion/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge" alt="License"></a>
  <a href="https://godotengine.org/"><img src="https://img.shields.io/badge/Godot-4.4+-478CBF?style=for-the-badge&logo=godotengine&logoColor=white" alt="Godot 4"></a>
  <a href="https://enchor.us"><img src="https://img.shields.io/badge/Powered%20By-Enchor-ff0055?style=for-the-badge" alt="Enchor"></a>
</p>

---

## ✨ Features

- **⚡ Instant Chart Discovery** — Search and explore the entire [Enchor](https://enchor.us) chart database with full filter support (Lead Guitar, Bass, Drums, Keys, Vocals, difficulty tiers, and charter info).
- **🏆 Community Classics & CSC Releases** — One-click access to curated rhythm gaming staples and featured monthly Custom Songs Central packs.
- **🎧 Smart Spotify Playlist Importer** — Securely authenticate with Spotify via OAuth 2.0 PKCE (no passwords or client secrets stored). Automatically matches playlist tracks with Enchor charts for seamless, single-click library downloads.
  - **Fuzzy String Similarity & Levenshtein Matching**: Multi-factor evaluation comparing normalized artists and song titles to eliminate false matches.
  - **Strict Artist Verification**: Enforces minimum similarity thresholds and collaboration handling (`&`, `and`, `feat.`, `with`, "The" prefixes). Never auto-selects charts by different artists.
  - **Tiered Clean Queries**: Automatically strips noisy metadata (remaster years, live tags, bracketed extras) and queries Clean Title + Primary Artist first for high precision.
  - **Duration Delta Cross-Reference**: Cross-references Spotify track length against Enchor chart durations as an additional confidence signal.
  - **Disambiguation & Warnings**: Interactive modal displays chart artist, song name, and charter, with prominent `[⚠️ DIFFERENT ARTIST]` badges for alternative or cover versions.
- **🗺️ Intelligent Artist Discovery** — Integrated with Music-Map to dynamically explore and recommend artists and charts tailored to your local library.
- **🎯 Dual-Game Support** — Seamlessly detect and manage song libraries for both Clone Hero and YARG.
- **💾 Dynamic Multi-Drive Scanning** — Automatically scans all connected mounted drives and partitions on Windows and Linux to detect existing rhythm game libraries wherever they are stored.
- **📦 Direct Chart Installation** — Downloads, validates, extracts, and installs `.sng` charts and archives straight into your game's song folders without manual unzipping.
- **🔓 YARG Song Converter** — Built-in decrypter support for YARG package formats (`.yargsong` Crawford cipher to CON format).
- **🚀 Native Cross-Platform Performance** — Standalone native 64-bit binaries for Windows and Linux with zero external dependencies and low resource overhead.

---

## 🚀 Getting Started

### Pre-built Release (Windows & Linux)

1. Head over to the [Latest Release](https://github.com/Azteriisk/CloneHeroCompanion/releases/latest).
2. Download the package for your operating system:
   - **Windows**: Download `AzteriskHero-v1.1-windows.zip` (or `AzteriskHero.exe` directly). Extract and run `AzteriskHero.exe`.
   - **Linux**: Download `AzteriskHero-v1.1-linux.tar.gz` (or `AzteriskHero.x86_64` directly). Extract, mark executable (`chmod +x AzteriskHero.x86_64`), and run.
3. The companion will automatically detect your Clone Hero and YARG song folders on launch across all drives. You can also customize or add directories anytime in the **Settings** tab.

---

## 💻 Building from Source

### Prerequisites

- [Godot Engine 4.4+](https://godotengine.org) (Standard 64-bit)
- Python 3.10+ (optional, for standalone `.yargsong` converter script)

### Running Locally

```bash
# Clone repository
git clone https://github.com/Azteriisk/CloneHeroCompanion.git
cd CloneHeroCompanion

# Run with Godot
godot --path .
```

### Exporting Release Builds

```bash
# Export release binary for Windows Desktop
godot --headless --export-release "Windows Desktop" "build/AzteriskHero.exe"

# Export release binary for Linux Desktop
godot --headless --export-release "Linux Desktop" "build/AzteriskHero.x86_64"
```

---

## 🔒 Privacy & Security

- **PKCE Authentication**: Spotify integration uses Proof Key for Code Exchange (OAuth 2.0 PKCE). No developer client secrets or user passwords are ever requested, transmitted, or stored.
- **100% Local Storage**: All tokens and configuration settings are stored locally in the standard application data folder (`user://`). No analytics, tracking, or telemetry of any kind.

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🤝 Acknowledgments

- [Enchor](https://enchor.us) for the community chart search API & file distribution.
- [Music-Map](https://www.music-map.com) for artist recommendation graphs.
- The **Clone Hero** & **YARG** communities for their tireless work charting and preserving rhythm gaming history.
