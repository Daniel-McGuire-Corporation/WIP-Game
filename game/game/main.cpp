#include "def.hpp"
#include "engine.hpp"
#include "dmc.hpp"

#include <iostream>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <sstream>
#include <thread>
#include <chrono>
#include <string>
#include <ctime>
#include <atomic>

// Platform-specific includes
#ifdef _WIN32
    #include <windows.h>
    #include <filesystem>
#elif __APPLE__
    #include <unistd.h>
    #include <filesystem>
    #include <dlfcn.h>
#endif

const int TILE_SIZE = 40;
const float DEATH_HEIGHT = 600.0f;
std::atomic<bool> running(true);
float musicVolume = 30.0f;

namespace fs = std::filesystem;

// Function to check collision between player and platform
bool isColliding(const sf::RectangleShape& player, const sf::RectangleShape& platform) {
    return player.getGlobalBounds().intersects(platform.getGlobalBounds());
}

// Function to handle player movement
void handlePlayerMovement(sf::RectangleShape& player, float& velocityY, bool& isJumping) {
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::Left)) {
        player.move(-MOVE_SPEED, 0.0f);
    }
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::Right)) {
        player.move(MOVE_SPEED, 0.0f);
    }
    if (sf::Keyboard::isKeyPressed(sf::Keyboard::Up) && !isJumping) {
        velocityY = -5.0f;
        isJumping = true;
    }
    
    // Apply gravity
    velocityY += GRAVITY;
    player.move(0.0f, velocityY);
}

// Function to load the level from a file
std::vector<sf::RectangleShape> loadLevel(const std::string& filename, const sf::Texture* floorTexture, const sf::Texture* platformTexture) {
    std::vector<sf::RectangleShape> platforms;
    std::ifstream file(filename);
    std::string line;
    int y = 0;

    while (std::getline(file, line)) {
        for (int x = 0; x < line.size(); ++x) {
            if (line[x] == '1' || line[x] == 'G') {
                sf::RectangleShape platform(sf::Vector2f(TILE_SIZE, TILE_SIZE));
                if (line[x] == '1' && platformTexture) {
                    platform.setTexture(platformTexture);
                } else if (line[x] == 'G' && floorTexture) {
                    platform.setTexture(floorTexture);
                } else {
                    platform.setFillColor(line[x] == '1' ? sf::Color::Red : sf::Color::Blue);
                }
                platform.setPosition(x * TILE_SIZE, y * TILE_SIZE);
                platforms.push_back(platform);
            }
        }
        ++y;
    }

    return platforms;
}

// Function to draw the background tiled across the screen
void drawTiledBackground(sf::RenderWindow& window, const sf::Texture& backgroundTexture) {
    sf::Sprite backgroundSprite;
    backgroundSprite.setTexture(backgroundTexture);

    // Get the size of the window
    sf::Vector2u windowSize = window.getSize();

    // Get the size of the texture
    sf::Vector2u textureSize = backgroundTexture.getSize();

    // Calculate the number of tiles needed to cover the width of the window
    unsigned int tilesX = (windowSize.x + textureSize.x - 1) / textureSize.x;

    // Draw the tiles horizontally
    for (unsigned int i = 0; i < tilesX; ++i) {
        backgroundSprite.setPosition(i * textureSize.x, 0);
        window.draw(backgroundSprite);
    }
}

void updateCamera(sf::RenderWindow& window, sf::RectangleShape& player) {
    sf::View view = window.getDefaultView();
    
    // Center the view on the player
    view.setCenter(player.getPosition().x + player.getSize().x / 2, window.getSize().y / 2);

    // Apply the view to the window
    window.setView(view);
}

bool asiLoader() {
    #ifdef _WIN32
    std::string folderPath = "./scripts/";
    #elif __APPLE__
    std::string folderPath = "/Users/" + std::string(getenv("USER")) + "/Library/Application Support/untitledgame/plug-ins/asitype/user";
    fs::create_directories(folderPath);
    #endif
    
    for (const auto& entry : fs::directory_iterator(folderPath)) {
        if (entry.path().extension() == ".asi" || entry.path().extension() == ".so") {
            #ifdef _WIN32
            HMODULE hModule = LoadLibraryW(entry.path().c_str());
            if (!hModule) {
                std::wcerr << L"Failed to load ASI: " << entry.path() << std::endl;
                return false;
            } else {
                std::wcout << L"Successfully loaded ASI: " << entry.path() << std::endl;
            }
            #elif __APPLE__
            void* hModule = dlopen(entry.path().c_str(), RTLD_NOW);
            if (!hModule) {
                std::cerr << "Failed to load ASI: " << entry.path() << std::endl;
                return false;
            } else {
                std::cout << "Successfully loaded ASI: " << entry.path() << std::endl;
            }
            #endif
        }
    }
    return true;
}

#ifdef DEBUG_BUILD
int main() {
#else
int main(int argc, char* argv[]) {
#endif
    #ifdef DEBUG_BUILD
    std::cout << APP_NAME << " Debug Prompt" << std::endl;
    #endif

    // Load ASIs from the specified folder
    if (!asiLoader()) {
        std::cerr << "ASI Loader experienced an error" << std::endl;
        #ifdef _WIN32
        MessageBoxA(NULL, "Error loading ASIs", "ASI Load Error", MB_ICONERROR | MB_OK);
        #endif
        return -1; // Exit if ASI loading fails
    }
    std::srand(static_cast<unsigned int>(std::time(nullptr)));

    #ifdef DEBUG_BUILD
    sf::RenderWindow window(sf::VideoMode(800, 600), "debug");
    #else
    sf::RenderWindow window(sf::VideoMode(800, 600), APP_NAME);
    #endif

    // Load textures based on platform
    std::string texturePath;
    #ifdef _WIN32
    texturePath = "./data/txd/";
    #elif __APPLE__
    texturePath = "/Applications/untitledgame.app/Contents/Resources/textures/";
    #endif

    sf::Texture backgroundTexture;
    if (!backgroundTexture.loadFromFile(texturePath + "back.png")) {
        std::cerr << "Error loading background texture" << std::endl;
        #ifdef _WIN32
        MessageBoxA(NULL, "Error loading background texture", "Texture Error", MB_ICONERROR | MB_OK);
        #endif
        return -1; // Exit if texture loading fails
    }

    sf::Texture playerTexture;
    if (!playerTexture.loadFromFile(texturePath + "user.png")) {
        std::cerr << "Error loading player texture" << std::endl;
        #ifdef _WIN32
        MessageBoxA(NULL, "Error loading player texture", "Texture Error", MB_ICONERROR | MB_OK);
        #endif
        return -1; // Exit if texture loading fails
    }

    sf::Texture floorTexture;
    if (!floorTexture.loadFromFile(texturePath + "base.png")) {
        std::cerr << "Error loading floor texture" << std::endl;
        #ifdef _WIN32
        MessageBoxA(NULL, "Error loading floor texture", "Texture Error", MB_ICONERROR | MB_OK);
        #endif
        return -1; // Exit if texture loading fails
    }

    sf::Texture platformTexture;
    if (!platformTexture.loadFromFile(texturePath + "platform.png")) {
        std::cerr << "Error loading platform texture" << std::endl;
        #ifdef _WIN32
        MessageBoxA(NULL, "Error loading platform texture", "Texture Error", MB_ICONERROR | MB_OK);
        #endif
        return -1; // Exit if texture loading fails
    }

    // Player setup
    sf::RectangleShape player(sf::Vector2f(40.0f, 40.0f));
    if (playerTexture.getSize().x > 0) {
        player.setTexture(&playerTexture);
    } else {
        player.setFillColor(sf::Color::Green);
    }
    player.setPosition(380.0f, -100.0f); // Start 280 pixels to the right of the original start position

    // Define a level file based on platform
    std::string levelFile;
    #ifdef _WIN32
    levelFile = "./data/levels/level1.ini";
    #elif __APPLE__
    levelFile = "/Applications/untitledgame.app/Contents/Resources/level.ini";
    #endif

    // Load the level
    std::vector<sf::RectangleShape> platforms = loadLevel(levelFile, floorTexture.getSize().x > 0 ? &floorTexture : nullptr, platformTexture.getSize().x > 0 ? &platformTexture : nullptr);

    #ifdef DEBUG_BUILD
    // Start the debug thread
    startDebugThread();
    #endif

    float velocityY = 0.0f; // Initialize velocityY
    bool isJumping = false; // Initialize isJumping
    std::vector<Enemy> enemies;
    sf::Texture enemyTexture;
    if (!enemyTexture.loadFromFile(texturePath + "enemy.png")) {
        std::cerr << "Error loading enemy texture" << std::endl;
        #ifdef _WIN32
        MessageBoxA(NULL, "Error loading enemy texture", "Texture Error", MB_ICONERROR | MB_OK);
        #endif
        return -1; // Exit if texture loading fails
    }

    // Main game loop
    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        handlePlayerMovement(player, velocityY, isJumping);
        updateCamera(window, player);

        window.clear();
        drawTiledBackground(window, backgroundTexture);
        for (const auto& platform : platforms) {
            window.draw(platform);
        }
        window.draw(player);
        window.display();
    }

    return 0;
}
