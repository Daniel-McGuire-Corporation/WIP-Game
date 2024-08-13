#include <windows.h>

constexpr uintptr_t OFFSET = 0x4C020; // Your module-relative offset

void __cdecl ModifyGameSpeed() {
    // Get the base address of the module
    HMODULE hModule = GetModuleHandleW(L"game-debug.exe");
    if (hModule) {
        // Calculate the actual address
        uintptr_t address = reinterpret_cast<uintptr_t>(hModule) + OFFSET;
        float* speedControl = reinterpret_cast<float*>(address);
        if (speedControl) {
            *speedControl = 5.0f; // Set the speed to 2.0
        }
    } else {
        MessageBoxW(NULL, L"Error: Could not get module handle.", L"Error", MB_ICONERROR | MB_OK);
    }
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
    case DLL_PROCESS_ATTACH:
        ModifyGameSpeed();
        break;
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
