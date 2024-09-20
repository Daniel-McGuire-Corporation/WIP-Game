# Variables
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -pthread
WIN_CXX = cl
WIN_FLAGS = /EHsc /NOLOGO
WIN_LIBS = ws2_32.lib

# Determine Python command
PYTHON = $(shell command -v python3 2>/dev/null || command -v python 2>/dev/null)
# Determine pip command
PIP = $(shell command -v pip3 2>/dev/null || command -v pip 2>/dev/null || $(PYTHON) -m pip)

# Source files
SERVER_SOURCES = chat_server.cpp stringcensor.cpp
CLIENT_SOURCES = chat_client.cpp
GUI_SOURCE = chat_clientgui.py

# Project Titles
LINUX_SERVER_NAME = "Chat Server"
LINUX_CLIENT_NAME = "Debug Client"
LINUX_GUI_NAME = "In-Game Chat Component"
MAC_SERVER_NAME = "Chat Server"
MAC_CLIENT_NAME = "Debug Client"
MAC_GUI_NAME = "In-Game Chat Component"
WIN_SERVER_NAME = "Chat Server"
WIN_CLIENT_NAME = "Debug Client"
WIN_GUI_NAME = "In-Game Chat Component"
GUI_EXT = "chatugmp"
GUIV_NAME = "chatclient"

# Detect OS and architecture
OS := $(shell uname)
ARCH := $(shell uname -m)

# Set output directory
BIN_DIR = bin/$(OS)/$(ARCH)

# Print project name and OS before compiling
define print_info
	@if [ "$(OS)" = "Linux" ]; then \
		echo "Compiling $(1) for Linux $$(uname -r) $$(uname -m)"; \
	elif [ "$(OS)" = "Darwin" ]; then \
		echo "Compiling $(1) for macOS $$(sw_vers -productVersion) $$(uname -m)"; \
	else \
		echo "Compiling $(1) for Windows $$(ver)"; \
	fi
endef

# Help target
help:
	@if [ -f ./.makehelp ]; then \
		cat ./.makehelp; \
	else \
		echo "Help file not found."; \
	fi

# Targets
all: linux_server linux_client mac_server mac_client win_server win_client mac_guiclient

# Requirements
requirements:
	@./makehelper.sh install

# Output file variables
LINUX_SERVER_OUT = $(BIN_DIR)/linux_server.out
LINUX_CLIENT_OUT = $(BIN_DIR)/linux_client.out
MAC_SERVER_OUT = $(BIN_DIR)/mac_server
MAC_CLIENT_OUT = $(BIN_DIR)/mac_client
WIN_SERVER_OUT = $(BIN_DIR)/win_server.exe
WIN_CLIENT_OUT = $(BIN_DIR)/win_client.exe
MAC_GUI_DIR = $(BIN_DIR)/$(GUI_EXT).app
WIN_GUI_DIR = $(BIN_DIR)/$(GUI_EXT).exe
LINUX_GUI_DIR = $(BIN_DIR)/$(GUI_EXT).out

# Linux targets
linux_server: $(SERVER_SOURCES:.cpp=.o)
	$(call print_info, $(LINUX_SERVER_NAME))
	@mkdir -p $(BIN_DIR)
	@$(CXX) $(CXXFLAGS) -o $(LINUX_SERVER_OUT) $^

linux_client: $(CLIENT_SOURCES:.cpp=.o)
	$(call print_info, $(LINUX_CLIENT_NAME))
	@mkdir -p $(BIN_DIR)
	@$(CXX) $(CXXFLAGS) -o $(LINUX_CLIENT_OUT) $^

mac_guiclient: 
	$(call print_info, $(LINUX_GUI_NAME))
	@pyinstaller --onefile --name $(GUI_EXT) --distpath $(BIN_DIR) $(GUI_SOURCE)

# macOS targets
mac_server: $(SERVER_SOURCES:.cpp=.o)
	$(call print_info, $(MAC_SERVER_NAME))
	@mkdir -p $(BIN_DIR)
	@clang++ $(CXXFLAGS) -o $(MAC_SERVER_OUT) $^

mac_client: $(CLIENT_SOURCES:.cpp=.o)
	$(call print_info, $(MAC_CLIENT_NAME))
	@mkdir -p $(BIN_DIR)
	@clang++ $(CXXFLAGS) -o $(MAC_CLIENT_OUT) $^

# Windows targets
win_server: $(SERVER_SOURCES:.cpp=.o)
	$(call print_info, $(WIN_SERVER_NAME))
	@mkdir -p $(BIN_DIR)
	@$(WIN_CXX) $(WIN_FLAGS) -o $(WIN_SERVER_OUT) $^

win_client: $(CLIENT_SOURCES:.cpp=.o)
	$(call print_info, $(WIN_CLIENT_NAME))
	@mkdir -p $(BIN_DIR)
	@$(WIN_CXX) $(WIN_FLAGS) -o $(WIN_CLIENT_OUT) $^

win_guiclient: 
	$(call print_info, $(WIN_GUI_NAME))
	@pyinstaller --onefile --name $(GUI_EXT) --distpath $(BIN_DIR) $(GUI_SOURCE)

# Clean target
clean:
	@echo "Cleaning up build artifacts..."
	rm -rf bin/ build/ dist/ *.spec
	@echo "Clean complete."

# Object file rule
%.o: %.cpp
	@$(CXX) $(CXXFLAGS) -c $< -o $@
