#include "MMFCppFunctions.hpp"
extern "C" {
#include "MMFCFunctions.h"
}

int main() {
    MMFCppFunctions::helloFromCpp();
    helloFromC();
    return 0;
}