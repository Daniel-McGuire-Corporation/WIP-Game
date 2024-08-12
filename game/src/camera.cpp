#include "camera.hpp"

void updateCamera(sf::RenderWindow& window, sf::RectangleShape& player) {
    sf::View view = window.getDefaultView();
    
    // Center the view on the player
    view.setCenter(player.getPosition().x + player.getSize().x / 2, window.getSize().y / 2);

    // Apply the view to the window
    window.setView(view);
}

