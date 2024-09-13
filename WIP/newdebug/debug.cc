// Untitled Game Debugger (Linux)
// WIP
// Created by Daniel McGuire on 09/12/24 10:30EST

#include <iostream>
#include <string>
#include <vector>
#include <ctime>
#include <cstdlib>
#include <cstdio>

int main() {
    std::string logoSpacer = "=====================";
    std::cout << logoSpacer << " Untitled Game Debugging Command Line " << logoSpacer << std::endl;
    std::string command;
    std::cout << "DEBUG:";
    std::cin >> command;
    if (command == "nigga") {
        std::cerr << "Racism? Anyway, thats not a command lol";
        command = "*****";
    }

    std::cout << '\n' << "Command Entered: ";
    std::cout << command << std::endl;
}
