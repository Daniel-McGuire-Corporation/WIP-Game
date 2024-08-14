#include <SFML/Graphics.hpp>
#include <iostream>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <sstream>
#include <thread>
#include <chrono>
#include <string>
#include <windows.h> 
#include <filesystem>
#include "../ai/enemy.hpp" 
#include "../vari.hpp"
#include "game.hpp"
#include <shellapi.h>
#include "../debug/debug.hpp"


// Variables
const int TILE_SIZE = 40;
const float DEATH_HEIGHT = 600.0f;
std::atomic<bool> running(true);

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
    std::string folderPath = "./scripts/";
    for (const auto& entry : fs::directory_iterator(folderPath)) {
        if (entry.path().extension() == ".asi") {
            HMODULE hModule = LoadLibraryW(entry.path().c_str()); // Use LoadLibraryW for wide characters
            if (!hModule) {
                std::wcerr << L"Failed to load ASI: " << entry.path() << std::endl;
                return false;
            } else {
                std::wcout << L"Successfully loaded ASI: " << entry.path() << std::endl;
            }
        }
    }
    return true;
}

// Function to show a notification

#ifdef DEBUG_BUILD
int main() {
#else
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
#endif
    std::cout << APP_NAME << "Debug Prompt (C++ 17)" << std::endl;

    // Load ASIs from the ./scripts/ folder
    if (!asiLoader()) {
        std::cerr << "ASI Loader experienced an error" << std::endl;
        MessageBoxA(NULL, "Error loading ASIs", "ASI Load Error", MB_ICONERROR | MB_OK);

        return -1; // Exit if ASI loading fails
    }

    #ifdef DEBUG_BUILD
    sf::RenderWindow window(sf::VideoMode(800, 600), "debug");
    #else
    sf::RenderWindow window(sf::VideoMode(800, 600), APP_NAME);
    #endif

    // Load textures
    sf::Texture backgroundTexture;
    if (!backgroundTexture.loadFromFile("./data/txd/back.png")) {
        std::cerr << "Error loading background texture" << std::endl;   
        MessageBoxA(NULL, "Error loading background texture", "Texture Error", MB_ICONERROR | MB_OK);
        return -1; // Exit if texture loading fails
    }

    sf::Texture playerTexture;
    if (!playerTexture.loadFromFile("./data/txd/user.png")) {
        std::cerr << "Error loading player texture" << std::endl;
        MessageBoxA(NULL, "Error loading player texture", "Texture Error", MB_ICONERROR | MB_OK);
        return -1; // Exit if texture loading fails
    }

    sf::Texture floorTexture;
    if (!floorTexture.loadFromFile("./data/txd/base.png")) {
        std::cerr << "Error loading floor texture" << std::endl;
        MessageBoxA(NULL, "Error loading floor texture", "Texture Error", MB_ICONERROR | MB_OK);
        return -1; // Exit if texture loading fails
    }

    sf::Texture platformTexture;
    if (!platformTexture.loadFromFile("./data/txd/platform.png")) {
        std::cerr << "Error loading platform texture" << std::endl;
        MessageBoxA(NULL, "Error loading platform texture", "Texture Error", MB_ICONERROR | MB_OK);
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

    // Define a level file
    std::string levelFile = "data/levels/level1.ini"; // Set the level file here

    // Load the level
    std::vector<sf::RectangleShape> platforms = loadLevel(levelFile, floorTexture.getSize().x > 0 ? &floorTexture : nullptr, platformTexture.getSize().x > 0 ? &platformTexture : nullptr);

    #ifdef DEBUG_BUILD
    // Start the debug thread
    startDebugThread();
    #endif

    // Wait for 2 seconds before dropping the player
    #ifdef DEBUG_BUILD
    std::this_thread::sleep_for(std::chrono::seconds(10));
    #endif
    float velocityY = 0.0f; // Initialize velocityY
    bool isJumping = false; // Initialize isJumping
    std::vector<Enemy> enemies;
    sf::Texture enemyTexture;
    if (!enemyTexture.loadFromFile("./data/txd/enemy.png")) {
        std::cerr << "Error loading enemy texture" << std::endl;
        MessageBoxA(NULL, "Error loading enemy texture", "Texture Error", MB_ICONERROR | MB_OK);
        return -1; // Exit if texture loading fails
    }

    // Spawn initial enemies
    for (int i = 0; i < 3; ++i) {
        enemies.emplace_back(enemyTexture, 100.0f * i, 0.0f); // Spawn enemies at different x positions
    }

    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        // Check if the window is focused and the game is running before handling input
        if (window.hasFocus() && running) {
            // Handle player movement
            handlePlayerMovement(player, velocityY, isJumping);

            // Collision detection with platforms
            for (auto& platform : platforms) {
                if (isColliding(player, platform)) {
                    player.setPosition(player.getPosition().x, platform.getPosition().y - player.getSize().y);
                    velocityY = 0.0f;
                    isJumping = false;
                }
            }

            // Update enemies
            updateEnemies(enemies, player, window.getSize().y);

            // Handle enemy collisions
            handleEnemyCollisions(enemies, player);

            // Check if the player has fallen below the death height
            if (player.getPosition().y > DEATH_HEIGHT) {
                std::cout << "Player fell below cutoff." << std::endl;
                MessageBoxA(NULL, "You walked off the edge!", "You Died!", MB_ICONERROR | MB_OK);
            }
        }

        window.clear();

        // Draw the background as tiles
        drawTiledBackground(window, backgroundTexture);

        updateCamera(window, player);

        window.draw(player);
        for (auto& platform : platforms) {
            window.draw(platform);
        }
        for (auto& enemy : enemies) {
            enemy.draw(window);
        }
        window.display();
    }

    return 0;
}
