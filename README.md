
# Untitled Game

Supported OSs:
1. Windows (Alpha stage) (Download from Releases)
2. macOS (Development only) (Learn to Compile it below)
3. ~Linux~ (Soon maybe) (Needs X11 or QT.)


## Build-Prerequisites

> [!NOTE]
>
> Linux Development hasn't started yet. macOS Version won't compile. macOS make sucks.

'*' = **REQUIRED**
| **---**| **Windows** | **~Linux~** | **macOS** | **Recommended** |
|--------|-------------|-----------|-----------|-----------------|
| **Minimum** | Windows 10 | ~Ubuntu 22.04~ | macOS Monterey (Intel) | --- |
| **Misc** | [MSYS2](https://github.com/msys2/msys2-installer/releases/download/2024-07-27/msys2-x86_64-20240727.exe) (Optional) | ~---~ | [HomeBrew](https://github.com/Homebrew/brew/releases/download/4.3.23/Homebrew-4.3.23.pkg)* | --- |
| --- | [Chocolatey](https://chocolatey.org/install)* | ~---~ | --- | --- |
| **Python\*** | `choco install python` | ~`sudo apt install python`~ | `brew install python` | --- |
| **Build Tools\*** | `choco install visualstudio2022buildtools` | ~`sudo apt install gcc`~ | `brew install clang` | --- |
| **PowerShell\*** | --- | ~`sudo snap install powershell`~ | `brew install powershell` | --- |
| **IDE** | ANY | ~ANY~ | ANY | [VSCodium](https://vscodium.com) |


## Building the Project on macOS
1. **Clone the Repository**
   ```bash
   git clone --recurse-submodules https://github.com/Daniel-McGuire-Corporation/WIP-Game.git
   cd WIP-Game
   ```
2. Setup Make Tool in PowerShell
   ```pwsh
      pwsh
   ./makeinit
   ```
3. **Compile the Project** [Learn Make Syntax (Some parts may be different due to platform differences.)](https://github.com/Daniel-McGuire-Corporation/WIP-Game/wiki/Make-Guide)
   ```pwsh
   ./make -compile (-run) -[game, tools, all]
   ```

## Building the Project on Windows (USING Visual Studio Powershell)

1. **Clone the Repository**

   ```pwsh
   git clone --recurse-submodules https://github.com/Daniel-McGuire-Corporation/WIP-Game.git
   cd WIP-Game
   ```
   
2. **Setup** (Does not require make, uses custom program)
   ```pwsh
   ./makeinit
   ./setenv
   make -setupengine
   ```


3. **Compile the Project** [Learn Make Syntax](https://github.com/Daniel-McGuire-Corporation/WIP-Game/wiki/Make-Guide)
   ```pwsh
   make -compile (-run) -[game, tools, all]
   ```
## USAGE:

**Game Controls**

   - **Left Arrow:** Move left
   - **Right Arrow:** Move right
   - **Up Arrow:** Jump

## Level Files

Levels are defined in `.ini` files located in the `data/levels` directory. The format of these files determines the layout of platforms and other elements.

## Debug Mode

To enable debugging features, you have to recomp:

```pwsh
make -compile (-run) -[game, tools, all] -debug
```

## Known Issues

- The game currently assumes the level file format is correct and doesn't handle errors in the level file.
- Collision detection is basic and might need improvements for more complex levels.
- macOS Version is not compiling.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For questions or issues, please contact [Daniel McGuire](mailto:danielmcguire23@icloud.com).

## Acknowledgments

- SFML: A great library for multimedia applications.
- DMC MVPs

