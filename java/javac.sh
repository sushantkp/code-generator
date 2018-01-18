# pre-processing
for cname in ${@:1}
do
    pre-compile.sh $cname
done


# determine classpath
LIBDIR=.lib
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
mkdir -p .classes
classpath=".:$(ls -1 .lib | grep ".jar$" | sed 's/^/.lib\//g' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/:/g')"
/usr/bin/javac -cp $classpath -g -d .classes $@
