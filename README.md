# Counter Strike 2 Clone

![Project](https://img.shields.io/badge/Project-Fan--made-7c3aed)
![Engine](https://img.shields.io/badge/Godot-4.3.x-478cbf)
![Platform](https://img.shields.io/badge/Platform-Android-3ddc84)
![Status](https://img.shields.io/badge/Status-In%20development-f59e0b)

**Counter Strike 2 Clone** is an independent fan-made tactical FPS project for Android, built with Godot.

> This is **not an official Counter-Strike 2 product**, is not affiliated with Valve, and does not redistribute Valve proprietary game assets or original CS2 map files.

## 🎯 Project vision

Build an original mobile tactical FPS experience inspired by the classic competitive 5v5 formula: short rounds, economy, bomb sites, weapon variety, bots, skins, cases and fast Android controls.

The project uses its **own procedural geometry and original locations** rather than copying proprietary CS2 content.

## 🔥 Current prototype

- ⚔️ Offline **5v5** match with bots
- 🏁 **13-round** competitive score format
- 💣 Bomb A/B concept with a **40-second** timer after planting
- 💰 Buy phase and economy
- 🔫 **12 procedural weapons**
- 🎨 **24 procedural skins**
- 🎁 **4 cases**
- 🗺️ Original procedural maps: **Foundry** and **Harbor**
- 🌫️ Procedural lighting, fog, geometry and navigation
- 📱 Android-oriented UI and touch controls
- ⚙️ Godot 4.3.x project
- 🤖 GitHub Actions Android APK workflow

## 🌸 Featured character

The project includes the provided character artwork as a project character/reference asset.

![Featured character](assets/characters/featured-character.jpg)

Character assets are kept separate from the gameplay code so they can later be connected to the inventory, profile, menu and character-selection systems.

## 🗺️ Original maps

### Foundry
Industrial environment with central cover, A/B areas and compact routes designed for tactical engagements.

### Harbor
Container-yard environment with long lanes, cover blocks, a crane area and separate A/B zones.

Both locations are generated from project-owned procedural geometry.

## 🎮 Controls

### Desktop
- **WASD** — movement
- **Mouse** — look
- **Left mouse** — fire
- **R** — reload
- **B** — buy
- **E** — plant/use
- **Space** — jump

### Android
The project is being prepared around touch-first controls, including movement, aiming, fire, reload and shop actions.

## 🧩 Project structure

```
counter-strike-2-clone-apk/
├── .github/workflows/     # Android CI/CD
├── assets/characters/     # Character artwork
├── scenes/                # Godot scenes
├── scripts/               # Gameplay and data
├── project.godot
├── export_presets.cfg
└── README.md
```

## 🛠️ Local development

1. Install Godot 4.3.x.
2. Open this repository as a Godot project.
3. Run `scenes/Main.tscn`.
4. For Android, install matching Android export templates and SDK tools.

## 📦 Android build

The repository contains a GitHub Actions workflow for Android export.

The intended output is:

```
build/CounterStrike2Clone.apk
```

APK artifacts are uploaded by GitHub Actions when the export job succeeds.

## 🚧 Roadmap

- [ ] Full dual-stick Android controls
- [ ] Weapon switching and grenades
- [ ] Proper bomb planting/defusing flow
- [ ] Better bot navigation, visibility and tactics
- [ ] More original competitive maps
- [ ] Procedural audio and VFX
- [ ] Persistent inventory and settings
- [ ] Character/profile system
- [ ] Improved Android HUD and safe-area handling
- [ ] Stable release APK

## ⚖️ Fan-project notice

This repository is an independent fan project. It is **not sponsored, endorsed, licensed or affiliated with Valve**.

No Valve game assets, copied CS2 map files, or proprietary game data are included in this repository. The goal is to create an original game using procedural and project-owned content.

---

**Project:** Counter Strike 2 Clone  
**Engine:** Godot 4.3.x  
**Target:** Android / offline FPS  
**Developer:** Suyziss
