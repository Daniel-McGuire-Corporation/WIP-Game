#ifndef GAME_HPP
#define GAME_HPP
#include <SFML/Graphics.hpp>


const std::string APP_NAME = "Platformer Game";

extern sf::RectangleShape player;
extern float velocityY;
extern bool isJumping;

void resetGame();

#endif // GAME_HPP
