#!/bin/zsh

BD="$(pwd)/$(dirname $0)/.."
source "${BD}/bin/variables.sh"
set -eu

pushd "$BD"
bin/cleanup.sh

function pf() { printf "$1" >>"$MAKE_FILE"; }

pf "# Makefile auto generated using custom generator"
# Find all the directories containing header files

cat /dev/null >header-dir.list # dir only
cat /dev/null >src-full.list   # full path
cat /dev/null >src-name.list   # filename no extension

for EXTENSION in ${SRC_EXTENSIONS[@]}; do
    for f in $(find $SRC_PATHS -name "*.${EXTENSION}"); do
        if ! [ "$f" = "$SKIP_SRC" ]; then
            FILE_NAME=$(basename $f)
            echo "$f" >>src-full.list
            FILE_NO_EXT=${FILE_NAME%.*}
            echo "${FILE_NO_EXT}" >>src-name.list
        fi
    done
done

for EXTENSION in ${INC_EXTENSIONS[@]}; do
    for f in $(find $HEADER_PATHS -name "*.${EXTENSION}"); do
        echo $(dirname $f) >>header-dir.list
    done
done

# Remove duplicates from directory list
sort header-dir.list | uniq >header-sorted-dir.list

# find system libs which may need to be linked
ALL_LIBS=($(egrep -rh "^#include|^#import" $(echo "$SRC_PATHS" "$HEADER_PATHS") 2>/dev/null |
    grep -o "<.*>" |
    sed 's/<//' |
    sed 's/>//' |
    sort |
    uniq))

# select those who actually need to be linked and create LIB list
for LIB_FOUND in ${ALL_LIBS[@]}; do
    case $LIB_FOUND in
    thread)
        LIB="$LIB -pthread"
        ;;
    pthread.h)
        LIB="$LIB -pthread"
        ;;
    curl/curl.h)
        LIB="$LIB -lcurl"
        ;;
    zlib.h)
        LIB="$LIB -lz"
        ;;
    esac
done

pf "\nCFLAGS=${CFLAGS}"
pf "\nCPPFLAGS=${CPPFLAGS}"
pf "\nMAINFLAGS=${MAINFLAGS}"
pf "\nBD=${BD}"
pf "\nOPT ?= 0"

[ "$LIB" != "" ] && pf "\nLIB=$LIB"                                 # LIB added if not empty
[ "$FRAMEWORKS" != "" ] && pf "\nFRAMEWORKS=-framework $FRAMEWORKS" # LIB added if not empty
pf "\nINC="
while read -r folder; do # created -I list
    pf " -I$folder \\"
    pf "\n"
done <header-sorted-dir.list

# Phony recipes
pf "\n.PHONY: all test"
pf "\n"

# All
pf "\nall:"
pf "\n\t@mkdir -p \\"
pf "\n\t${BUILD_DIR}"
pf "\n\t@[ \`grep -c '^#define TEST 1' \"\$(BD)\"/${COMMON_HEADER}\` -eq 1 ] && \\"
pf "\n\tsed -i.bak 's/^#define TEST 1/#define TEST 0/g' \"\$(BD)\"/${COMMON_HEADER}; \\"
pf "\n\t[ \`grep -c '^#define MEM_ANALYSIS 1' \"\$(BD)\"/${COMMON_HEADER}\` -eq 1 ] && \\"
pf "\n\tsed -i.bak 's/^#define MEM_ANALYSIS 1/#define MEM_ANALYSIS 0/g' \"\$(BD)\"/${COMMON_HEADER}; \\"
pf "\n\tmake -C \"\$(BD)\" OPT=\$(OPT) ${BUILD_DIR}/${APP_NAME}-o\$(OPT);"
pf "\n"

pf "\ntest:"
pf "\n\t@mkdir -p \\"
pf "\n\t${BUILD_DIR}"
pf "\n\t@[ \`grep -c '^#define TEST 0' \"\$(BD)\"/${COMMON_HEADER}\` -eq 1 ] && \\"
pf "\n\tsed -i.bak 's/^#define TEST 0/#define TEST 1/g' \"\$(BD)\"/${COMMON_HEADER}; \\"
pf "\n\t[ \`grep -c '^#define MEM_ANALYSIS 0' \"\$(BD)\"/${COMMON_HEADER}\` -eq 1 ] && \\"
pf "\n\tsed -i.bak 's/^#define MEM_ANALYSIS 0/#define MEM_ANALYSIS 1/g' \"\$(BD)\"/${COMMON_HEADER}; \\"
pf "\n\tmake -C \"\$(BD)\" OPT=\$(OPT) ${BUILD_DIR}/${APP_NAME}-test-o\$(OPT);"
pf "\n"

pf "\n${BUILD_DIR}/${APP_NAME}-o\$(OPT):"
while read -r FILE_NAME; do
    if [ "${FILE_NAME}" = "${MAIN_TEST}" ]; then continue; fi
    pf "\\"
    pf "\n\t${BUILD_DIR}/$FILE_NAME-o\$(OPT).o "
done <src-name.list
pf "\n\t${COMPILER} \$(LIB) \$(MAINFLAGS) -O\$(OPT) \$(INC) \$(FRAMEWORKS) \$^ -o \$@"
pf "\n"

# Test
pf "\n${BUILD_DIR}/${APP_NAME}-test-o\$(OPT):"
while read -r FILE_NAME; do
    if [ "${FILE_NAME}" = "${MAIN}" ]; then continue; fi
    pf "\\"
    pf "\n\t${BUILD_DIR}/${FILE_NAME}-o\$(OPT).o "
done <src-name.list
pf "\n\t${COMPILER} \$(LIB) \$(MAINFLAGS) -O\$(OPT) \$(INC) \$(FRAMEWORKS) \$^ -o \$@"
pf "\n"

echo "Adding dependency list"
while read -r SRC_FULL_PATH; do
    FILE_NAME=$(basename "${SRC_FULL_PATH}")
    DIR_NAME=$(dirname "${SRC_FULL_PATH}")
    FILE_NO_EXT=${FILE_NAME%.*}
    FILE_EXT=${FILE_NAME##*.}
    if [ "${FILE_EXT}" = "c" ]; then
        if ! [ "${FILE_NO_EXT}" = "${MAIN}" ] && ! [ "${FILE_NO_EXT}" = "${MAIN_TEST}" ]; then
            CORR_HEADER=$(find ${BD} -name ${FILE_NO_EXT}.h)
        else
            CORR_HEADER=""
        fi
    elif [ "${FILE_EXT}" = "cpp" ]; then
        if ! [ "${FILE_NO_EXT}" = "${MAIN}" ] && ! [ "${FILE_NO_EXT}" = "${MAIN_TEST}" ]; then
            CORR_HEADER=$(find ${BD} -name ${FILE_NO_EXT}.hpp)
        else
            CORR_HEADER=""
        fi
    else
        echo "File extension ${FILE_EXT} not supported"
    fi

    pf "\n${BUILD_DIR}/${FILE_NO_EXT}-o\$(OPT).o: ${SRC_FULL_PATH} "

    HEADER_FILES=($(egrep "^#include|^#import" "${SRC_FULL_PATH}" | grep -v "<" | awk -F '"' '{print $2}'))
    if ! [ "${CORR_HEADER}" = "" ]; then
        HEADER_FILES+=($(egrep "^#include|^#import" "${CORR_HEADER}" | grep -v "<" | awk -F '"' '{print $2}'))
    fi
    UNIQUE_HEADER_FILES=($(for H in "${HEADER_FILES[@]}"; do echo "${H}"; done | sort -u))

    echo "Adding as dependencies header files and corresponding source files found in"
    echo " - ${SRC_FULL_PATH}"
    echo " - "${CORR_HEADER#"${BD}/"}

    for HEADER_FILE in ${UNIQUE_HEADER_FILES[@]}; do
        # Some headers are imported with the path
        HEADER_NAME=$(basename "${HEADER_FILE}")
        HEADER_PATH=$(find "${BD}" -name "${HEADER_NAME}")
        HEADER_PATH_FROM_BD=${HEADER_PATH#"${BD}/"}
        HEADER_NO_EXT=${HEADER_NAME%.*}
        pf "\\"
        pf "\n\t${HEADER_PATH_FROM_BD} "
        if ! [ "${HEADER_NO_EXT}" = "${FILE_NO_EXT}" ]; then
            pf "\\"
            pf "\n\t${BUILD_DIR}/${HEADER_NO_EXT}-o\$(OPT).o "
        fi
    done
    FLAGS=""
    case $FILE_EXT in
    c)
        FLAGS="CFLAGS"
        ;;
    cpp)
        FLAGS="CPPFLAGS"
        ;;
    *)
        echo "Unsupported file extension"
        exit 1
        ;;
    esac
    pf "\n\t${COMPILER} -O\$(OPT) \$(${FLAGS}) \$(INC) -c \$< -o \$@\n"
    pf "\n"
done <src-full.list

rm *.list

popd

echo "Done"
