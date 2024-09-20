# Makefile for Hello World Programs

# Compiler settings
CC=gcc
CXX=g++
CSCSC=csc
JS=node

# Source files
C_SRC=hello.c
CPP_SRC=hello.cpp
CS_SRC=Hello.cs
JS_SRC=hello.js
HTML_SRC=hello.html
CSS_SRC=styles.css

# Output executables
C_OUT=hello_c
CPP_OUT=hello_cpp
CS_OUT=Hello.exe

# Default target
all: linux mac windows

# Linux target
linux: $(C_OUT) $(CPP_OUT) $(CS_OUT)
	@echo "Running Linux targets..."
	./$(C_OUT)
	./$(CPP_OUT)
	$(JS) $(JS_SRC)
	@echo "Open $(HTML_SRC) in a browser to see the output."

# Mac target (similar to Linux)
mac: $(C_OUT) $(CPP_OUT) $(CS_OUT)
	@echo "Running Mac targets..."
	./$(C_OUT)
	./$(CPP_OUT)
	$(JS) $(JS_SRC)
	@echo "Open $(HTML_SRC) in a browser to see the output."

# Windows target
windows: $(C_OUT).exe $(CPP_OUT).exe $(CS_OUT)
	@echo "Running Windows targets..."
	$(C_OUT).exe
	$(CPP_OUT).exe
	$(JS) $(JS_SRC)
	@echo "Open $(HTML_SRC) in a browser to see the output."

# Compile C program
$(C_OUT): $(C_SRC)
	$(CC) $(C_SRC) -o $(C_OUT)

# Compile C++ program
$(CPP_OUT): $(CPP_SRC)
	$(CXX) $(CPP_SRC) -o $(CPP_OUT)

# Compile C# program
$(CS_OUT): $(CS_SRC)
	$(CSCSC) $(CS_SRC) -out:$(CS_OUT)

# Clean up generated files
clean:
	rm -f $(C_OUT) $(CPP_OUT) $(CS_OUT) *.exe

.PHONY: all linux mac windows clean
