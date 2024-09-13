
# Untitled Game

> [!WARNING]
> 
> Do not use the make tool with any other OS than Windows right now!

## Build-Prerequisites

> [!NOTE]
> 
> Linux Development hasn't started yet

| OS: | Windows | Linux | macOS |
|-----|---------|-------|-------|
| Minimum: | Windows 10 | Ubuntu 22.04 | macOS Monterey (Intel) |
| Python: | [3.12.6](https://www.python.org/ftp/python/3.12.5/python-3.12.5-amd64.exe) | sudo apt install python | [3.12.6](https://www.python.org/ftp/python/3.12.6/python-3.12.6-macos11.pkg) |
| IDE: | [Visual Studio 2022 Build Tools](https://aka.ms/vs/17/release/vs_BuildTools.exe) | sudo snap install --classic code | [Xcode](https://developer.apple.com/xcode/) |
| PowerShell: | [7.4.5](https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/PowerShell-7.4.5-win-x64.msi) | sudo snap install powershell | [7.4.5](https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/powershell-lts-7.4.5-osx-x64.pkg) |
| Misc: | [MSYS2](https://github.com/msys2/msys2-installer/releases/download/2024-07-27/msys2-x86_64-20240727.exe) (Optional) | [QT](https://www.qt.io/download-dev) | [HomeBrew](brew.sh) | 


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

