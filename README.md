# DINO — Desert Run

An offline endless runner built with Lua and LÖVE 11.5. Guide a T-Rex through the desert, jungle and snow, jump over cacti, duck under birds, collect coins and beat your best score. The game supports keyboard, mouse and Android touch controls.

## Features

- **Endless running:** gradually increasing speed, variable-height jumps and animated bird obstacles. Jump over low birds, duck under birds at middle height and stay grounded beneath high birds.
- **Changing scenery:** the environment cycles through desert, jungle and snow every 250 points, with trees, mountains and snowfall.
- **Coins and missions:** collect randomly placed groups of coins and complete three recurring missions for additional rewards. Mission progress carries over between runs.
- **Shared upgrades:** improve jump power, coin attraction and score gains for every dinosaur. A rechargeable shield absorbs one hit per run.
- **52,399 cosmetic skins:** browse a searchable collection of T-Rex costumes and procedural designs. All skins share the same movement, collision geometry and upgrades.
- **23 fruit costumes:** recognizable fruit colors, seeds, textures and decorations applied to the T-Rex body, preserving its head, short arms, tail and legs.
- **10 languages:** English, Romanian, Simplified Chinese, Italian, Portuguese, Spanish, French, German, Turkish and Polish. Menus, controls, missions, shop messages and fruit names are translated.
- **Local persistence:** best score, coins, missions, upgrades, unlocked heroes, language and selected skin are saved between sessions. Older progress formats remain supported.
- **Mobile controls:** touch buttons for jumping, ducking, pause, restart, sound and upgrades, including simultaneous jump/duck input and Android Back handling.
- **Offline play:** graphics and sound effects are generated in code. Bundled Noto fonts provide accented Latin and Simplified Chinese characters without downloads during play.
- **Automatic pause:** opening menus or losing window focus pauses an active run.

## Run from source

Install **LÖVE 11.5** separately, then run this command from the project directory:

```sh
love .
```

On Windows, if LÖVE is installed in its default location:

```powershell
& 'C:\Program Files\LOVE\love.exe' .
```

On Linux, the included launcher is also available:

```sh
bash start.sh
```

LÖVE includes its own Lua runtime, so a separate Lua installation is only needed to run the standalone tests. A fresh clone does not include the local `.runtime` directory or any executable packages.

## Controls

| Action | Keyboard / mouse | Touch |
| --- | --- | --- |
| Start, jump or retry after a crash | Space, Up, W or click the play area | Tap the play area or JUMP |
| Shorter jump | Release the jump button early | Release JUMP early |
| Duck | Hold Down or S | Hold DUCK |
| Pause / resume | P or Esc | PAUSE / RESUME |
| Return to the start screen | R | RESET |
| Toggle sound | M | SOUND ON / OFF |
| Open the skin collection | C or click the skin bar | Tap the skin bar |
| Open upgrades | U or click Upgrades | Tap UPGRADES |
| Choose a language | L or click Language | Tap Language |
| Select an original skin | 1–5 outside menus | Use the collection |

Opening a menu during a run pauses the game. Resume after closing it. In the language menu, use the ten visible buttons or keys **1–9**, with **0** selecting Polish. Android Back closes an open menu and pauses gameplay.

### Skin collection

Search by full or partial name, an exact numeric ID, or an ID prefixed with `#`. Searches are case-insensitive and include English names, Romanian tags and fruit names in the selected language.

- Click or tap a card to select it, or press Enter for the first result on the current page.
- Use the arrow keys, mouse wheel or Previous / Next buttons to change pages. Home / End jumps to the first / last page.
- Use Random to choose from the filtered skins that are free or already unlocked.
- Delete or the X button clears the search; Backspace removes a character and Tab toggles search focus.
- Esc closes the collection. When search is unfocused, C also closes it and R chooses a random skin.

## Skins

The collection contains **52,397 free skins** and **two heroes**, each unlockable once for **200 in-game coins**. Skin names and IDs remain stable so existing selections continue to work.

| Collection | Count | Examples |
| --- | ---: | --- |
| Originals | 5 | Classic, Ember, Frost, Neon, Explorer |
| Procedural variants | 5,000 | Body palettes, markings and head accessories |
| Special | 6,767 | Crystal, Magma, Cosmic, Storm, Grove, Aurora, Fossil, Solar |
| Halloween | 6,767 | Pumpkin, Ghost, Skeleton, Vampire, Witch, Mummy, Bat, Spider |
| Ocean | 6,767 | Shark, Octopus, Coral, Abyss, Jellyfish, Turtle, Seahorse, Pearl |
| Pirates | 6,767 | Captain, Corsair, Raider, Sailor, Gunner, Admiral, Treasure, Kraken |
| Robots | 6,767 | Steel, Laser, Rust, Astronaut, Hologram, Magnet, Reactor, Mecha |
| SpongeBob-inspired | 6,767 | SpongeBob, Patrick, Squidward, Sandy and other themed costumes |
| Sweets | 6,767 | Ice Cream, Chocolate, Gummy, Lollipop, Donut, Cupcake, Marshmallow, Cookie |
| Fruit | 23 | Distinct fruit designs on the shared T-Rex body |
| Heroes | 2 | Godzilla and King Kong |

Fruit costumes include mango; red, green and yellow apples; yellow pear; banana; orange and blood orange; watermelon; yellow melon; peach; strawberry; kiwi; pineapple; cherry; grape; lemon; coconut; dragon fruit; blueberry; raspberry; pomegranate; and avocado.

The original fruit skins use IDs **52375–52385**. Godzilla and King Kong retain IDs **52386** and **52387**. The twelve additional fruit species use IDs **52388–52399**. Search for `fruit`, `fructe`, a fruit name or its ID to find them.

## Coins, missions and upgrades

Coins appear independently of obstacles in groups of one to six, at varying heights and intervals. The HUD distinguishes coins collected in the current run from the available wallet balance.

Three missions are active at once: collect coins, clear cacti and earn score. Their initial targets are **30 coins**, **20 cacti** and **150 points**, with rewards of **25**, **50** and **75 coins**. Each completed mission increases its next target by the initial target amount.

| Upgrade | Effect | Initial cost | Maximum level |
| --- | --- | ---: | ---: |
| Jump | +5% jump power per level | 50 coins | 5 |
| Coin magnet | +20 px pickup range per level | 75 coins | 5 |
| Score | +10% score per level | 100 coins | 5 |
| Shield | Absorbs one hit per run and recharges on restart | 150 coins | 1 |

For upgrades with multiple levels, the purchase price is the initial cost multiplied by the level being purchased. Upgrades apply to the entire collection, including heroes. The shield provides a brief protection period after breaking.

## Saved data

LÖVE stores game data under the application identity `dino-desert-run` in its platform-specific save directory:

- `record.txt`: best score.
- `progress.txt`: coins, missions, upgrades and unlocked heroes.
- `skin.txt`: selected skin name.
- `language.txt`: selected language code.

Progress is saved during play and on normal shutdown or focus loss. Desktop and Android installations maintain separate local saves. Uninstalling the Android application may remove its saved data.

## Build packages locally

This repository contains game source, build scripts, tests, fonts and documentation. **Lua/LÖVE executables, runtime toolchains, `.love` packages, Android APK/AAB files and signing keys are excluded from Git.**

Create the portable LÖVE package on Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File build-love.ps1
```

The output is `Dino.love`; it requires an installed LÖVE runtime to launch.

Build the Android application on Windows with **JDK 17 or later** and the **Android SDK Build Tools** installed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File android\build.ps1
```

Set `ANDROID_HOME` or `ANDROID_SDK_ROOT`, or pass `-SdkRoot` to the Android build script. The script downloads and verifies its build dependencies on the first run, then builds, aligns and signs `android/dist/Dino-Android.apk`. Keep the locally generated signing key and password private so future APKs can update the same installation.

See [Android build and installation notes](android/README.md) and [validation results](android/VALIDATION.md) for more details.

## Tests

Install Lua 5.4 separately and run:

```sh
lua tests.lua
lua search-tests.lua
lua mobile-tests.lua
lua feature-tests.lua
```

These suites cover gameplay, collisions, missions, upgrades, save migration, catalog input, touch controls, hero purchases, fruit species, translations, localized searches and language selection at multiple resolutions.

`skin-tests.lua` exports a validation function that must be invoked inside LÖVE. It renders every skin, checks unique names and SHA-256 pixel hashes, verifies font coverage for all ten languages and checks that the additional fruit skins preserve the shared T-Rex body in both walking poses.

## Project layout

| File / directory | Purpose |
| --- | --- |
| `main.lua` | Rendering, input, menus, audio and persistence integration |
| `game.lua` | Player motion, obstacles, coins, score and collisions |
| `progress.lua` | Missions, wallet, upgrades, hero ownership and save migration |
| `skins.lua`, `skin-search.lua` | Skin definitions and catalog filtering |
| `dino.lua`, themed drawing modules | Shared T-Rex body and cosmetic decorations |
| `i18n.lua` | Language definitions and translations |
| `conf.lua` | LÖVE window and module configuration |
| `assets/fonts/` | Bundled Noto fonts and their licenses |
| `*-tests.lua`, `tests.lua` | Automated checks |
| `build-love.ps1`, `android/build.ps1` | Local packaging scripts |

Font sources and license details are listed in [assets/fonts/SOURCES.md](assets/fonts/SOURCES.md).
