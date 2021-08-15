#!/bin/bash
APP_NAME="app_name"
COMMON_HEADER="include/common.h"
CFLAGS="-Wall -Wextra -g -std=c11"
CPPFLAGS="-Wall -Wextra -g -std=c++1z"
MAINFLAGS="-Wall -Wextra -g -std=c++1z"
GLOBAL_COMPILER="clang"
LIB="-lc++"
BUILD_DIR="build"
MAKE_FILE="Makefile"
MAIN="main"
MAIN_TEST="main-test"
SRC_EXTENSIONS=("cpp" "c")
INC_EXTENSIONS=("hpp" "h")

HEADER_PATHS="include"
SRC_PATHS="src"