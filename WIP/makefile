# Makefile for Untitled Game

# Compiler and tools
CXX = g++
PYINSTALL = pyinstaller
FFMPEG = ffmpeg
CL = cl

# Directories
BIN_DIR = bin
TOOLS_DIR = tools/bin
TMP_DIR = tmp
THIRD_PARTY_DIR = 3rdpty
LEVELS_DIR = levels
ASSETS_DIR = assets/data
MUSIC_DIR = $(ASSETS_DIR)/music

# Sources
TWEAKER_SRC = tools/src/leveltweaker/leveltweaker.py
EDITOR_SRC = tools/src/leveledit/leveledit.cpp
VIEWER_SRC = tools/src/levelview/levelviewer.cpp
GAME_SRC = game/game/main.cpp
GAME_DEBUG_SRC = game/debug/debug.cpp

# Options
DEBUG = 0
CLEAN = 0
SETUP_ENGINE = 0

# Targets
all: compile run

compile: $(BIN_DIR)/game.exe $(BIN_DIR)/game-debug.exe $(TOOLS_DIR)/leveleditor.exe $(TOOLS_DIR)/leveltweaker.exe $(TOOLS_DIR)/levelviewer.exe

$(BIN_DIR)/game.exe: $(GAME_SRC) $(LEVELS_DIR)/demo.level
    @echo "Compiling game..."
    $(CL) /EHsc /nologo /std:c++17 /MP /DSFML_STATIC $(GAME_SRC) $(LEVELS_DIR)/demo.level /link /OUT:$@

$(BIN_DIR)/game-debug.exe: $(GAME_SRC) $(LEVELS_DIR)/demo.level
    @echo "Compiling debug game..."
    $(CL) /EHsc /nologo /std:c++17 /MP /DDEBUG_BUILD /DSFML_STATIC $(GAME_SRC) $(LEVELS_DIR)/demo.level /link /OUT:$@

$(TOOLS_DIR)/leveleditor.exe: $(EDITOR_SRC)
    @echo "Compiling level editor..."
    $(CL) /EHsc /nologo /std:c++17 /MP $(EDITOR_SRC) /link /OUT:$@

$(TOOLS_DIR)/leveltweaker.exe: $(TWEAKER_SRC)
    @echo "Compiling level tweaker..."
    $(PYINSTALL) --onefile --distpath $(TOOLS_DIR) --workpath $(TMP_DIR) $(TWEAKER_SRC)

$(TOOLS_DIR)/levelviewer.exe: $(VIEWER_SRC)
    @echo "Compiling level viewer..."
    $(CL) /EHsc /nologo /std:c++17 /MP $(VIEWER_SRC) /link /OUT:$@

setupengine:
    @echo "Downloading and setting up SFML..."
    @curl -L -o $(THIRD_PARTY_DIR)/sfml.zip https://www.sfml-dev.org/files/SFML-2.6.1-windows-vc17-32-bit.zip
    @unzip $(THIRD_PARTY_DIR)/sfml.zip -d $(THIRD_PARTY_DIR)

clean:
    @echo "Cleaning directories..."
    @rm -rf $(BIN_DIR)/*
    @rm -rf $(TOOLS_DIR)/*
    @rm -rf $(TMP_DIR)/*
    @rm -rf *.obj
    @rm -rf *.res
    @echo "Cleaned directories."

run: 
    @echo "Running game..."
    @$(BIN_DIR)/game.exe

.PHONY: all compile setupengine clean run