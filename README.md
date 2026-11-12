# Counter Strike 2 Clone

Fan-made, unofficial offline tactical FPS project for Android, built with Godot 4.3.4.

This project is an independent fan clone and is not an official Counter-Strike 2 product and is not affiliated with or endorsed by Valve.

## Current prototype

- Offline 5v5 bot match.
- 13-round score format.
- Bomb A/B concept with 40-second timer after planting.
- Buy phase and economy.
- 12 procedural weapons.
- 24 procedural skins and 4 cases.
- Original procedural maps: Foundry and Harbor.
- Procedural geometry, lighting, fog and navigation.
- Android export preset.
- GitHub Actions workflow for APK builds.
- No Valve game assets or copied CS2 map files are included.

## Maps

The project deliberately uses original maps rather than redistributing Valve proprietary de_mirage or de_dust2 files. Future updates can add original maps inspired by classic competitive FPS design without copying proprietary assets.

## Build

Pushes to main automatically start the Android APK GitHub Actions workflow.

The workflow exports build/CounterStrike2Clone.apk and uploads it as a GitHub Actions artifact.

For a release, push a tag such as v1.0.0.

## Local development

Open the project in Godot 4.3.4 and run scenes/Main.tscn.

## Controls

Development:
- WASD — move
- Mouse — look
- Left mouse — fire
- R — reload
- B — buy
- E — plant bomb
- Space — jump

Android UI currently provides fire, reload and shop controls.

## Roadmap

- Full dual-stick touch controls.
- Weapon switching and grenades.
- Defuse interaction.
- Better bot navigation, visibility and tactics.
- Original competitive maps.
- Procedural audio and VFX.
- Persistent inventory/settings.
- More complete Android HUD and safe-area handling.
