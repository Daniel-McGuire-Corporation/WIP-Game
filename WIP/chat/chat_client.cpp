// chat_client.cpp
#include <iostream>
#include <string>
#include <thread>
#include <vector>
#include <algorithm>
#include <unistd.h>  // for sleep function

#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "Ws2_32.lib")
#else
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <cstring>
#define closesocket close
#endif

void clear_screen() {
    #ifdef _WIN32
    system("cls");
    #else
    system("clear");
    #endif
}

void display_chat(const std::string& chat_history, const std::string& prompt) {
    // Clear the screen
    clear_screen();

    // Display the chat history
    std::cout << chat_history;

    // Print the chat prompt with one line of space above it
    std::cout << "\n" << prompt << " ";
    std::cout.flush();
}

void receive_messages(int client_socket, std::string& chat_history) {
    char buffer[1024];
    int bytes_received;

    while (true) {
        bytes_received = recv(client_socket, buffer, sizeof(buffer) - 1, 0);
        if (bytes_received > 0) {
            buffer[bytes_received] = '\0';
            chat_history += buffer;
            display_chat(chat_history, "CHAT:");
        } else {
            std::cout << "Connection closed or error occurred" << std::endl;
            break;
        }
    }
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "Usage: chat_client <host> <port>" << std::endl;
        return 1;
    }

    std::string host = argv[1];
    int port = std::stoi(argv[2]);

#ifdef _WIN32
    WSADATA wsaData;
    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
        std::cerr << "Failed to initialize WinSock" << std::endl;
        return 1;
    }
#endif

    int client_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (client_socket == -1) {
        std::cerr << "Socket creation failed" << std::endl;
        return 1;
    }

    sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port);
    inet_pton(AF_INET, host.c_str(), &server_addr.sin_addr);

    if (connect(client_socket, (sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        std::cerr << "Connection failed" << std::endl;
        return 1;
    }

    std::string username;
    std::cout << "Username: ";
    std::getline(std::cin, username);
    send(client_socket, username.c_str(), username.length(), 0);

    char buffer[1024];
    int bytes_received = recv(client_socket, buffer, sizeof(buffer) - 1, 0);
    if (bytes_received > 0) {
        buffer[bytes_received] = '\0';
        std::cout << buffer << std::endl;
    }

    std::string chat_history;
    std::thread(receive_messages, client_socket, std::ref(chat_history)).detach();

    std::string message;
    display_chat("!\nCHAT:", chat_history);
    while (true) {
        std::getline(std::cin, message);
        if (message == "exit") {
            std::cout << "Exiting..." << std::endl;
            break;
        }
        // Print the message sent by the user to their own screen
        chat_history += username + ": " + message + "\n";
        display_chat(chat_history, "CHAT:");
        send(client_socket, message.c_str(), message.length(), 0);
    }

    closesocket(client_socket);
#ifdef _WIN32
    WSACleanup();
#endif
    return 0;
}

