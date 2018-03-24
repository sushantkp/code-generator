#! /bin/sh

SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/../common/common-functions.sh
. $SCRIPT_DIR/../java/common-java-functions.sh

# create a temp directory, copy all the source files and compile against that
tmp_dir=$(get_temp_dir src)

# copy files to tmp_dir
for cname in ${@:1}
do
    cp $cname ${tmp_dir}/$cname
done

# pre-processing
for cname in ${@:1}
do
    pre-compile.sh ${tmp_dir}/$cname
done


# append tmp dir name to java sourcefiles
srcfiles=()
for cname in ${@:1}
do
    srcfiles=("${srcfiles[@]}" "${tmp_dir}/$cname")
done


# determine classpath
LIBDIR=$(get_lib_dir)
#printf "." >> temp
#if [ -d $LIBDIR ]; then
#    ls $LIBDIR |\
#        while read line
#        do
#            printf ":${LIBDIR}/${line}" >> temp
#        done
#fi
#classpath=$(cat temp)
#rm temp
#
CLASSESDIR=$(get_classes_dir)
jars="$(ls -1 $LIBDIR | grep ".jar$" | sed 's/^/$LIBDIR\//g')" #clean jar file path
if (( $(echo $classpath | wc -l) > 1 ));  then
	jars="$(echo $jars | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/:/g')" # compact multiple lines to one
fi
classpath="$CLASSESDIR:$jars" #clean jar file path
/usr/bin/javac -cp $classpath -g -d $CLASSESDIR -sourcepath $tmp_dir $srcfiles

# save src files to src directory and delete temp dir
cp $srcfiles $tmp_dir/../
rm -rf $tmp_dir
