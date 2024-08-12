#include <SFML/Graphics.hpp>
#include <fstream>
#include <vector>
#include <string>
#include <windows.h> // For WinMain

// Function to load the level from a file
std::vector<sf::RectangleShape> loadLevel(const std::string& filename, const sf::Texture* floorTexture, const sf::Texture* platformTexture) {
    std::vector<sf::RectangleShape> tiles;
    std::ifstream file(filename);
    std::string line;
    int y = 0;

    while (std::getline(file, line)) {
        for (int x = 0; x < line.size(); ++x) {
            if (line[x] == '1' || line[x] == 'G') {
                sf::RectangleShape tile(sf::Vector2f(40.0f, 40.0f));
                if (line[x] == '1' && floorTexture) {
                    tile.setTexture(floorTexture);
                } else if (line[x] == 'G' && platformTexture) {
                    tile.setTexture(platformTexture);
                } else {
                    tile.setFillColor(line[x] == '1' ? sf::Color::Red : sf::Color::Blue);
                }
                tile.setPosition(x * 40.0f, y * 40.0f);
                tiles.push_back(tile);
            }
        }
        ++y;
    }

    return tiles;
}

int APIENTRY WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    sf::RenderWindow window(sf::VideoMode(800, 600), "Level Viewer");

    // Load textures
    sf::Texture floorTexture;
    if (!floorTexture.loadFromFile("./data/txd/floatingplatform.png")) {
        return -1;
    }

    sf::Texture platformTexture;
    if (!platformTexture.loadFromFile("./data/txd/base.png")) {
        return -1;
    }

    // Load level
    auto tiles = loadLevel("level.ini", &floorTexture, &platformTexture);

    // Create a large background texture to tile
    sf::Texture backgroundTexture;
    backgroundTexture.create(800, 600);
    sf::Sprite backgroundSprite(backgroundTexture);

    sf::Uint8* pixels = new sf::Uint8[800 * 600 * 4];
    for (int y = 0; y < 600; ++y) {
        for (int x = 0; x < 800; ++x) {
            // Background color
            pixels[(y * 800 + x) * 4 + 0] = 135; // Red
            pixels[(y * 800 + x) * 4 + 1] = 206; // Green
            pixels[(y * 800 + x) * 4 + 2] = 250; // Blue
            pixels[(y * 800 + x) * 4 + 3] = 255; // Alpha
        }
    }
    backgroundTexture.update(pixels);
    delete[] pixels;

    // Initial camera position
    sf::View view(sf::FloatRect(0, 0, 800, 600));
    window.setView(view);

    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        // Movement controls
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::A)) {
            view.move(-5, 0);
        }
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::D)) {
            view.move(5, 0);
        }

        window.setView(view);

        window.clear();
        window.draw(backgroundSprite);

        // Draw all tiles
        for (const auto& tile : tiles) {
            window.draw(tile);
        }

        window.display();
    }

    return 0;
}
