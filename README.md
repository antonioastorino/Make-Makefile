# Make Makefile
A simple shell script that generates a `Makefile` file for C/C++ projects.

#### Please read carefully this document before using the tools provided here.

### Description
This project mainly consists of a single script called `makeMakefile.sh`.
This script must be placed the `bin` folder of your C/C++ project workspace dir, along with the `variables.sh`
and `cleanup.sh` files.
Once run, the script will look for all the files in the paths specified by `HEADER_PATHS` and `SRC_PATHS`
in `variables.sh`. You can specified multiple paths by adding them to their corresponding arrays.

The `SRC_EXTENSIONS` array lists all the possible extensions for the implementation files.
Similarly, `SRC_EXTENSIONS` is an array of extensions used in the project for header files.
Notice that, `.c` files will be compiled using the `CFLAGS` and `gcc` compiler. `.cpp` files
are compiled using `CPPFLAGS` and `g++` compiler.
Although it is not done here, it is also possible to compile `Objective-C++` code, using the `mm` extension
- see my project `PLT` as an example.

### Directory structure
The project comes with the following directory tree:

```
.
├── LICENSE
├── README.md
├── include
│   ├── common.h
│   └── c-stuff
│   |   └── MMFCFunctions.h
│   └── cpp-stuff
│       └── MMFCppFunctions.hpp
├── bin
│   └── cleanup.sh
│   └── makeMakefile.sh
│   └── variables.sh
└── src
    ├── common.c
    ├── c-stuff
    │   └── MMFCFunctions.c
    ├── cpp-stuff
    │   └── MMFCppFunctions.cpp
    ├── main-test.cpp
    └── main.cpp
```

where `.` is the workspace folder.

## Build, run, cleanup

First, you should create the `Makefile` file by running

```shell
$ bin/makeMakefile.sh                    # create the `Makefile`
```
The file will be created in the workspace folder. To compile, execute

```shell
$ make [MODE=TEST] [OPT=<OPT_LEVEL>]     # complie
```

Here, `<OPT_LEVEL>` indicates the **optimization level** you can optionally choose for compiling the project.
If `<OPT_LEVEL>` is not specified, `0` will be used. The accepted values for it are `0`, `1`, `2`, and `3`.
The compiled executable is named accordingly.

If `MODE=TEST` is specified, the unit test will be compiled. There are, in fact, two 'main' files.
In test mode, the macro `TEST`, defined in `include/common.h`, is set to `1` and the executable will use
the `main()` function in `main-test.cpp` as the program entry point.
In case `MODE=TEST` is not used, the macro `TEST` is set to `0`, the unit tests are not
compiled, and the executable will be created using `main.cpp`, instead.

The name of the executable can be specified using the variable `APP_NAME` in `variables.sh`.
The actual file name will be extended with the suffix `-o<OPT_LEVEL>` and located in the `build` folder.
Therefore, executing the target can be done by running

```shell
$ ./build/app_name-o<OPT_LEVEL>         # execute main program
```

or

```shell
$ ./build/app_nam-test-o<OPT_LEVEL>     # execute unit test
```

To cleanup, run

```shell
$ bin/cleanup.sh                        # delete Makefile and build folder
```

> NOTE: every header file must have a corresponding implementation file, even empty.
As an example, see `common.c`.
This ensures that, if the header file changes, also the implementation file does.
In turn, nested dependencies reflects those updates and Make will detect them. 
