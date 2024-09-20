// CHAT_SERVER.CPP 
//  Written by Daniel McGuire Thu Sep 19 2:14PM CST (OSX, 15.0.0)
//
//  Name: untitledgame Chat Service
//
//  Purpose: Chat Service for untitledgame Multiplayer (WIP)
// This file may be commented very much, as it is in a few of my c++ videos.
#include <iostream> 
#include <string>   
#include <vector>   
#include <thread>
#include <mutex>
#include <atomic>
#include <unordered_map>
#include <deque>
#include <algorithm>
#include "chatheaders/StringCensor.hpp"  // Include the censoring functionality
// Networking:
#ifdef _WIN32 // If Windows:
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "Ws2_32.lib")
#else // If not windows:
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <cstring>
#define closesocket close
#endif

std::vector<int> clients;
std::mutex clients_mutex;
std::atomic<bool> running(true);
std::unordered_map<int, std::string> client_usernames;
std::deque<std::string> chat_history;
const size_t MAX_HISTORY_SIZE = 100; // Limit history size to 100 messages

void broadcast_message(const std::string& message, int sender_socket) {
    std::lock_guard<std::mutex> lock(clients_mutex);
    for (int client : clients) {
        if (client != sender_socket) {
            send(client, message.c_str(), message.length(), 0);
        }
    }
}
   
void handle_client(int client_socket) {
    std::cout << "Client handler started for socket: " << client_socket << std::endl;
    char buffer[1024];
    int bytes_received;

    // Prompt for username
    std::string username;
    std::string welcome_msg = "Username: " + username + "\n";
    send(client_socket, welcome_msg.c_str(), welcome_msg.length(), 0);

    bytes_received = recv(client_socket, buffer, sizeof(buffer) - 1, 0);
    if (bytes_received > 0) {
        buffer[bytes_received] = '\0';
        username = std::string(buffer);
        client_usernames[client_socket] = username;

        // Announce user joining
        std::string join_announcement = username + " has joined the chat.\n";
        broadcast_message(join_announcement, client_socket);
        std::cout << join_announcement << std::endl;

        // Send chat history to the new user
        for (const std::string& msg : chat_history) {
            send(client_socket, msg.c_str(), msg.length(), 0);
        }

        std::string welcome = "Welcome, " + username + "!\n";
        send(client_socket, welcome.c_str(), welcome.length(), 0);
    }

    while (running) {
        bytes_received = recv(client_socket, buffer, sizeof(buffer) - 1, 0);
        if (bytes_received > 0) {
            buffer[bytes_received] = '\0';
            std::string message = client_usernames[client_socket] + ": " + buffer;

            // Censor the message before broadcasting
            std::string censored_message = censor::string(message);

            std::cout << censored_message << std::endl;

            // Add censored message to chat history
            chat_history.push_back(censored_message);
            if (chat_history.size() > MAX_HISTORY_SIZE) {
                chat_history.pop_front(); // Remove oldest message
            }

            // Broadcast the censored message to all clients
            broadcast_message(censored_message, client_socket);
        } else {
            std::cout << "Client " << client_usernames[client_socket];
            std::cout << "@socket." << client_socket << " lost connection.\n";
            break;
        }
    }

    // Announce user leaving
    {
        std::lock_guard<std::mutex> lock(clients_mutex);
        std::string leave_announcement = client_usernames[client_socket] + " has left the chat.\n";
        broadcast_message(leave_announcement, client_socket);
        std::cout << leave_announcement << std::endl;
        clients.erase(std::remove(clients.begin(), clients.end(), client_socket), clients.end());
        client_usernames.erase(client_socket);
    }

    closesocket(client_socket);
}

int main() {
#ifdef _WIN32
    WSADATA wsaData;
    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
        std::cerr << "Failed to initialize WinSock" << std::endl;
        return 1;
    }
#endif

    // Initialize the censoring system with the wordlist
    censor::init("./wordlist.txt");

    int server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket == -1) {
        std::cerr << "Socket creation failed" << std::endl;
        return 1;
    }

    sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(8647);

    if (bind(server_socket, (sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        std::cerr << "Bind failed" << std::endl;
        return 1;
    }

    if (listen(server_socket, 5) < 0) {
        std::cerr << "Listen failed" << std::endl;
        return 1;
    }

    std::cout << "Server is running on port 8647" << std::endl;

    while (running) {
        sockaddr_in client_addr;
        socklen_t client_addr_len = sizeof(client_addr);
        int client_socket = accept(server_socket, (sockaddr*)&client_addr, &client_addr_len);

        if (client_socket >= 0) {
            std::cout << "Accepted connection from client socket: " << client_socket << std::endl;
            std::lock_guard<std::mutex> lock(clients_mutex);
            clients.push_back(client_socket);
            std::thread(handle_client, client_socket).detach();
        } else {
            std::cerr << "Accept failed" << std::endl;
        }
    }

    closesocket(server_socket);
#ifdef _WIN32
    WSACleanup();
#endif
    return 0;
}
