# Foundry Explorer

Offline 3D exploration prototype for Android, built with Godot 4.3.

This branch keeps the procedural Foundry and Harbor environments from the original prototype and changes the gameplay into a non-combat exploration experience.

## Features

- Two original procedural locations: Foundry and Harbor.
- First-person movement on desktop and Android touch controls.
- Three discoverable data stations in each location.
- Object inspection with completion feedback.
- Local progress and camera sensitivity saved with ConfigFile.
- Dark violet interface palette adapted from the Suyziss visual theme.
- Android ARM64 export preset.
- GitHub Actions workflow for APK validation and export.

## Controls

Desktop: WASD to move, mouse to look, E to inspect a nearby station, Escape to pause.

Android: direction buttons to move, drag on the right side to look, and the Inspect button to interact.

## Build

Use Godot 4.3 stable with matching export templates, JDK 17, Android SDK platform/build-tools 34, NDK 23.2.8568313, and CMake 3.10.2.4988404.

The Android workflow uploads the generated APK as the FoundryExplorer-Android-APK artifact. A version tag such as v0.2.0 also publishes the APK to GitHub Releases.

## Notes

This is an independent fan-made project and includes no Valve game assets. This branch is an exploration-focused reinterpretation and does not implement combat mechanics.
