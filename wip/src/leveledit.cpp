#include <SFML/Graphics.hpp>
#include <nfd.h>
#include <fstream>
#include <iostream>
#include <vector>

const int tileSize = 40;
const int chunkWidth = 35;
const int gridWidth = 250;
const int gridHeight = 15;

class LevelEditor {
public:
    LevelEditor() : window(sf::VideoMode(tileSize * chunkWidth, tileSize * gridHeight), "Level Editor") {
        grid.resize(gridWidth, std::vector<int>(gridHeight, 0));
        view.reset(sf::FloatRect(0, 0, tileSize * chunkWidth, tileSize * gridHeight));
        createGrid();
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
                    handleKeyPress(event.key.code);
            }

            window.clear(sf::Color::White);
            drawGrid();
            window.display();
        }
    }

    std::string openFileDialog() {
        nfdchar_t *outPath = NULL;
        nfdresult_t result = NFD_OpenDialog(NULL, NULL, &outPath);

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

private:
    sf::RenderWindow window;
    sf::View view;
    std::vector<std::vector<int>> grid;

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
                    rectangle.setFillColor(sf::Color::White);
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

    void handleKeyPress(sf::Keyboard::Key key) {
        if (key == sf::Keyboard::Left)
            view.move(-tileSize, 0);
        else if (key == sf::Keyboard::Right)
            view.move(tileSize, 0);
        else if (key == sf::Keyboard::Up)
            view.move(0, -tileSize);
        else if (key == sf::Keyboard::Down)
            view.move(0, tileSize);
    }
};

int main() {
    LevelEditor editor;
    std::string filename = editor.openFileDialog();
    if (!filename.empty()) {
        editor.openFile(filename);
    }
    editor.run();
    return 0;
}
