# Desktop package validation — 2026-10-26

The missing Windows x64 and Linux x86_64 packages were generated from the current game sources using official LÖVE 11.5 binaries. The existing Android APK was retained: every bundled Lua module, font and font license matches the current sources, and its recorded SHA-256 checksum matches.

- `lua tests.lua`, `lua search-tests.lua`, `lua mobile-tests.lua` and `lua feature-tests.lua` passed.
- The Windows single-file executable was launched on Windows. It extracted the embedded runtime successfully, displayed the game and bundled fonts, and started a run from the start button.
- `packaging/verify.ps1` checks the content and architecture of the three packages, runtime dependencies, engine and font licenses, AppImage launch configuration and executable permissions, and SHA-256 files.
- The Linux AppImage was built and inspected on Windows using SquashFS tools. No Linux environment is installed on this computer, so a Linux launch, FUSE integration and gameplay have **not** been tested.

Build dependencies and source URLs with pinned hashes are in `build-desktop.ps1`. Cached tools, temporary build files and executable outputs are ignored by Git.
