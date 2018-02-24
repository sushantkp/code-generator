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
jars="$(ls -1 .lib | grep ".jar$" | sed 's/^/.lib\//g')" #clean jar file path
if (( $(echo $classpath | wc -l) > 1 ));  then
	jars="$(echo $jars | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/:/g')" # compact multiple lines to one
fi
classpath=".:$jars:$CLASSESDIR" #clean jar file path
/usr/bin/java -cp $classpath $@
