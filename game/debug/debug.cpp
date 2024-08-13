#include "debug.hpp"
#include "../game/game.hpp"
#include <iostream>
#include <string>
#include <sstream>
#include <thread>
#include <atomic>
#include <SFML/Graphics.hpp>
#include <Windows.h>
#include <map>
#include <algorithm>
#include "../vari.hpp"


sf::RectangleShape player(sf::Vector2f(50.0f, 50.0f));

void resetGame() {
    player.setPosition(100.0f, -100.0f); // Reset player position
    velocityY = 0.0f;
    isJumping = false;
}

// Enumeration for commands
enum Command {
    UNKNOWN,
    SET,
    RESET,
    STOP,
    RESUME,
    HELP,
    CLEAR
};

// Function to map command string to enum value
Command getCommandEnum(const std::string& cmd) {
    if (cmd == "set") return SET;
    if (cmd == "reset") return RESET;
    if (cmd == "stop") return STOP;
    if (cmd == "resume") return RESUME;
    if (cmd == "help") return HELP;
    if (cmd == "clear") return CLEAR;
    return UNKNOWN;
}

void clear() {
	                // If cls does not work, you can try using Windows API to clear the console
				HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
				COORD coordScreen = { 0, 0 };    // Home for the cursor
				DWORD cCharsWritten;
				CONSOLE_SCREEN_BUFFER_INFO csbi;
				DWORD dwConSize;

				// Get the number of character cells in the current buffer
				GetConsoleScreenBufferInfo(hConsole, &csbi);
				dwConSize = csbi.dwSize.X * csbi.dwSize.Y;

				// Fill the entire screen with blanks
				FillConsoleOutputCharacter(hConsole, (TCHAR) ' ', dwConSize, coordScreen, &cCharsWritten);
				FillConsoleOutputAttribute(hConsole, csbi.wAttributes, dwConSize, coordScreen, &cCharsWritten);

				// Move the cursor home
				SetConsoleCursorPosition(hConsole, coordScreen);
}

void handleDebugCommands() {
    std::string command;
    std::cout << "DEBUG: ";
    std::getline(std::cin, command);

    // Remove parentheses if present
    command.erase(std::remove(command.begin(), command.end(), '('), command.end());
    command.erase(std::remove(command.begin(), command.end(), ')'), command.end());

    // Convert command to lowercase to handle case insensitivity
    std::transform(command.begin(), command.end(), command.begin(), ::tolower);

    std::istringstream iss(command);
    std::string cmd, var;
    float value;

    iss >> cmd;
    Command commandEnum = getCommandEnum(cmd);

    switch (commandEnum) {
        case SET: {
            std::string variable;
            std::getline(iss, var, '.'); // Read variable name up to the dot
            variable = var;
            variable.erase(0, variable.find_first_not_of(" ")); // Trim leading spaces

            std::getline(iss, var); // Read value after dot
            var.erase(0, var.find_first_not_of(" ")); // Trim leading spaces

            try {
                value = std::stof(var); // Convert to float
            } catch (const std::invalid_argument& e) {
                std::cout << "Invalid value: " << var << ". Use 'help()' for usage instructions." << std::endl;
                return;
            }

            if (variable == "gravity") {
                GRAVITY = value;
                std::cout << "Updated gravity to " << GRAVITY << std::endl;
            } else if (variable == "move_speed") {
                MOVE_SPEED = value;
                std::cout << "Updated move speed to " << MOVE_SPEED << std::endl;
            } else if (variable == "jump_height") {
                JUMP_HEIGHT = value;
                std::cout << "Updated jump height to " << JUMP_HEIGHT << std::endl;
            } else {
                std::cout << "Unknown variable: " << variable << ". Use 'help()' for usage instructions." << std::endl;
            }
            break;
        }
        case RESET:
            if (iss.rdbuf()->in_avail() == 0) {
                resetGame();
                std::cout << "Game reset" << std::endl;
            } else {
                std::cout << "Invalid command format. Use 'help()' for usage instructions." << std::endl;
            }
            break;
        case STOP:
            if (iss.rdbuf()->in_avail() == 0) {
                running = false;
                std::cout << "Game stopped" << std::endl;
            } else {
                std::cout << "Invalid command format. Use 'help()' for usage instructions." << std::endl;
            }
            break;
        case RESUME:
            if (iss.rdbuf()->in_avail() == 0) {
                running = true;
                std::cout << "Game resumed" << std::endl;
            } else {
                std::cout << "Invalid command format. Use 'help()' for usage instructions." << std::endl;
            }
            break;
        case HELP:
            std::cout << "Available commands:" << std::endl;
            std::cout << "  help() - Show this help message" << std::endl;
            std::cout << "  reset() - Reset the game to initial state" << std::endl;
            std::cout << "  stop() - Stop the game" << std::endl;
            std::cout << "  resume() - Resume the game" << std::endl;
            std::cout << "  set(VARIABLE.VALUE) - Set the value of a variable (e.g., GRAVITY.0.2)" << std::endl;
            std::cout << "  clear() - Clear the console screen" << std::endl;
            std::cout << std::endl;
            std::cout << "Variables:" << std::endl;
            std::cout << "  GRAVITY - Controls the downward force on the player (default: 0.1)" << std::endl;
            std::cout << "  MOVE_SPEED - Controls the speed at which the player moves (default: 1.0)" << std::endl;
            std::cout << "  JUMP_HEIGHT - Controls the height of the player's jump (default: 0.1)" << std::endl;
            break;
        case CLEAR:
				clear();
				break;
        case UNKNOWN:
        default:
            std::cout << "Unknown command: " << cmd << ". Use 'help()' for usage instructions." << std::endl;
            break;
    }
}

void debugThreadFunction() {
    // Allocate a new console for the debug thread
    AllocConsole();
    freopen("CONIN$", "r", stdin);
    freopen("CONOUT$", "w", stdout);
    freopen("CONOUT$", "w", stderr);
    SetConsoleTitle((APP_NAME + " | DEBUG ").c_str());
    while (running) {
        handleDebugCommands();
    }
}

void startDebugThread() {
    std::thread debugThread(debugThreadFunction);
    debugThread.detach();
}