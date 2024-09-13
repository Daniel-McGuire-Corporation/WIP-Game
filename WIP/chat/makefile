# Variables
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -pthread
WIN_CXX = cl
WIN_FLAGS = /EHsc
WIN_LIBS = ws2_32.lib

# Targets
all: linux_server linux_client mac_client mac_server win_server win_client

# Linux
linux_server: chat_server.cpp
	$(CXX) $(CXXFLAGS) -o linux_server chat_server.cpp

linux_client: chat_client.cpp
	$(CXX) $(CXXFLAGS) -o linux_client chat_client.cpp

# macOS
mac_server: chat_server.cpp
	$(CXX) $(CXXFLAGS) -o mac_server chat_server.cpp

mac_client: chat_client.cpp
	$(CXX) $(CXXFLAGS) -o mac_client chat_client.cpp

# Windows
win_server: chat_server.cpp
	$(WIN_CXX) $(WIN_FLAGS) chat_server.cpp $(WIN_LIBS) /Fe:win_server.exe

win_client: chat_client.cpp
	$(WIN_CXX) $(WIN_FLAGS) chat_client.cpp $(WIN_LIBS) /Fe:win_client.exe

# Clean
clean:
	rm -f linux_server linux_client mac_server mac_client win_server.exe win_client.exe

.PHONY: all clean
