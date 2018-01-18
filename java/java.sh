LIBDIR=.lib
CLASSESDIR=.classes
#printf "." >> temp
#if [ -d $LIBDIR ]; then
#    ls $LIBDIR |\
#        while read line
#        do
#            printf ":${LIBDIR}/${line}" >> temp
#        done
#fi
#classpath=$(cat temp)
##echo $classpath
classpath=".:$(ls -1 .lib | grep ".jar$" | sed 's/^/.lib\//g' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/:/g'):$CLASSESDIR"
/usr/bin/java -cp $classpath $@
