#ifndef ENEMIE_HPP
#define ENEMIE_HPP

#include <SFML/Graphics.hpp>
#include <iostream>
#include <string>
#include <vector>

class Enemy {
public:
    Enemy(const sf::Texture& texture, float x, float y);

    void update(float playerX, float playerY);
    void draw(sf::RenderWindow& window);
    void takeDamage(float amount);
    bool isDead() const;
    bool isBelowScreen(float screenHeight) const;
    sf::FloatRect getBounds() const;
    sf::Vector2f getPosition() const;
    sf::Vector2f getSize() const;

private:
    sf::RectangleShape shape;
    float health;
    float velocityY;
    static const float GRAVITY;
};



void updateEnemies(std::vector<Enemy>& enemies, sf::RectangleShape& player, float screenHeight);
void handleEnemyCollisions(std::vector<Enemy>& enemies, sf::RectangleShape& player);

#endif // ENEMIE_HPP
