# Make Makefile
As I like writing from scratch whatever I can, I am creating a simple shell script that generates a `Makefile` file for C/C++ (also hybrid) projects.

#### Please read carefully this document before using the tools provided here.

### Description
This project mainly consists of a single script called `makeMakefile.sh`. This script can placed in any folder of your C/C++ project. Once run, the script will look for all the `.c`, `.cpp`, `.h`, and `.hpp` files in the paths specified in the script itself. Based on those files, the script will create and populate the `Makefile` file which you can use to compile your project.

### Directory structure
The project comes with the following directory tree:

```
.
├── LICENSE
├── README.md
├── include
│   ├── MMFCFunctions.h
│   └── MMFCppFunctions.hpp
├── bin
│   └── makeMakefile.sh
└── src
    ├── c-stuff
    │   └── MMFCFunctions.c
    ├── cpp-stuff
    │   └── MMFCppFunctions.cpp
    └── main.cpp
```

where `.` is the `MMF` folder.

## Instructions
### Test this project

* clone/download this repository for a complete C/C++ project example or

Then run

```
$ bin/makeMakefile.sh                    # create the `Makefile`
```

to generate the file `Makefile` in the project directory:

```
.
├── LICENSE
├── Makefile     # newly created Makefile
├── README.md
...
```
You can now compile the downloaded `C`/`C++` project:

```
$ make SHELL=/bin/bash [OPT=<OPT_LEVEL>] # the downloaded project with optimization level <OPT_LEVEL>
```

Here, `<OPT_LEVEL>` indicates the **optimization level** you can optionally choose for compiling the project. Note that `<OPT_LEVEL>` is `0` by default, namely if not specified when you run `make`. The accepted values for it are `0`, `1`, `2`, and `3`. The compiled executable is named accordingly.

As an example, assuming that `<OPT_LEVEL>` was not specified, the produced result is:

```
.
├── LICENSE
├── Makefile
├── README.md
├── bin
│   └── makeMakefile.sh
├── build                     # build folder
│   └── objects
│       ├── MMFCFunctions.o
│       ├── MMFCppFunctions.o
│       └── main.o
├── include
│   ├── MMFCFunctions.h
│   └── MMFCppFunctions.hpp
├── prj-out-0                 # target file
└── src
    ├── c-stuff
    │   └── MMFCFunctions.c
    ├── cpp-stuff
    │   └── MMFCppFunctions.cpp
    └── main.cpp
```
Notice that the products of `Makefile` are

1. `prj-out-<OPT_LEVEL>` file, the executable
2. `build` folder, where built objects and auxiliary files are saved

The target is ready to be executed:

```
$ ./prj-out-0
Hello from C++!
Hello from C!
```

To cleanup, run

```
make clean         # delete Makefile artifacts
```


### Use makeMakefile.sh in your own project
To build your own `C/C++` project, 

1. Copy `makeMakefile.sh` in your project directory, say `<PATH_TO_SCRIPT>`. It is not necessary choose `<PATH_TO_SCRIPT>` with specific criteria. However, the `bin` folder of your project is recommended. 
2. Open `makeMakefile.sh` with your favorite text editor and modify the values of following parameters:
	- `target_name` - the name of the executable to be generated
	- `target_folder` - folder where the executable is placed
	- `makefile_folder` - folder where `Makefile` is generated
	- `build_folder` - folder where object files and auxiliary files are generated
	- `search_paths` - folder list where project files are located
3. Run `<PATH_TO_SCRIPT>/makeMakefile.sh` to generate `Makefile` where specified
4. `cd` to `<makefile_folder>`
5. Run `make SHELL=/bin/bash [OPT=<OPT_LEVEL>]` to generate the executable
6. Run `./<target_folder>/<target_name>-<OPT_LEVEL>`

As in the original script, it is recommended to prefix with `$bd/` all the folders listed above to have all paths relative to the folder where `makeMakefile.sh` is located.

#### EXTREMELY IMPORTANT: `build_folder` is erased by the command `make clean` and, therefore, it must not contain subfolders you want to keep! In addition, you must not have have multiple projects main files in the paths specified in `search_paths`.

## Final note
Most of my C/C++ projects use my `makeMakefile.sh` script. You may want to look at them for further examples.

Any comments are welcomed and, as always, feel free to contact me if you have any questions.
