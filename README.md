# Make Makefile
As I like writing from scratch whatever I can, I am creating a simple shell script that generates a `Makefile` file for C/C++ (also hybrid) projects.

### Description
This project mainly consists of a single script you can place in the workspace folder of your C/C++ project. Once run, the script will look for all the `.c`, `.cpp`, `.h`, and `.hpp` files in its folder and subfolders. Based on those files, the script will create and populate the `Makefile` file which you can use to compile your project.

### Directory structure
The resulting `Makefile` file will create the following files and folders

1. `./build/`, containing the executable (called `prj-out-<OPT_LEVEL>`)
2. `./build/objects/`, containing all the **object files**

Here, `<OPT_LEVEL>` indicates the **optimization** level you have optionally chosen for compiling the project.

## Instructions
You can choose to

* clone/download this repository for a complete C/C++ project example or
* download only `makeMakefile.sh` and place it in the root folder of the project you want to compile. 

Then run

```
./makeMakefile.sh.                 # create the `Makefile` file in ./
make SHELL=/bin/bash [<OPT_LEVEL>] # compile your (or the downloaded) project with optimization level <OPT_LEVEL>
build/prj-out-<OPT_LEVEL>          # execute the compiled program
```
Done!

Note that `<OPT_LEVEL>` is `0` by default, namely if not specified when you run `make`. The accepted values for it are `0`, `1`, `2`, and `3`. The compiled executable is named accordingly.

To cleanup, run

```
make clean         # delete the ./build/ folder and its content
```
As always, feel free to contact me for any questions.