# Define the project name
PROJECT_NAME = MakeGUI

# Define directories
BUILD_DIR = .build
SRC_DIR = Sources/$(PROJECT_NAME)

# Targets
all: build

build:
	@echo "Building $(PROJECT_NAME)..."
	swift build

run:
	@echo "Running $(PROJECT_NAME)..."
	swift run $(PROJECT_NAME)

test:
	@echo "Testing $(PROJECT_NAME)..."
	swift test

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	swift package clean

.PHONY: all build run test clean

