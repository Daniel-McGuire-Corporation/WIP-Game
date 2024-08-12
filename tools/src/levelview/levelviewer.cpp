#include <SFML/Graphics.hpp>
#include <fstream>
#include <vector>
#include <string>
#include <windows.h> // For WinMain

// Function to load the level from a file
std::vector<sf::RectangleShape> loadLevel(const std::string& filename, const sf::Texture* floorTexture, const sf::Texture* platformTexture) {
    std::vector<sf::RectangleShape> tiles;
    std::ifstream file(filename);
    if (!file) {
        // Handle file open error
        return tiles;
    }

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

std::string openFileDialog() {
    OPENFILENAME ofn;       // Common dialog box structure
    char szFile[260] = {0}; // Buffer for file name

    // Initialize OPENFILENAME
    ZeroMemory(&ofn, sizeof(ofn));
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = NULL; // Set to the handle of your main window
    ofn.lpstrFile = szFile;
    ofn.nMaxFile = sizeof(szFile);
    ofn.lpstrFilter = "Level Files\0*.ini;*.level\0All Files\0*.*\0";
    ofn.nFilterIndex = 1;
    ofn.lpstrFileTitle = NULL;
    ofn.nMaxFileTitle = 0;
    ofn.lpstrInitialDir = NULL;
    ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

    // Display the Open File dialog box
    if (GetOpenFileName(&ofn) == TRUE) {
        return std::string(ofn.lpstrFile);
    }

    return ""; // Return an empty string if no file was selected
}

#include <SFML/Graphics.hpp>
#include <fstream>
#include <vector>
#include <string>
#include <windows.h> // For WinMain

// ... [rest of your code]

int APIENTRY WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    sf::RenderWindow window(sf::VideoMode(800, 600), "Level Viewer");

    // Load textures
    sf::Texture floorTexture;
    if (!floorTexture.loadFromFile("./data/txd/platform.png")) {
        return -1;
    }

    sf::Texture platformTexture;
    if (!platformTexture.loadFromFile("./data/txd/base.png")) {
        return -1;
    }

    std::string levelFile;
    bool levelLoaded = false;

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

        // Check for Ctrl+O to open the file dialog
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::LControl) && sf::Keyboard::isKeyPressed(sf::Keyboard::O)) {
            if (!levelLoaded) { // Avoid opening multiple dialogs
                levelFile = openFileDialog();
                if (!levelFile.empty()) {
                    // Load level
                    auto tiles = loadLevel(levelFile, &floorTexture, &platformTexture);
                    levelLoaded = true; // Mark level as loaded
                }
            }
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

        // Draw all tiles if level is loaded
        if (levelLoaded) {
            for (const auto& tile : loadLevel(levelFile, &floorTexture, &platformTexture)) {
                window.draw(tile);
            }
        }

        window.display();
    }

    return 0;
}
