#ifndef STRINGCENSOR_H
#define STRINGCENSOR_H

#include <string>
#include <vector>

namespace censor {
    // Initializes the censor by loading the words from the file
    void init(const std::string& filePath);

    // Censors the given input string based on the loaded censor words
    std::string string(const std::string& input);
}

#endif
