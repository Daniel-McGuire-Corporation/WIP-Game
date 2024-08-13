
# Untitled Game

## Prerequisites
- Windows 10 or later
- Visual Studio 17 (VS Build Tools is all thats required.)



## Building the Project

1. **Clone the Repository**

   ```bash
   git clone --recurse-submodules https://github.com/Daniel-McGuire-Corporation/WIP-Game.git
   cd WIP-Game
   ```


2. **Compile the Project**
   1. [Compile SFML](https://www.sfml-dev.org/tutorials/2.6/compile-with-cmake.php)

   2. Use the provided build script to compile the project. The script will handle necessary build configurations:

   ```powershell
   .\make.ps1 -compile (-run) -game
   ```
## USAGE:

2. **Game Controls**

   - **Left Arrow:** Move left
   - **Right Arrow:** Move right
   - **Up Arrow:** Jump

## Level Files

Levels are defined in `.ini` files located in the `data/levels` directory. The format of these files determines the layout of platforms and other elements.

## Debug Mode

To enable debugging features, you have to recomp:

```powershell
.\make.ps1 -compile -debug -game (-run)
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

