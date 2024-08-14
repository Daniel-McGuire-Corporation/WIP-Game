
# Untitled Game

## Build-Prerequisites
- Windows 10 x64 or later
- Python 3.6 or later (and PIP)
- [Visual Studio 17 (2022) Build Tools (or VS Studio)](https://aka.ms/vs/17/release/vs_BuildTools.exe) 



## Building the Project

1. **Clone the Repository**

   ```bash
   git clone --recurse-submodules https://github.com/Daniel-McGuire-Corporation/WIP-Game.git
   cd WIP-Game
   ```
   
2. **Setup**
   ```bash
   ./setenv
   makeinit 
   make -setupengine
   ```


2. **Compile the Project**
   1. Use the provided build script to compile the project. The script will handle necessary build configurations:

   ```bash
   make -compile (-run) -game
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
make -compile -debug -game (-run)
```

## Known Issues

- The game currently assumes the level file format is correct and doesn't handle errors in the level file.
- Collision detection is basic and might need improvements for more complex levels.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For questions or issues, please contact [Daniel McGuire](mailto:danielmcguire23@icloud.com).

## Acknowledgments

- SFML: A great library for multimedia applications.
- QT: A great GUI library
- DMC MVPs

