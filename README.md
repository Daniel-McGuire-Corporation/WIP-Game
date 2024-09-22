
# Untitled Game

> [!WARNING]
> 
> Do not use the make tool with any other OS than Windows and macOS right now!

## Build-Prerequisites

> [!NOTE]
>
> Linux Development hasn't started yet. macOS Version won't compile. macOS make sucks.

'*' = Required

| --- | Windows | Linux | macOS | Recommended |
|-----|---------|-------|-------|-------|
| Minimum: | Windows 10 | Ubuntu 22.04 | macOS Monterey (Intel) | --- |
| Misc: | [MSYS2](https://github.com/msys2/msys2-installer/releases/download/2024-07-27/msys2-x86_64-20240727.exe) (Optional) | --- | [HomeBrew](brew.sh)* | --- |
| Python*: | winget install python.python) | sudo apt install python | brew install python | --- |
| Build Tools*: | [Visual Studio 2022 Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe) | sudo apt install gcc | brew install clang | --- |
| PowerShell*: | [7.4.5](https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/PowerShell-7.4.5-win-x64.msi) | sudo snap install powershell | [7.4.5](https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/powershell-lts-7.4.5-osx-x64.pkg) | --- |
| IDE: | ANY | ANY | ANY | [VSCodium](vscodium.com) |



## Building the Project on macOS
1. ~Setup make tool~ (REDACTED) This can cause IRREVERSABLE HARM to your system if PyInstaller is not installed!
1. Use Xcode to manage the project

## Building the Project on Windows (USING Visual Studio Powershell)

1. **Clone the Repository**

   ```bash
   git clone --recurse-submodules https://github.com/Daniel-McGuire-Corporation/WIP-Game.git
   cd WIP-Game
   ```
   
3. **Setup** (Does not require make, uses custom program)
   ```bash
   ./makeinit
   ./setenv
   make -setupengine
   ```


2. **Compile the Project** [Learn Make Syntax](https://github.com/Daniel-McGuire-Corporation/WIP-Game/wiki/Make-Guide)
   ```bash
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

```bash
make -compile (-run) -[game, tools, all] -debug
```

## Known Issues

- The game currently assumes the level file format is correct and doesn't handle errors in the level file.
- Collision detection is basic and might need improvements for more complex levels.
- macOS Version is not loading textures and just doesnt really want to work.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For questions or issues, please contact [Daniel McGuire](mailto:danielmcguire23@icloud.com).

## Acknowledgments

- SFML: A great library for multimedia applications.
- QT: A great GUI library
- Apple: swift (took me 2 days to learn the basics lol)
- DMC MVPs

