#include <SFML/Graphics.hpp>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <thread>
#include <chrono>
#include <windows.h> 
#include <filesystem> 
#include "../vari.hpp"

// Conditional inclusion of debug functionalities
#ifdef DEBUG_BUILD
#include "../debug/debug.hpp"
#endif

#include "game.hpp"

// Variables
const int TILE_SIZE = 40;
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

#ifdef DEBUG_BUILD
int main() {
#else
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
#endif
    std::cout << APP_NAME << std::endl;
    std::cout << "Copyright 2024 Daniel McGuire Corporation" << std::endl;

    sf::RenderWindow window(sf::VideoMode(800, 600), APP_NAME);

    // Load textures
    sf::Texture backgroundTexture;
    if (!backgroundTexture.loadFromFile("./data/txd/back.png")) {
        MessageBox(NULL, "Error loading background texture", "Texture Error", MB_ICONERROR | MB_OK);
        return -1; // Exit if texture loading fails
    }

    sf::Texture playerTexture;
    if (!playerTexture.loadFromFile("./data/txd/user.png")) {
        MessageBox(NULL, "Error loading player texture", "Texture Error", MB_ICONERROR | MB_OK);
        return -1; // Exit if texture loading fails
    }

    sf::Texture floorTexture;
    if (!floorTexture.loadFromFile("./data/txd/base.png")) {
        MessageBox(NULL, "Error loading floor texture", "Texture Error", MB_ICONERROR | MB_OK);
        return -1; // Exit if texture loading fails
    }

    sf::Texture platformTexture;
    if (!platformTexture.loadFromFile("./data/txd/platform.png")) {
        MessageBox(NULL, "Error loading platform texture", "Texture Error", MB_ICONERROR | MB_OK);
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
    std::this_thread::sleep_for(std::chrono::seconds(2));

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
        }

        window.clear();

        // Draw the background as tiles
        sf::Sprite backgroundSprite(backgroundTexture);
        int backgroundWidth = backgroundTexture.getSize().x;
        int backgroundHeight = backgroundTexture.getSize().y;
        int screenWidth = window.getSize().x;
        int screenHeight = window.getSize().y;
        for (int x = 0; x < screenWidth; x += backgroundWidth) {
            for (int y = 0; y < screenHeight; y += backgroundHeight) {
                backgroundSprite.setPosition(x, y);
                window.draw(backgroundSprite);
            }
        }

        updateCamera(window, player);

        window.draw(player);
        for (auto& platform : platforms) {
            window.draw(platform);
        }
        window.display();
    }

    return 0;
}