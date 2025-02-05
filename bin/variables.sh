#!/bin/bash
APP_NAME="app_name"
COMMON_HEADER="include/common.h"
COMMON_FLAGS="-Wall -Wextra -pedantic -Wswitch-enum -g"
CFLAGS="${COMMON_FLAGS} -std=c2x"
CPPFLAGS="${COMMON_FLAGS} -std=c++23"
MAINFLAGS="${COMMON_FLAGS} -std=c++23"
COMPILER="clang"
LIB="-lc++"
BUILD_DIR="build"
MAKE_FILE="Makefile"
MAIN="main"
MAIN_TEST="main-test"
SKIP_SRC=""
SRC_EXTENSIONS=("cpp" "c")
INC_EXTENSIONS=("hpp" "h")
FRAMEWORKS=""

HEADER_PATHS=("include")
SRC_PATHS=("src")
