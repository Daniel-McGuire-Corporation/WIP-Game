#include "StringCensor.h"
#include <fstream>
#include <sstream>
#include <algorithm>

// List of words to be censored
std::vector<std::string> censorWords;

// Method to load the censor words from the file
void censor::init(const std::string& filePath) {
    std::ifstream file(filePath);
    std::string line;
    while (std::getline(file, line)) {
        // Strip any extra spaces
        line.erase(std::remove_if(line.begin(), line.end(), ::isspace), line.end());
        if (!line.empty()) {
            censorWords.push_back(line);
        }
    }
}

// Method to censor a word by replacing all but the first letter with '*'
std::string censorWord(const std::string& word) {
    if (word.length() <= 1) return word;  // If the word is only 1 character, return as is
    return word[0] + std::string(word.length() - 1, '*');
}

// Method to censor a given string by replacing censored words
std::string censor::string(const std::string& input) {
    std::string result = input;

    // Iterate through each word in the censor list
    for (const std::string& word : censorWords) {
        size_t pos = result.find(word);
        while (pos != std::string::npos) {
            // Replace the word with its censored version
            result.replace(pos, word.length(), censorWord(word));
            pos = result.find(word, pos + 1);
        }
    }

    return result;
}
