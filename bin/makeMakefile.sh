bd="`pwd`/`dirname $0`/"        # The base directory: where this script is located
                                # Use it as a prefix to all the paths to ensure they are all absolute

##########################
# customizable variables #
##########################
target_name="prj-out"                          # executable file name
target_folder="$bd/.."                         # executable location
makefile_folder="$bd/../"                      # Makefile location
build_folder="$bd/../build"                    # build folder location
search_paths="$bd $bd/../include $bd/../src"   # paths for header and source files


######################
# don't change below #
######################
make_file="$makefile_folder/Makefile"
object_folder="$build_folder/objects"
pushd "$bd"

function pf () { printf "$1" >> "$make_file"; }

echo "# Makefile auto generated using custom generator" > "$make_file" # Initialize Makefile

# Find all the directories containing header files
cat /dev/null > header-dir.list    # dir only (combined .hpp and .h locations)
cat /dev/null > hpp-file.list      # file name only
cat /dev/null > hpp-full.list      # full path
cat /dev/null > h-file.list        # file name only
cat /dev/null > h-full.list        # full path

# .hpp files only
for f in `find $search_paths -name "*.hpp"`; do
	echo "$f" >> hpp-full.list
	echo "`basename $f | awk -F '.' '{print $1}'`" >> hpp-file.list
	echo `dirname $f` >> header-dir.list
done
# .h files only
for f in `find $search_paths -name "*.h"`; do
	echo "$f" >> h-full.list
	echo "`basename $f | awk -F '.' '{print $1}'`" >> h-file.list
	echo `dirname $f` >> header-dir.list
done
# Remove duplicates from directory list
sort header-dir.list | uniq > header-sorted-dir.list

# Find all .cpp and .c files
cat /dev/null > cpp-file.list      # file name only
cat /dev/null > cpp-full.list      # full path
cat /dev/null > c-file.list      # file name only
cat /dev/null > c-full.list      # full path
# .cpp only
for f in `find $search_paths -name "*.cpp"`; do
	echo "$f" >> cpp-full.list
	echo "`basename $f | awk -F '.' '{print $1}'`" >> cpp-file.list
done
# .c only
for f in `find $search_paths -name "*.c"`; do
	echo "$f" >> c-full.list
	echo "`basename $f | awk -F '.' '{print $1}'`" >> c-file.list
done

# find system libs which may need to be linked
sys_libs=`grep -rh "#include" $(echo "$search_paths") 2>/dev/null | grep -v Binary | grep -o "<.*>" | sed 's/<//' | sed 's/>//' | sort | uniq`
echo $sys_libs
# select those who actually need to be linked and create LDLIBS list
for l in ${sys_libs[@]}; do
# TODO: add more cases as we go (for Ubuntu)
	case $l in
		thread)
		LDLIBS="$LDLIBS -pthread"
		;;
	esac
done

pf "\nCPPFLAGS=-c -Wextra -std=c++14 -O\$(OPT) -g"
pf "\nCFLAGS=-c -Wextra -O\$(OPT) -g"
pf "\nCPPC=g++"
pf "\nCC=gcc"
[ "$LDLIBS" != "" ] && pf "\nLDLIBS=$LDLIBS" # LDLIBS added if not empty
pf "\nINC="
while read -r folder; do       # created -I list
	pf " -I$folder\\"
	pf "\n"
done < header-sorted-dir.list

pf "\n.PHONY: all clean check-directory make-opt check-opt-value"
pf "\n"
pf "\nall: check-directory"
pf "\n"

pf "\ncheck-directory:"
pf "\n\t@[ -d \"$object_folder\" ] || mkdir -p $object_folder"
pf "\n\t@[ -d \"$target_folder\" ] || mkdir -p $target_folder"
pf "\n\t@make SHELL=/bin/bash check-opt-value OPT=\$(OPT)"
pf "\n"

pf "\ncheck-opt-value:"
pf "\n\t@[ \"\$(OPT)\" == \"\" ] && make SHELL=/bin/bash make-opt OPT=0 || make SHELL=/bin/bash make-opt OPT=\$(OPT)\n"

pf "\nmake-opt:"
pf "\n\t@if [ ! -f \"$build_folder/.out-\$(OPT)\" ]; then \\"
pf "\n\t\trm -rf $build_folder/*; \\"
pf "\n\t\tmkdir -p $object_folder; \\"
pf "\n\t\ttouch $build_folder/.out-\$(OPT); \\"
pf "\n\tfi"
pf "\n\t@make SHELL=/bin/bash $target_folder/$target_name-\$(OPT) OPT=\$(OPT)"
pf "\n"

# project executable
pf "\n$target_folder/$target_name-\$(OPT):"
while read -r file_name; do
	pf " $object_folder/$file_name.o"
done < cpp-file.list
while read -r file_name; do
	pf " $object_folder/$file_name.o"
done < c-file.list
pf "\n\t\$(CPPC) \$(LDLIBS) \$(INC) -o \$@ \$^"
pf "\n"

echo "Adding cpp-related dependency list"
while read -r cpp_full_path; do
	echo "Parsing $cpp_full_path"

	cpp_file_name="`echo $(basename $cpp_full_path) | awk -F '.' '{print $1}'`"
	cpp_dir_name="`dirname $cpp_full_path`"
	pf "\n$object_folder/$cpp_file_name.o: $cpp_dir_name/$cpp_file_name.cpp "

	# find all the included libraries in the cpp file
	includes=`grep "^#include" "$cpp_full_path" | grep -v "<" | awk -F '"' '{print $2}'`
	for hpp_file in ${includes[@]}; do
		pf "`find $search_paths -name $hpp_file` "
	done
	# find all the included libraries in the hpp file
	hpp_full_path="`find $search_paths -name "$cpp_file_name.hpp"`"
	# if the hpp file exists, look for dependencies in the hpp file as well
	if [ "$hpp_full_path" != "" ]; then
		hpp_dep=`grep "^#include" "$hpp_full_path" | grep -v "<" | awk -F '"' '{print $2}' | awk -F '.hpp' '{print $1}'`
		for hpp_file in ${hpp_dep[@]}; do
			# echo $hpp_file); exit
			cpp_dep=`find $search_paths -name "$(basename $hpp_file).cpp"`
			[ "$cpp_dep" != "" ] && echo $object_folder/$hpp_file.o && pf "$object_folder/$hpp_file.o "
		done
	else
		echo "No headers in $cpp_file_name.hpp"
	fi

	pf "\n\t\$(CPPC) \$(INC) \$(CPPFLAGS) \$< -o \$@\n"
done < cpp-full.list

echo "Adding c-related dependency list"
while read -r c_full_path; do
	echo "Parsing $c_full_path"

	c_file_name="`echo $(basename $c_full_path) | awk -F '.' '{print $1}'`"
	c_dir_name="`dirname $c_full_path`"
	pf "\n$object_folder/$c_file_name.o: $c_dir_name/$c_file_name.c "

	# find all the included libraries in the .c file
	includes=`grep "^#include" "$c_full_path" | grep -v "<" | awk -F '"' '{print $2}'`
	for h_file in ${includes[@]}; do
		pf "`find $search_paths -name $h_file` "
	done
	# find all the included libraries in the .h file
	h_full_path="`find $search_paths -name "$c_file_name.h"`"
	# if the .h file exists, look for dependencies in the .h file as well
	if [ "$h_full_path" != "" ]; then
		h_dep=`grep "^#include" "$h_full_path" | grep -v "<" | awk -F '"' '{print $2}' | awk -F '.h' '{print $1}'`
		for h_file in ${h_dep[@]}; do
			# echo $h_file); exit
			c_dep=`find $search_paths -name "$(basename $h_file).c"`
			[ "$c_dep" != "" ] && echo $object_folder/$h_file.o && pf "$object_folder/$h_file.o "
		done
	else
		echo "No headers in $c_file_name.h"
	fi

	pf "\n\t\$(CC) \$(INC) \$(CFLAGS) \$< -o \$@\n"
done < c-full.list


pf "\nclean:\n\trm -rf $build_folder $target_folder/$target_name-*\n"

rm *.list

popd