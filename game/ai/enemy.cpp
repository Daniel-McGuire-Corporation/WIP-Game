#include "enemy.hpp"
#include <iostream>
#include <string>
#include <vector>
#include <SFML/Graphics.hpp>

const float Enemy::GRAVITY = 0.2f;

Enemy::Enemy(const sf::Texture& texture, float x, float y) : health(100.0f), velocityY(0.0f) {
    shape.setSize(sf::Vector2f(40.0f, 40.0f));
    shape.setTexture(&texture);
    shape.setPosition(x, y);
}

void Enemy::update(float playerX, float playerY) {
    // Basic AI to move towards the player
    float dx = playerX - shape.getPosition().x;
    shape.move(std::clamp(dx * 0.01f, -1.0f, 1.0f), velocityY);
    
    // Apply gravity
    velocityY += GRAVITY;
    shape.move(0.0f, velocityY);
}

void Enemy::draw(sf::RenderWindow& window) {
    window.draw(shape);
}

void Enemy::takeDamage(float amount) {
    health -= amount;
    if (health < 0.0f) health = 0.0f;
}

bool Enemy::isDead() const {
    return health <= 0.0f;
}

bool Enemy::isBelowScreen(float screenHeight) const {
    return shape.getPosition().y > screenHeight;
}

sf::FloatRect Enemy::getBounds() const {
    return shape.getGlobalBounds();
}

sf::Vector2f Enemy::getPosition() const {
    return shape.getPosition();
}

sf::Vector2f Enemy::getSize() const {
    return shape.getSize();
}

void updateEnemies(std::vector<Enemy>& enemies, sf::RectangleShape& player, float screenHeight) {
    for (auto it = enemies.begin(); it != enemies.end(); ) {
        it->update(player.getPosition().x, player.getPosition().y);

        if (it->isBelowScreen(screenHeight) || it->isDead()) {
            it = enemies.erase(it);
        } else {
            ++it;
        }
    }
}

void handleEnemyCollisions(std::vector<Enemy>& enemies, sf::RectangleShape& player) {
    for (auto& enemy : enemies) {
        if (player.getGlobalBounds().intersects(enemy.getBounds())) {
            std::cout << "Collision detected between player and enemy at position: "
                      << player.getPosition().x << ", " << player.getPosition().y << std::endl;

            if (player.getPosition().y + player.getSize().y / 2 < enemy.getPosition().y) {
                enemy.takeDamage(50.0f);
                player.setPosition(player.getPosition().x, player.getPosition().y - 10.0f);
            } else {
                // Enemy deals damage to the player
                player.setPosition(player.getPosition().x, player.getPosition().y - 10.0f);
            }
        }
    }
}
