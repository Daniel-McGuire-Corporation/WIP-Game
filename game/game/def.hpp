#ifdef _WIN32
    #include <windows.h>
    #include <shellapi.h> // Windows-specific for shell operations
#elif __APPLE__
    #include <unistd.h> // macOS/Unix-specific
#endif

#include <iostream>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <sstream>
#include <thread>
#include <chrono>
#include <string>
#include <ctime>
#include <filesystem>

