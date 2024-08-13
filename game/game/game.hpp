#ifndef GAME_HPP
#define GAME_HPP
#include <SFML/Graphics.hpp>


const std::string APP_NAME = "wierd stickman jump";

extern sf::RectangleShape player;
extern float velocityY;
extern bool isJumping;

void resetGame();

#endif // GAME_HPP
