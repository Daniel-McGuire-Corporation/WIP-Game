#include <SFML/Graphics.hpp>
#include <nfd.h>
#include <SFML/Window.hpp>
#include <Windows.h>
#include <fstream>
#include <iostream>
#include <vector>
#include <cstring>
#include <thread>
#include <chrono>
#include <SFML/System.hpp>
#include <filesystem>


const int tileSize = 40;
const int chunkWidth = 35;
const int gridWidth = 250;
const int gridHeight = 15;

class LevelEditor {
public:
    LevelEditor(bool develMode) : window(sf::VideoMode(tileSize * chunkWidth, tileSize * gridHeight), "Level Editor"), develMode(develMode) {
        grid.resize(gridWidth, std::vector<int>(gridHeight, 0));
        view.reset(sf::FloatRect(0, 0, tileSize * chunkWidth, tileSize * gridHeight));
        createGrid();
    }
    void handleResize(int newWidth, int newHeight) {
    // Adjust the view to the new window size
    sf::FloatRect visibleArea(0, 0, newWidth, newHeight);
    window.setView(sf::View(visibleArea));

    // Optionally, reset the view to maintain the original aspect ratio
    float aspectRatio = static_cast<float>(newWidth) / static_cast<float>(newHeight);
    view.setSize(tileSize * chunkWidth * aspectRatio, tileSize * gridHeight);
    view.setViewport(sf::FloatRect(0, 0, 1.0f, 1.0f));
    window.setView(view);
    }


    void run() {
    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            if (event.type == sf::Event::Closed)
                window.close();
            if (event.type == sf::Event::MouseButtonPressed)
                onCanvasClick(event.mouseButton.x, event.mouseButton.y);
            if (event.type == sf::Event::KeyPressed)
                handleKeyPress(event.key);
            if (event.type == sf::Event::Resized)
                handleResize(event.size.width, event.size.height);
        }

        window.clear(sf::Color::White);
        drawGrid();
        window.display();
    }
    }


    std::string openFileDialog() {
        nfdchar_t *outPath = NULL;
        nfdresult_t result;
        if (develMode) {
            result = NFD_OpenDialog("ini,level", NULL, &outPath);
        } else {
            result = NFD_OpenDialog("ini", NULL, &outPath);
        }

        if (result == NFD_OKAY) {
            std::string path(outPath);
            free(outPath);
            return path;
        } else if (result == NFD_CANCEL) {
            std::cout << "User pressed cancel." << std::endl;
        } else {
            std::cout << "Error: " << NFD_GetError() << std::endl;
        }
        return "";
    }

    void openFile(const std::string& filename) {
        std::ifstream file(filename);
        if (file.is_open()) {
            std::string line;
            int y = 0;
            while (std::getline(file, line) && y < gridHeight) {
                for (int x = 0; x < gridWidth && x < line.size(); ++x) {
                    if (line[x] == '1')
                        grid[x][y] = 1;
                    else if (line[x] == 'G')
                        grid[x][y] = 2;
                    else
                        grid[x][y] = 0;
                }
                ++y;
            }
            file.close();
        } else {
            std::cerr << "Unable to open file: " << filename << std::endl;
        }
    }

    void saveFile(const std::string& filename) {
        std::ofstream file(filename);
        if (file.is_open()) {
            for (int j = 0; j < gridHeight; ++j) {
                for (int i = 0; i < gridWidth; ++i) {
                    if (grid[i][j] == 1)
                        file << '1';
                    else if (grid[i][j] == 2)
                        file << 'G';
                    else
                        file << '0';
                }
                file << '\n';
            }
            file.close();
        } else {
            std::cerr << "Unable to save file: " << filename << std::endl;
        }
    }

    std::string saveFileDialog() {
        nfdchar_t *outPath = NULL;
        nfdresult_t result = NFD_SaveDialog("ini", NULL, &outPath);

        if (result == NFD_OKAY) {
            std::string path(outPath);
            free(outPath);
            return path;
        } else if (result == NFD_CANCEL) {
            std::cout << "User pressed cancel." << std::endl;
        } else {
            std::cout << "Error: " << NFD_GetError() << std::endl;
        }
        return "";
    }

    std::string currentFilename; // Move this to public section

private:
    sf::RenderWindow window;
    sf::View view;
    std::vector<std::vector<int>> grid;
    bool develMode;

    void createGrid() {
        for (int i = 0; i < gridWidth; ++i) {
            for (int j = 0; j < gridHeight; ++j) {
                grid[i][j] = 0;
            }
        }
    }

    void drawGrid() {
        window.setView(view);
        for (int i = 0; i < gridWidth; ++i) {
            for (int j = 0; j < gridHeight; ++j) {
                sf::RectangleShape rectangle(sf::Vector2f(tileSize, tileSize));
                rectangle.setPosition(i * tileSize, j * tileSize);
                rectangle.setOutlineColor(sf::Color::Black);
                rectangle.setOutlineThickness(1);

                if (grid[i][j] == 0)
                    rectangle.setFillColor(sf::Color::Blue);
                else if (grid[i][j] == 1)
                    rectangle.setFillColor(sf::Color::Red);
                else if (grid[i][j] == 2)
                    rectangle.setFillColor(sf::Color::Green);

                window.draw(rectangle);
            }
        }
    }

    void onCanvasClick(int mouseX, int mouseY) {
        // Convert mouse coordinates to world coordinates
        sf::Vector2f worldPos = window.mapPixelToCoords(sf::Vector2i(mouseX, mouseY), view);
        int x = worldPos.x / tileSize;
        int y = worldPos.y / tileSize;
        if (x < gridWidth && y < gridHeight) {
            grid[x][y] = (grid[x][y] + 1) % 3;
        }
    }

    void handleKeyPress(sf::Event::KeyEvent key) {
    if (key.code == sf::Keyboard::Left)
        view.move(-tileSize, 0);
    else if (key.code == sf::Keyboard::Right)
        view.move(tileSize, 0);
    else if (key.code == sf::Keyboard::Up)
        view.move(0, -tileSize);
    else if (key.code == sf::Keyboard::Down)
        view.move(0, tileSize);
    else if (key.code == sf::Keyboard::S && key.control && key.shift) {
        std::string filename = saveFileDialog();
        if (!filename.empty()) {
            currentFilename = filename;
            saveFile(filename);
        }
    } else if (key.code == sf::Keyboard::S && key.control) {
        if (currentFilename.empty()) {
            currentFilename = saveFileDialog();
        }
        if (!currentFilename.empty()) {
            saveFile(currentFilename);
        }
    } else if (key.code == sf::Keyboard::O && key.control) {
        std::string filename = openFileDialog();
        if (!filename.empty()) {
            openFile(filename);
            currentFilename = filename;
        }
    } else if (key.code == sf::Keyboard::L && key.control) {
        std::string gamePath = "../../bin/game.exe";
        if (!std::filesystem::exists(gamePath)) {
            gamePath = "../../bin/game-debug.exe";
        }

        if (std::filesystem::exists(gamePath)) {
            system(("start " + gamePath).c_str());
        } else {
            std::cerr << "Error: Neither game.exe nor game-debug.exe could be found." << std::endl;
        }
    } else if (key.code == sf::Keyboard::P && key.control) {
        std::string levelViewerPath = "levelviewer.exe";
        system(("start " + levelViewerPath).c_str());
    } else if (key.code == sf::Keyboard::D && key.control && key.shift) {
        develMode = !develMode;
        std::cout << "Developer Mode " << (develMode ? "Enabled" : "Disabled") << std::endl;
    }
}
};

#ifdef DEBUG_BUILD
int main(int argc, char* argv[]) {
#else
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
#endif
    bool develMode = false;

#ifdef DEBUG_BUILD
    if (argc > 1 && std::strcmp(argv[1], "--devel") == 0) {
#else
    if (__argc > 1 && std::strcmp(__argv[1], "--devel") == 0) {
#endif
        develMode = true;
    }

    LevelEditor editor(develMode);
    std::string filename = editor.openFileDialog();
    if (!filename.empty()) {
        editor.openFile(filename);
        editor.currentFilename = filename;
    }
    editor.run();

    return 0;
}


