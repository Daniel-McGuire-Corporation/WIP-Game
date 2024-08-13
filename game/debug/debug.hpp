#ifndef DEBUG_HPP
#define DEBUG_HPP

#include <thread>
#include <atomic>

extern std::atomic<bool> running;

void handleDebugCommands();
void startDebugThread();

#endif // DEBUG_HPP
