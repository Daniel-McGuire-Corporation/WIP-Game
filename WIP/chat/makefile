# Variables
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -pthread
WIN_CXX = cl
WIN_FLAGS = /EHsc
WIN_LIBS = ws2_32.lib

# Source files
SERVER_SOURCES = chat_server.cpp stringcensor.cpp
CLIENT_SOURCES = chat_client.cpp

# Targets
all: linux_server linux_client mac_client mac_server win_server win_client

# Linux
linux_server: $(SERVER_SOURCES)
	$(CXX) $(CXXFLAGS) -o linux_server $(SERVER_SOURCES)

linux_client: $(CLIENT_SOURCES)
	$(CXX) $(CXXFLAGS) -o linux_client $(CLIENT_SOURCES)

# macOS
mac_server: $(SERVER_SOURCES)
	$(CXX) $(CXXFLAGS) -o mac_server $(SERVER_SOURCES)

mac_client: $(CLIENT_SOURCES)
	$(CXX) $(CXXFLAGS) -o mac_client $(CLIENT_SOURCES)

# Windows
win_server: chat_server.cpp stringcensor.cpp
	$(WIN_CXX) $(WIN_FLAGS) chat_server.cpp stringcensor.cpp $(WIN_LIBS) /Fe:win_server.exe

win_client: $(CLIENT_SOURCES)
	$(WIN_CXX) $(WIN_FLAGS) $(CLIENT_SOURCES) $(WIN_LIBS) /Fe:win_client.exe

# Clean
clean:
	rm -f linux_server linux_client mac_server mac_client win_server.exe win_client.exe

.PHONY: all clean
